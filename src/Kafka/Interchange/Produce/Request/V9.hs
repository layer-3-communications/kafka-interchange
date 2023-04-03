{-# language BangPatterns #-}
{-# language NamedFieldPuns #-}
{-# language DataKinds #-}
{-# language DeriveFunctor #-}
{-# language DuplicateRecordFields #-}
{-# language FlexibleContexts #-}
{-# language GeneralizedNewtypeDeriving #-}
{-# language MultiParamTypeClasses #-}
{-# language OverloadedStrings #-}
{-# language PolyKinds #-}
{-# language RankNTypes #-}
{-# language TypeFamilies #-}
{-# language UnboxedTuples #-}
{-# language UndecidableInstances #-}

module Kafka.Interchange.Produce.Request.V9
  ( Request(..)
  , Topic(..)
  , Partition(..)
  , apiVersion
  , apiKey
  , encode
  , toChunks
  ) where

import Data.Int
import Data.Primitive (SmallArray)
import Data.Text (Text)
import Kafka.Data.RecordBatch (RecordBatch(..))
import Data.Bytes.Chunks (Chunks)

import qualified Kafka.Builder as Builder
import qualified Kafka.Builder.Bounded as Bounded
import qualified Data.Bytes.Chunks as Chunks
import qualified Arithmetic.Nat as Nat
import qualified Kafka.Data.RecordBatch as RecordBatch

import qualified Kafka.Data.Acknowledgments as Acknowledgments

-- Description from Kafka docs:
--
-- > Produce Request (Version: 9) => transactional_id acks timeout_ms [topic_data] TAG_BUFFER 
-- >   transactional_id => COMPACT_NULLABLE_STRING
-- >   acks => INT16
-- >   timeout_ms => INT32
-- >   topic_data => name [partition_data] TAG_BUFFER 
-- >     name => COMPACT_STRING
-- >     partition_data => index records TAG_BUFFER 
-- >       index => INT32
-- >       records => COMPACT_RECORDS

apiVersion :: Int16
apiVersion = 9

apiKey :: Int16
apiKey = 0

toChunks :: Request -> Chunks
toChunks = Builder.run 256 . encode

encode :: Request -> Builder.Builder
encode Request{transactionalId,acks=Acknowledgments.Acknowledgments acks,timeoutMilliseconds,topicData} =
  Builder.compactNullableString transactionalId
  <>
  Builder.fromBounded Nat.constant
    ( Bounded.int16 acks
      `Bounded.append`
      Bounded.int32 timeoutMilliseconds
    )
  <>
  Builder.compactArray encodeTopicData topicData
  <>
  Builder.word8 0

encodeTopicData :: Topic -> Builder.Builder
encodeTopicData Topic{name,partitions} =
  Builder.compactString name
  <>
  Builder.compactArray encodePartition partitions
  <>
  Builder.word8 0

encodePartition :: Partition -> Builder.Builder
encodePartition Partition{index,records} =
  Builder.int32 index
  <>
  -- This is not documented, but in V9+, you have to add the number 1
  -- the the size of the encoded record batch. The kafka source code
  -- confirms this. The proof is in org.apache.kafka.common.message.ProduceRequestData,
  -- a generated file, on a line that says:
  --   _writable.writeUnsignedVarint(records.sizeInBytes() + 1);
  Builder.varWordNative (fromIntegral (1 + Chunks.length batchChunks))
  <>
  Builder.chunks batchChunks
  <>
  Builder.word8 0
  where
  batchChunks = RecordBatch.toChunks records

data Request = Request
  { transactionalId :: !(Maybe Text)
  , acks :: !Acknowledgments.Acknowledgments
  , timeoutMilliseconds :: !Int32
  , topicData :: !(SmallArray Topic)
  }

data Topic = Topic
  { name :: !Text
    -- ^ Topic name
  , partitions :: !(SmallArray Partition)
  }

data Partition = Partition
  { index :: !Int32
  , records :: !RecordBatch
    -- ^ Record batch is decoded in a separate step.
  }
