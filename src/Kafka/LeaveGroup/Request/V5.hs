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

module Kafka.LeaveGroup.Request.V5
  ( Request(..)
  , Member(..)
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

-- | Kafka Leave Group request V5.
data Request = Request
  { groupId :: !Text
  , members :: !(SmallArray Member)
  }

data Member = Member
  { memberId :: !Text
  , groupInstanceId :: !(Maybe Text)
  , reason :: !Text
  }

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode Request{groupId,members} =
  Builder.compactString groupId
  <>
  Builder.compactArray encodeMember members
  <>
  Builder.word8 0

encodeMember :: Member -> Builder
encodeMember Member{memberId,groupInstanceId,reason} =
  Builder.compactString memberId
  <>
  Builder.compactNullableString groupInstanceId
  <>
  Builder.compactString reason
  <>
  Builder.word8 0
