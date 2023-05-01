{-# language BangPatterns #-}
{-# language LambdaCase #-}

module Kafka.Parser
  ( compactArray
  , compactString
  , compactInt32Array
  , varintLengthPrefixedArray
  , boolean
  , BigEndian.int16
  , BigEndian.int32
  , BigEndian.word32
  , BigEndian.int64
  , BigEndian.word128
  ) where

import Data.Primitive (SmallArray,PrimArray)
import Data.Bytes.Parser (Parser)
import Kafka.Parser.Context (Context)
import Data.Text (Text)
import Data.Int (Int32)

import qualified Kafka.Parser.Context as Ctx
import qualified Data.Primitive as PM
import qualified Data.Bytes.Parser as Parser
import qualified Data.Bytes.Parser.Leb128 as Leb128
import qualified Data.Bytes.Parser.BigEndian as BigEndian
import qualified Data.Text.Short as TS
import qualified Data.Bytes as Bytes

boolean :: Context -> Parser Context s Bool
boolean ctx = Parser.any ctx >>= \case
  0 -> pure False
  _ -> pure True

-- | This maps NULL to the empty string.
compactString :: Context -> Parser Context s Text
compactString ctx = do
  len0 <- Leb128.word32 ctx
  let !lenSucc = fromIntegral len0 :: Int
  if lenSucc < 2
    then pure mempty
    else do
      let len = lenSucc - 1
      b <- Parser.take ctx len
      let sbs = Bytes.toShortByteString b
      case TS.fromShortByteString sbs of
        Nothing -> Parser.fail ctx
        Just ts -> pure (TS.toText ts)

-- | This maps NULL to the empty array.
compactInt32Array :: Context -> Parser Context s (PrimArray Int32)
compactInt32Array ctx = do
  len0 <- Leb128.word32 ctx
  let !lenSucc = fromIntegral len0 :: Int
  if lenSucc < 2
    then pure mempty
    else do
      let len = lenSucc - 1
      dst <- Parser.effect (PM.newPrimArray len)
      let go !ix = if ix < len
            then do
              a <- BigEndian.int32 (Ctx.Index ix ctx)
              Parser.effect (PM.writePrimArray dst ix a)
              go (ix + 1)
            else Parser.effect (PM.unsafeFreezePrimArray dst)
      go (0 :: Int)

-- | This maps NULL to the empty array.
compactArray :: (Context -> Parser Context s a) -> Context -> Parser Context s (SmallArray a)
{-# inline compactArray #-}
compactArray f ctx = do
  len0 <- Leb128.word32 ctx
  let !lenSucc = fromIntegral len0 :: Int
  if lenSucc < 2
    then pure mempty
    else do
      let len = lenSucc - 1
      replicateN f len ctx

-- | This is the same thing as 'compactArray' except that the encoded number
-- is not expected to be the successor of the array length. Instead, it should
-- be the actual array length.
varintLengthPrefixedArray :: (Context -> Parser Context s a) -> Context -> Parser Context s (SmallArray a)
{-# inline varintLengthPrefixedArray #-}
varintLengthPrefixedArray f ctx = do
  len0 <- Leb128.word32 ctx
  let !len = fromIntegral len0 :: Int
  case len of
    0 -> pure mempty
    _ -> replicateN f len ctx

replicateN :: (Context -> Parser Context s a) -> Int -> Context -> Parser Context s (SmallArray a)
{-# inline replicateN #-}
replicateN f !len ctx = do
  dst <- Parser.effect (PM.newSmallArray len uninitializedArray)
  let go !ix = if ix < len
        then do
          a <- f (Ctx.Index ix ctx)
          Parser.effect (PM.writeSmallArray dst ix a)
          go (ix + 1)
        else Parser.effect (PM.unsafeFreezeSmallArray dst)
  go (0 :: Int)

uninitializedArray :: a
uninitializedArray = errorWithoutStackTrace "Kafka.Parser: uninitializedArray"
