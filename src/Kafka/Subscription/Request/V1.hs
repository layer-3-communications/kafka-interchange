{-# language BangPatterns #-}
{-# language NamedFieldPuns #-}
{-# language DataKinds #-}
{-# language DeriveFunctor #-}
{-# language DerivingStrategies #-}
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

module Kafka.Subscription.Request.V1
  ( Subscription(..)
  , Ownership(..)
  , encodeOwnership
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Int (Int16,Int32,Int64)
import Data.Text (Text)
import Data.Bytes (Bytes)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.WideWord (Word128)
import Data.Primitive (SmallArray,PrimArray)

import qualified Kafka.Builder as Builder

-- | Kafka Init Producer ID request V4.
data Subscription = Subscription
  { topics :: !(SmallArray Text)
  , userData :: !Bytes
  , ownedPartitions :: !(SmallArray Ownership)
  } deriving stock (Show)

data Ownership = Ownership
  { topic :: !Text
  , partitions :: !(PrimArray Int32)
  } deriving stock (Show)

-- | Serializes the version number at the beginning.
toChunks :: Subscription -> Chunks
toChunks = Builder.run 128 . encode

encode :: Subscription -> Builder
encode Subscription{topics,userData,ownedPartitions} =
  Builder.int16 1
  <>
  Builder.array Builder.string topics
  <>
  Builder.nonCompactBytes userData
  <>
  Builder.array encodeOwnership ownedPartitions

encodeOwnership :: Ownership -> Builder
encodeOwnership Ownership{topic,partitions} =
  Builder.string topic
  <>
  Builder.int32Array partitions

