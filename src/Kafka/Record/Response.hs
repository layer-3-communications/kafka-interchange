{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language LambdaCase #-}
{-# language NumericUnderscores #-}
{-# language DataKinds #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}
{-# language TypeApplications #-}

module Kafka.Record.Response
  ( Record(..)
  , Header(..)
    -- * Decode
    -- ** Relative Offsets
  , decodeArray
    -- * Decode 
    -- ** Absolute Offsets
  , decodeArrayAbsolute
  ) where

import Control.Monad (when)
import Data.Bytes (Bytes)
import Data.Bytes.Chunks (Chunks(ChunksCons,ChunksNil))
import Data.Int (Int32,Int64)
import Data.Primitive (SmallArray)
import Data.Text (Text)
import Data.Bytes.Parser (Parser)
import Data.Word (Word8)

import qualified Data.Primitive.Contiguous as C
import qualified Arithmetic.Nat as Nat
import qualified Data.Bytes as Bytes
import qualified Data.Bytes.Chunks as Chunks
import qualified Data.Bytes.Text.Utf8 as Utf8
import qualified Data.Text.Short as TS
import qualified Data.Bytes.Parser as Parser
import qualified Data.Primitive as PM
import qualified Kafka.Parser

-- | Information about @Record@ from Kafka documentation:
--
-- > length: varint
-- > attributes: int8
-- >     bit 0~7: unused
-- > timestampDelta: varlong
-- > offsetDelta: varint
-- > keyLength: varint
-- > key: byte[]
-- > valueLen: varint
-- > value: byte[]
-- > Headers => [Header]
--
data Record = Record
  { attributes :: !Word8
    -- ^ To the author's understanding, record attributes are unused,
    -- and this will always be zero. But just to be safe, this library
    -- parses it from the encoded record.
  , timestampDelta :: !Int64
  , offsetDelta :: !Int64
    -- ^ We deviate from the spec here by making this a 64-bit integer instead
    -- of a 32-bit integer. We do this so that the integral type is wide enough
    -- to hold an absolute offset.
  , key :: {-# UNPACK #-} !Bytes
    -- ^ We decode a null key to the empty byte sequence.
  , value :: {-# UNPACK #-} !Bytes
  , headers :: {-# UNPACK #-} !(SmallArray Header)
  } deriving stock (Show)

-- | Information about @Header@ from Kafka documentation:
--
-- > headerKeyLength: varint
-- > headerKey: String
-- > headerValueLength: varint
-- > value: byte[]
data Header = Header
  { key :: {-# UNPACK #-} !Text
    -- ^ Header key.
  , value :: {-# UNPACK #-} !Bytes
    -- ^ Header value.
  } deriving stock (Show)

-- | This consumes the entire input. If it succeeds, there were no
-- leftovers.
decodeArray :: Bytes -> Maybe (SmallArray Record)
{-# noinline decodeArray #-}
decodeArray = Parser.parseBytesMaybe (parserArrayOf (parser 0 0))

-- | Variant of 'decodeArray' that converts the timestamp and offset
-- deltas to absolute timestamps and offsets. In the resulting records,
-- the fields 'timestampDelta' and 'offsetDelta' are misnomers.
decodeArrayAbsolute ::
     Int64 -- ^ Base timestamp (from record batch)
  -> Int64 -- ^ Base offset (from record batch)
  -> Bytes
  -> Maybe (SmallArray Record)
{-# noinline decodeArrayAbsolute #-}
decodeArrayAbsolute !baseTimestamp !baseOffset
  = Parser.parseBytesMaybe (parserArrayOf (parser baseTimestamp baseOffset))

-- | Parse several records laid out one after the other.
parserArrayOf :: Parser () s Record -> Parser () s (SmallArray Record)
{-# inline parserArrayOf #-} 
parserArrayOf p = go [] 0
  where
  go !acc !n = Parser.isEndOfInput >>= \case
    True -> pure $! C.unsafeFromListReverseN n acc
    False -> do
      r <- p
      go (r : acc) (n + 1)

parser ::
     Int64 -- ^ base timestamp
  -> Int64 -- ^ base offset
  -> Parser () s Record
parser !baseTimestamp !baseOffset = do
  len <- Kafka.Parser.varIntNative ()
  Parser.delimit () () len $ do
    attributes <- Parser.any ()
    timestampDelta <- Kafka.Parser.varInt64 ()
    offsetDelta <- Kafka.Parser.varInt32 ()
    keyLength <- Kafka.Parser.varIntNative ()
    when (keyLength < (-1) || keyLength >= 1000000) (Parser.fail ())
    -- Null keys are mapped to empty bytes.
    key <- Parser.take () (max 0 keyLength)
    valueLength <- Kafka.Parser.varIntNative ()
    -- I don't think that null values are allowed.
    when (valueLength < 0 || valueLength >= 2000000000) (Parser.fail ())
    value <- Parser.take () valueLength
    headers <- parserHeaders
    pure Record
      { attributes
      , timestampDelta=timestampDelta + baseTimestamp
      , offsetDelta=fromIntegral offsetDelta + baseOffset
      , key
      , value
      , headers
      }

parserHeaders :: Parser () s (SmallArray Header)
parserHeaders = do
  len <- Kafka.Parser.varIntNative ()
  case len of
    0 -> pure mempty
    -- Having more than 100K headers is unfathomable.
    _ | len >= 100_000 -> Parser.fail ()
      | otherwise -> replicateHeaderN len

replicateHeaderN :: Int -> Parser () s (SmallArray Header)
replicateHeaderN !len = do
  dst <- Parser.effect (PM.newSmallArray len uninitializedHeader)
  let go !ix = if ix < len
        then do
          a <- parserHeader
          Parser.effect (PM.writeSmallArray dst ix a)
          go (ix + 1)
        else Parser.effect (PM.unsafeFreezeSmallArray dst)
  go (0 :: Int)

uninitializedHeader :: Header
uninitializedHeader = errorWithoutStackTrace "Kafka.Record.Response.parserHeaders: implementation mistake"
  
parserHeader :: Parser () s Header
parserHeader = do
  keyLength <- Kafka.Parser.varIntNative ()
  when (keyLength < 0) (Parser.fail ())
  keyBytes <- Parser.take () keyLength
  -- This performs a copy of the memory. Fix this once text-2.0.3 or
  -- newer is released.
  case TS.fromShortByteString (Bytes.toShortByteString keyBytes) of
    Nothing -> Parser.fail ()
    Just keyShort -> do
      valueLength <- Kafka.Parser.varIntNative ()
      when (valueLength < 0) (Parser.fail ())
      value <- Parser.take () valueLength
      pure Header{key=TS.toText keyShort,value}
