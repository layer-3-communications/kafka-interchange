{-# language BangPatterns #-}
{-# language LambdaCase #-}
{-# language MultiWayIf #-}
{-# language NumericUnderscores #-}

module Kafka.Parser
  ( compactArray
  , array
  , compactBytes
  , nonCompactBytes
  , compactString
  , compactNullableString
  , string
  , compactInt32Array
  , int32Array
  , varintLengthPrefixedArray
  , varWordNative
  , varIntNative
  , varInt32
  , varInt64
  , apiKey
  , errorCode
  , boolean
  , BigEndian.int16
  , BigEndian.int32
  , BigEndian.word16
  , BigEndian.word32
  , BigEndian.int64
  , BigEndian.word128
  , Parser.fail
  ) where

import Data.Bytes (Bytes)
import Data.Bytes.Parser (Parser)
import Data.Int (Int32,Int64)
import Data.Primitive (SmallArray,PrimArray)
import Data.Text (Text)
import Kafka.ApiKey (ApiKey(ApiKey))
import Kafka.ErrorCode (ErrorCode(ErrorCode))
import Kafka.Parser.Context (Context)

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

nonCompactBytes :: Context -> Parser Context s Bytes
nonCompactBytes ctx = do
  len <- BigEndian.int32 ctx
  if | len <= (-2) -> Parser.fail ctx
     | len <= 0 -> pure mempty
     | len >= 1000000 -> Parser.fail ctx
     | otherwise -> Parser.take ctx (fromIntegral len)

-- | This maps NULL to the empty byte sequence.
compactBytes :: Context -> Parser Context s Bytes
compactBytes ctx = do
  len0 <- Leb128.word32 ctx
  let !lenSucc = fromIntegral len0 :: Int
  if lenSucc < 2
    then pure mempty
    else do
      let len = lenSucc - 1
      Parser.take ctx len

string :: Context -> Parser Context s Text
string ctx = do
  len <- BigEndian.int16 ctx
  if | len <= (-2) -> Parser.fail ctx
     | len <= 0 -> pure mempty
     | otherwise -> do
         b <- Parser.take ctx (fromIntegral len)
         let sbs = Bytes.toShortByteString b
         case TS.fromShortByteString sbs of
           Nothing -> Parser.fail ctx
           Just ts -> pure (TS.toText ts)

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

compactNullableString :: Context -> Parser Context s (Maybe Text)
compactNullableString ctx = do
  len0 <- Leb128.word32 ctx
  let !lenSucc = fromIntegral len0 :: Int
  case lenSucc of
    0 -> pure Nothing
    1 -> pure (Just mempty)
    _ -> do
      let len = lenSucc - 1
      b <- Parser.take ctx len
      let sbs = Bytes.toShortByteString b
      case TS.fromShortByteString sbs of
        Nothing -> Parser.fail ctx
        Just ts -> pure (Just (TS.toText ts))

int32Array :: Context -> Parser Context s (PrimArray Int32)
int32Array ctx = do
  len0 <- BigEndian.int32 ctx
  if | len0 <= (-2) -> Parser.fail ctx
     | len0 <= 0 -> pure mempty
     | len0 >= 1000000 -> Parser.fail ctx
     | otherwise -> do
         let len = fromIntegral len0 :: Int
         dst <- Parser.effect (PM.newPrimArray len)
         let go !ix = if ix < len
               then do
                 a <- BigEndian.int32 (Ctx.Index ix ctx)
                 Parser.effect (PM.writePrimArray dst ix a)
                 go (ix + 1)
               else Parser.effect (PM.unsafeFreezePrimArray dst)
         go (0 :: Int)

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
array :: (Context -> Parser Context s a) -> Context -> Parser Context s (SmallArray a)
{-# inline array #-}
array f ctx = do
  len <- BigEndian.int32 ctx
  if | len <= (-2) -> Parser.fail ctx
     | len <= 0 -> pure mempty
     | len >= 1000000 -> Parser.fail ctx
     | otherwise -> replicateN f (fromIntegral len) ctx

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
    _ | len >= 10_000_000 -> Parser.fail ctx
      | otherwise -> replicateN f len ctx

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

varWordNative :: e -> Parser e s Word
{-# inline varWordNative #-}
varWordNative e = fmap fromIntegral (Leb128.word32 e)

-- This is only ever used for array lengths, so we restrict the
-- range to 32-bit integers.
varIntNative :: e -> Parser e s Int
{-# inline varIntNative #-}
varIntNative e = fmap fromIntegral (Leb128.int32 e)

varInt32 :: e -> Parser e s Int32
{-# inline varInt32 #-}
varInt32 e = Leb128.int32 e

varInt64 :: e -> Parser e s Int64
{-# inline varInt64 #-}
varInt64 e = Leb128.int64 e

-- | Same thing as 'int16' but wraps it up in ApiKey newtype.
apiKey :: e -> Parser e s ApiKey
{-# inline apiKey #-}
apiKey e = fmap ApiKey (BigEndian.int16 e)

-- | Same thing as 'int16' but wraps it up in ErrorCode newtype.
errorCode :: e -> Parser e s ErrorCode
{-# inline errorCode #-}
errorCode e = fmap ErrorCode (BigEndian.int16 e)
