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

module Kafka.Assignment.Request.V1
  ( Assignment(..)
  , Ownership(..)
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Int (Int16,Int32,Int64)
import Data.Text (Text)
import Data.Bytes (Bytes)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.Primitive (SmallArray)
import Kafka.Subscription.Request.V1 (Ownership(..),encodeOwnership)

import qualified Kafka.Builder as Builder

-- | Kafka consumer protocol assignment v1.
data Assignment = Assignment
  { assignedPartitions :: !(SmallArray Ownership)
  , userData :: !Bytes
  } deriving stock (Show)

-- | Serializes the version number at the beginning.
toChunks :: Assignment -> Chunks
toChunks = Builder.run 128 . encode

encode :: Assignment -> Builder
encode Assignment{assignedPartitions,userData} =
  Builder.int16 1
  <>
  Builder.array encodeOwnership assignedPartitions
  <>
  Builder.nonCompactBytes userData
