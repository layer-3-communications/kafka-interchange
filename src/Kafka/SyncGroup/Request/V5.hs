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

module Kafka.SyncGroup.Request.V5
  ( Request(..)
  , Assignment(..)
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Int (Int32)
import Data.Bytes (Bytes)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.Primitive (SmallArray)

import qualified Kafka.Builder as Builder

-- | Kafka Sync Group request V5.
data Request = Request
  { groupId :: !Text
    -- ^ The group identifier
  , generationId :: !Int32
  , memberId :: !Text
  , groupInstanceId :: !(Maybe Text)
    -- ^ Group instance id. See KIP-345. Null means that static membership
    -- is disabled.
  , protocolType :: !Text
    -- ^ Almost always the string @consumer@.
  , protocolName :: !Text
  , assignments :: !(SmallArray Assignment)
  }

data Assignment = Assignment
  { memberId :: {-# UNPACK #-} !Text
  , assignment :: {-# UNPACK #-} !Bytes
  } 

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode r =
     Builder.compactString r.groupId
  <> Builder.int32 r.generationId
  <> Builder.compactString r.memberId
  <> Builder.compactNullableString r.groupInstanceId
  <> Builder.compactString r.protocolType
  <> Builder.compactString r.protocolName
  <> Builder.compactArray encodeAssignment r.assignments
  <> Builder.word8 0 -- zero tagged fields

encodeAssignment :: Assignment -> Builder
encodeAssignment r =
     Builder.compactString r.memberId
  <> Builder.compactBytes r.assignment
  <> Builder.word8 0 -- zero tagged fields
