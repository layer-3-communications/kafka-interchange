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

module Kafka.Heartbeat.Request.V4
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
  { groupId :: !Text
  , generationId :: !Int32
  , memberId :: !Text
  , groupInstanceId :: !(Maybe Text)
  }

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode Request{groupId,generationId,memberId,groupInstanceId} =
  Builder.compactString groupId
  <>
  Builder.int32 generationId
  <>
  Builder.compactString memberId
  <>
  Builder.compactNullableString groupInstanceId
  <>
  Builder.word8 0
