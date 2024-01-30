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

module Kafka.InitProducerId.Request.V4
  ( Request(..)
  , toChunks
    -- * Construction
  , request
  ) where

import Prelude hiding (id)

import Data.Int (Int16,Int32,Int64)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.WideWord (Word128)
import Data.Primitive (SmallArray)

import qualified Kafka.Builder as Builder

-- | An empty request. Everything in this request is set to something that
-- means "this is not being provided to the broker". This is the most common
-- value of this type to use. Note that transactionTimeoutMilliseconds is set
-- to 2147483647 because this is what the kafka-console-producer does.
request :: Request
request = Request
  { transactionalId = Nothing
  , transactionTimeoutMilliseconds = 2147483647
  , producerId = (-1)
  , producerEpoch = (-1)
  }

-- | Kafka Init Producer ID request V4.
data Request = Request
  { transactionalId :: !(Maybe Text)
    -- ^ The transactional id, or null if the producer is not transactional.
  , transactionTimeoutMilliseconds :: !Int32
    -- ^ The time in ms to wait before aborting idle transactions sent by this producer.
    -- This is only relevant if a TransactionalId has been defined.
  , producerId :: !Int64
    -- ^ The producer id. This is used to disambiguate requests if a transactional id
    -- is reused following its expiration. Typically, this should be set to -1.
  , producerEpoch :: !Int16
    -- ^ The producer's current epoch. This will be checked against the producer epoch
    -- on the broker, and the request will return an error if they do not match.
    -- Setting this to -1 disables this check, which is typically what you want.
  }

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode Request{transactionalId,transactionTimeoutMilliseconds,producerId,producerEpoch} =
  Builder.compactNullableString transactionalId
  <>
  Builder.int32 transactionTimeoutMilliseconds
  <>
  Builder.int64 producerId
  <>
  Builder.int16 producerEpoch
  <>
  Builder.word8 0
