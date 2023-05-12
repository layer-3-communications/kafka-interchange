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

module Kafka.ListOffsets.Request.V7
  ( Request(..)
  , Topic(..)
  , Partition(..)
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Primitive (SmallArray)
import Data.Int (Int8,Int32,Int64)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)

import qualified Kafka.Builder as Builder

-- | Kafka List Offsets request V7.
data Request = Request
  { replicaId :: !Int32
  , isolationLevel :: !Int8
  , topics :: !(SmallArray Topic)
  }

data Topic = Topic
  { name :: !Text
  , partitions :: !(SmallArray Partition)
  }

data Partition = Partition
  { index :: !Int32
  , currentLeaderEpoch :: !Int32
  , timestamp :: !Int64
  }

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode Request{replicaId,isolationLevel,topics} =
  Builder.int32 replicaId
  <>
  Builder.int8 isolationLevel
  <>
  Builder.compactArray encodeTopic topics
  <>
  Builder.word8 0 -- zero tagged fields

encodeTopic :: Topic -> Builder
encodeTopic Topic{name,partitions} =
  Builder.compactString name
  <>
  Builder.compactArray encodePartition partitions
  <>
  Builder.word8 0 -- zero tagged fields

encodePartition :: Partition -> Builder
encodePartition Partition{index,currentLeaderEpoch,timestamp} =
  Builder.int32 index
  <>
  Builder.int32 currentLeaderEpoch
  <>
  Builder.int64 timestamp
  <>
  Builder.word8 0 -- zero tagged fields
