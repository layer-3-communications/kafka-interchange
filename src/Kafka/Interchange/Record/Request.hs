{-# language DataKinds #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}
{-# language TypeApplications #-}

module Kafka.Interchange.Record.Request
  ( Record(..)
  , Header(..)
  , toChunks
  , toChunksOnto
  ) where

import Data.Bytes (Bytes)
import Data.Bytes.Chunks (Chunks(ChunksCons,ChunksNil))
import Data.Int (Int32,Int64)
import Data.Primitive (SmallArray)
import Data.Text (Text)
import Kafka.Builder (Builder)

import qualified Arithmetic.Nat as Nat
import qualified Data.Bytes as Bytes
import qualified Data.Bytes.Chunks as Chunks
import qualified Data.Bytes.Text.Utf8 as Utf8
import qualified Data.Primitive as PM
import qualified Kafka.Builder as Builder
import qualified Kafka.Builder.Bounded as Bounded

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
  { timestampDelta :: !Int64
  , offsetDelta :: !Int32
  , key :: {-# UNPACK #-} !Bytes
    -- ^ Setting the key to the empty byte sequence causes it to be treated
    -- as though it were the null key. Technically, we could do the right
    -- thing by wrapping the Bytes with Maybe, but using the empty string
    -- as the key is a terrible idea anyway.
  , value :: {-# UNPACK #-} !Bytes
    -- ^ In a data-encoding setting, it actually makes more sense for this
    -- to be Chunks, not Bytes. But in a data-decoding setting, Bytes makes
    -- more sense. It might be better to create a separate type for each
    -- setting.
  , headers :: {-# UNPACK #-} !(SmallArray Header)
  }

toChunks :: Record -> Chunks
toChunks r = toChunksOnto r ChunksNil

-- | Variant of 'toChunks' that gives the caller control over what chunks
-- come after the encoded record. For example, it is possible to improve
-- the performance of
--
-- > foldMap toChunks records
--
-- by rewriting it as
--
-- > foldr toChunksOnto ChunksNil records
toChunksOnto :: Record -> Chunks -> Chunks
toChunksOnto r c = ChunksCons
  (Bytes.fromByteArray (Bounded.run Nat.constant (Bounded.varIntNative (fromIntegral n))))
  recordChunks
  where
  (n,recordChunks) = Builder.runOntoLength 128 (encodeWithoutLength r) c

encodeWithoutLength :: Record -> Builder
encodeWithoutLength Record{timestampDelta,offsetDelta,key,value,headers} =
  Builder.word8 0x00
  <>
  Builder.varInt64 timestampDelta
  <>
  Builder.varInt32 offsetDelta
  <>
  Builder.varIntNative
    (case Bytes.length key of
      0 -> (-1)
      klen -> klen
    )
  <>
  Builder.copy key
  <>
  Builder.varIntNative (Bytes.length value)
  <>
  Builder.bytes value
  <>
  Builder.varIntNative (PM.sizeofSmallArray headers)
  <>
  foldMap encodeHeader headers

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
  }

encodeHeader :: Header -> Builder
encodeHeader Header{key,value} =
  Builder.varIntNative (Bytes.length keyBytes)
  <>
  Builder.copy keyBytes
  <>
  Builder.varIntNative (Bytes.length value)
  <>
  Builder.copy value
  where
  keyBytes = Utf8.fromText key
