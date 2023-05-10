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

module Kafka.Interchange.JoinGroup.Request.V9
  ( Request(..)
  , Protocol(..)
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Int (Int16,Int32)
import Data.Bytes (Bytes)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.WideWord (Word128)
import Data.Primitive (SmallArray)

import qualified Kafka.Builder as Builder

-- | Kafka API Versions request V3.
data Request = Request
  { groupId :: !Text
    -- ^ The group identifier
  , sessionTimeoutMilliseconds :: !Int32
  , rebalanceTimeoutMilliseconds :: !Int32
  , memberId :: !Text
  , groupInstanceId :: !(Maybe Text)
    -- ^ Group instance id. See KIP-345. Null means that this static membership
    -- is disabled. The empty string (known as UNKNOWN_MEMBER_ID) means that
    -- the broker picks a group instance id returns it.
  , protocolType :: !Text
    -- ^ Almost always the string @consumer@.
  , protocols :: !(SmallArray Protocol)
  , reason :: !Text
    -- ^ We do not allow null.
  }

data Protocol = Protocol
  { name :: {-# UNPACK #-} !Text
  , metadata :: {-# UNPACK #-} !Bytes
  } 

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode r =
     Builder.compactString r.groupId
  <> Builder.int32 r.sessionTimeoutMilliseconds
  <> Builder.int32 r.rebalanceTimeoutMilliseconds
  <> Builder.compactString r.memberId
  <> Builder.compactNullableString r.groupInstanceId
  <> Builder.compactString r.protocolType
  <> Builder.compactArray encodeProtocol r.protocols
  <> Builder.compactString r.reason
  <> Builder.word8 0 -- zero tagged fields

encodeProtocol :: Protocol -> Builder
encodeProtocol Protocol{name,metadata} =
     Builder.compactString name
  <> Builder.compactBytes metadata
  <> Builder.word8 0 -- zero tagged fields

