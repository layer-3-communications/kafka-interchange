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
  ) where

import Prelude hiding (id)

import Data.Int (Int16,Int32,Int64)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.WideWord (Word128)
import Data.Primitive (SmallArray)

import qualified Kafka.Builder as Builder

-- | Kafka Init Producer ID request V4.
data Request = Request
  { transactionalId :: !(Maybe Text)
  , transactionTimeoutMilliseconds :: !Int32
  , producerId :: !Int64
  , producerEpoch :: !Int16
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
