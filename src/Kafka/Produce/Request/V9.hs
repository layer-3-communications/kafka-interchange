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

module Kafka.Produce.Request.V9
  ( Request(..)
  , Topic(..)
  , Partition(..)
  , encode
  , toChunks
    -- * Request Construction
  , singleton
  ) where

import Data.Int
import Data.Primitive (SmallArray)
import Data.Text (Text)
import Kafka.RecordBatch.Request (RecordBatch(..))
import Data.Bytes.Chunks (Chunks)

import qualified Arithmetic.Nat as Nat
import qualified Data.Bytes.Chunks as Chunks
import qualified Data.Primitive.Contiguous as C
import qualified Kafka.Acknowledgments as Acknowledgments
import qualified Kafka.Builder as Builder
import qualified Kafka.Builder.Bounded as Bounded
import qualified Kafka.RecordBatch.Request as RecordBatch

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

-- | Create a request for producing to a single partition of a single topic.
-- Transactions are not used.
singleton ::
     Acknowledgments.Acknowledgments -- ^ Acknowledgements
  -> Int32 -- ^ Timeout milliseconds
  -> Text -- ^ Topic name
  -> Int32 -- ^ Partition index
  -> RecordBatch -- ^ Records
  -> Request
singleton !acks !timeoutMs !topicName !partitionIx records = Request
  { transactionalId=Nothing
  , acks=acks
  , timeoutMilliseconds=timeoutMs
  , topicData=C.singleton $ Topic
    { name=topicName
    , partitions=C.singleton $ Partition
      { index=partitionIx
      , records=records
      }
    }
  }
       
  

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
