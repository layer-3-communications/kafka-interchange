{-# language BangPatterns #-}
{-# language LambdaCase #-}
{-# language TypeApplications #-}

-- | Adapted from kafka documentation. All fixed-width types use big-endian
-- encoding.
--
-- > BOOLEAN    | Single byte. Must be 0 or 1.
-- > INT8       | Signed 8-bit integer. Exactly 1 byte.
-- > INT16      | Signed 16-bit integer. Exactly 2 bytes.
-- > INT32      | Signed 32-bit integer. Exactly 4 bytes.
-- > INT64      | Signed 64-bit integer. Exactly 8 bytes.
-- > UINT32     | Unsigned 32-bit integer. Exactly 4 bytes.
-- > VARINT     | Signed 32-bit integer. LEB128 with zigzag.
-- > VARLONG    | Single 64-bit integer. LEB128 with zigzag.
-- > UUID       | 16 bytes
-- > FLOAT64    | Double-precision 64-bit format IEEE 754 value. Exactly 8 bytes.
-- > STRING                  | N is given as INT16. Then N bytes follow (UTF-8 sequence).
-- > COMPACT_STRING          | N+1 is given as an UNSIGNED_VARINT. Then N bytes follow (UTF-8 sequence).
-- > NULLABLE_STRING         | Same as STRING, but N = -1 means null
-- > COMPACT_NULLABLE_STRING | Same as COMPACT_STRING but N+1 = 0 means null.
-- > BYTES                   | N given as INT32. Then N bytes follow.
-- > COMPACT_BYTES           | N+1 given as UNSIGNED_VARINT. Then N bytes follow.
-- > NULLABLE_BYTES          | Same as BYTES but N = -1 means null.
-- > COMPACT_NULLABLE_BYTES  | Same as COMPACT_BYTES but N+1 = 0 means null.
-- > RECORDS                 | See official documentation
-- > ARRAY                   | Sequence of objects. First, N is given as INT32. Then N instances of type T follow. When N = -1, it means null.
-- > COMPACT_ARRAY           | Sequence of objects, First, N+1 is given as UNSIGNED_VARINT. Then N instances of type T follow. When N+1 = 0, it means null.
module Kafka.Builder
  ( Builder
  , nullableString
  , compactNullableString
  , compactString
  , compactBytes
  , nonCompactBytes
  , string
  , array
  , compactArray
  , compactNullableArray
  , int8
  , int16
  , int32
  , int32Array
  , int64
  , word128
  , varWordNative
  , varIntNative
  , varInt32
  , varInt64
  , boolean
    -- * Re-exports
  , word8
  , copy
  , fromBounded
  , run
  , consLength
  , bytes
  , Builder.runOnto
  , Builder.runOntoLength
  , Builder.chunks
  ) where

import Data.Bytes.Builder (Builder,fromBounded,run,word8,consLength,copy,bytes)
import Data.Int (Int8,Int16,Int32,Int64)
import Data.Primitive (SmallArray,PrimArray)
import Data.Text (Text)
import Data.Bytes (Bytes)
import Data.Bytes.Chunks (Chunks)
import Data.WideWord (Word128)
import qualified Data.Bytes as Bytes
import qualified Data.Bytes.Builder as Builder
import qualified Data.Bytes.Text.Utf8 as Utf8
import qualified Data.Primitive as PM

-- Implementation Note: We unconditionally copy the string since kafka strings
-- are typically small (less than 255 bytes). Topic names cannot even be more
-- than 255 bytes.
nullableString :: Maybe Text -> Builder
nullableString = \case
  Nothing -> Builder.int16BE (-1)
  Just s -> string s

compactNullableString :: Maybe Text -> Builder
compactNullableString = \case
  Nothing -> Builder.word8 0
  Just s ->
    let b = Utf8.fromText s
     in Builder.wordLEB128 (fromIntegral @Int @Word (Bytes.length b + 1)) <> Builder.copy b

compactNullableArray :: (a -> Builder) -> Maybe (SmallArray a) -> Builder
{-# inline compactNullableArray #-}
compactNullableArray f m = case m of
  Nothing -> Builder.word8 0
  Just xs -> Builder.wordLEB128 (fromIntegral @Int @Word (1 + PM.sizeofSmallArray xs)) <> foldMap f xs

compactString :: Text -> Builder
compactString s =
  let b = Utf8.fromText s
   in compactBytes b

compactBytes :: Bytes -> Builder
compactBytes b = Builder.wordLEB128 (fromIntegral @Int @Word (Bytes.length b + 1)) <> Builder.copy b

string :: Text -> Builder
string !s = 
  let b = Utf8.fromText s
   in Builder.int16BE (fromIntegral @Int @Int16 (Bytes.length b)) <> Builder.copy b

nonCompactBytes :: Bytes -> Builder
nonCompactBytes !b = 
  Builder.int32BE (fromIntegral @Int @Int32 (Bytes.length b))
  <>
  Builder.copy b

-- | Encode the length as @int32@. Then, encode all the elements one after another.
-- Does not support nullable array.
array :: (a -> Builder) -> SmallArray a -> Builder
{-# inline array #-}
array f !xs = Builder.int32BE (fromIntegral @Int @Int32 (PM.sizeofSmallArray xs)) <> foldMap f xs

-- | Not nullable.
compactArray :: (a -> Builder) -> SmallArray a -> Builder
{-# inline compactArray #-}
compactArray f !xs = Builder.wordLEB128 (fromIntegral @Int @Word (1 + PM.sizeofSmallArray xs)) <> foldMap f xs

-- x compactArrayChunks :: (a -> Chunks) -> SmallArray a -> Chunks
-- x {-# inline compactArrayChunks #-}
-- x compactArrayChunks f !xs = Builder.runOnto 20
-- x   (Builder.wordLEB128 (fromIntegral @Int @Word (1 + PM.sizeofSmallArray xs)))
-- x   (foldMap f xs)

int8 :: Int8 -> Builder
{-# inline int8 #-}
int8 = Builder.word8 . fromIntegral

int16 :: Int16 -> Builder
{-# inline int16 #-}
int16 = Builder.int16BE

int32 :: Int32 -> Builder
{-# inline int32 #-}
int32 = Builder.int32BE

int64 :: Int64 -> Builder
{-# inline int64 #-}
int64 = Builder.int64BE

word128 :: Word128 -> Builder
{-# inline word128 #-}
word128 = Builder.word128BE

varWordNative :: Word -> Builder
{-# inline varWordNative #-}
varWordNative = Builder.wordLEB128

varIntNative :: Int -> Builder
{-# inline varIntNative #-}
varIntNative = Builder.intLEB128

varInt64 :: Int64 -> Builder
{-# inline varInt64 #-}
varInt64 = Builder.int64LEB128

varInt32 :: Int32 -> Builder
{-# inline varInt32 #-}
varInt32 = Builder.int32LEB128

boolean :: Bool -> Builder
boolean b = case b of
  False -> Builder.word8 0
  True -> Builder.word8 1

int32Array :: PrimArray Int32 -> Builder
int32Array !x =
  Builder.int32BE (fromIntegral @Int @Int32 n)
  <>
  Builder.int32ArrayBE x 0 n
  where
  !n = PM.sizeofPrimArray x
