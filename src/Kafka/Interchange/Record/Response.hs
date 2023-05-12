{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language LambdaCase #-}
{-# language NumericUnderscores #-}
{-# language DataKinds #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}
{-# language TypeApplications #-}

module Kafka.Interchange.Record.Response
  ( Record(..)
  , Header(..)
  , parser
  , parserArray
  , decodeArray
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
  , timestampDelta :: !Int64
  , offsetDelta :: !Int32
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
    -- ^ Header key. For records that we are encoding, text (rather than
    -- some kind of builder) is a reasonable choice since header keys are
    -- typically not assembled from smaller pieces.
  , value :: {-# UNPACK #-} !Bytes
    -- ^ Header value. This is currently Bytes, and I'm torn about whether
    -- or not to change it to a builder or chunks type. On one hand, it
    -- makes a more sense for it to be done that way, but on the
    -- other hand, I do not think that values are particularly likely
    -- to be constructed since they are small.
  } deriving stock (Show)

-- | This consumes the entire input. If it succeeds, there were no
-- leftovers.
decodeArray :: Bytes -> Maybe (SmallArray Record)
decodeArray = Parser.parseBytesMaybe parserArray

-- | Parse several records laid out one after the other.
parserArray :: Parser () s (SmallArray Record)
parserArray = go [] 0
  where
  go !acc !n = Parser.isEndOfInput >>= \case
    True -> pure $! C.unsafeFromListReverseN n acc
    False -> do
      r <- parser
      go (r : acc) (n + 1)

parser :: Parser () s Record
parser = do
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
      , timestampDelta
      , offsetDelta
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
uninitializedHeader = errorWithoutStackTrace "Kafka.Interchange.Record.Response.parserHeaders: implementation mistake"
  
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
