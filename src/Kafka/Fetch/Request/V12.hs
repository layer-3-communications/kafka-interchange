{-# language BangPatterns #-}
{-# language NamedFieldPuns #-}
{-# language DataKinds #-}
{-# language DeriveFunctor #-}
{-# language DuplicateRecordFields #-}
{-# language FlexibleContexts #-}
{-# language GeneralizedNewtypeDeriving #-}
{-# language MultiParamTypeClasses #-}
{-# language OverloadedRecordDot #-}
{-# language OverloadedStrings #-}
{-# language PolyKinds #-}
{-# language RankNTypes #-}
{-# language TypeFamilies #-}
{-# language UnboxedTuples #-}
{-# language UndecidableInstances #-}

module Kafka.Fetch.Request.V12
  ( Request(..)
  , Topic(..)
  , Partition(..)
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.Int (Int8,Int32,Int64)
import Data.Primitive (SmallArray)
import Data.Text (Text)
import Data.WideWord (Word128)

import qualified Kafka.Builder as Builder

-- | Kafka Fetch request V12. Note: the forgotten topics array
-- is not implemented. Currently, we always encode this as a
-- zero-length array.
data Request = Request
  { replicaId :: !Int32
  , maxWaitMilliseconds :: !Int32
  , minBytes :: !Int32
  , maxBytes :: !Int32
  , isolationLevel :: !Int8
  , sessionId :: !Int32
    -- ^ Setting session ID to 0 means that we are requesting that the
    -- broker create a new session. The broker will return a randomly
    -- generated session ID in the response. A request with a session ID
    -- of -1 indicates that we do not want to use a fetch session at all.
  , sessionEpoch :: !Int32
  , topics :: !(SmallArray Topic)
  , rackId :: !Text
    -- ^ Rack ID of the consumer. Often the empty string.
  }

data Topic = Topic
  { name :: !Text
  , partitions :: !(SmallArray Partition)
  } 

data Partition = Partition
  { index :: !Int32
  , currentLeaderEpoch :: !Int32
  , fetchOffset :: !Int64
  , lastFetchedEpoch :: !Int32
    -- ^ The epoch of the last fetched record or -1 if there is none.
  , logStartOffset :: !Int64
    -- ^ Set this to -1. According to Kafka docs: "The earliest available
    -- offset of the follower replica. The field is only used when the request
    -- is sent by the follower."
  , maxBytes :: !Int32
  } 

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode r =
     Builder.int32 r.replicaId
  <> Builder.int32 r.maxWaitMilliseconds
  <> Builder.int32 r.minBytes
  <> Builder.int32 r.maxBytes
  <> Builder.int8 r.isolationLevel
  <> Builder.int32 r.sessionId
  <> Builder.int32 r.sessionEpoch
  <> Builder.compactArray encodeTopic r.topics
  <> Builder.word8 0x01 -- no forgotten topics
  <> Builder.compactString r.rackId
  <> Builder.word8 0 -- zero tagged fields

encodeTopic :: Topic -> Builder
encodeTopic r =
     Builder.compactString r.name
  <> Builder.compactArray encodePartition r.partitions
  <> Builder.word8 0 -- zero tagged fields

encodePartition :: Partition -> Builder
encodePartition r =
     Builder.int32 r.index
  <> Builder.int32 r.currentLeaderEpoch
  <> Builder.int64 r.fetchOffset
  <> Builder.int32 r.lastFetchedEpoch
  <> Builder.int64 r.logStartOffset
  <> Builder.int32 r.maxBytes
  <> Builder.word8 0 -- zero tagged fields
