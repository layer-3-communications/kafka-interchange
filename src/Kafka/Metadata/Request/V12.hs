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

module Kafka.Metadata.Request.V12
  ( Request(..)
  , Topic(..)
  , toChunks
    -- * Request Construction
  , all
  , none
  ) where

import Prelude hiding (id,all)

import Data.Int (Int16)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.WideWord (Word128)
import Data.Primitive (SmallArray)

import qualified Kafka.Builder as Builder

-- | A request for all topics. Authorized operations are
-- not requested.
all :: Request
all = Request
  { topics = Nothing
  , allowAutoTopicCreation = False
  , includeTopicAuthorizedOperations = False
  }

-- | A request for no topics. Authorized operations are
-- not requested. This is useful in situations where a user
-- wants to discover what brokers are in the cluster but does
-- not care about the topics.
none :: Request
none = Request
  { topics = Just mempty
  , allowAutoTopicCreation = False
  , includeTopicAuthorizedOperations = False
  }

-- | Kafka API Versions request V3.
data Request = Request
  { topics :: !(Maybe (SmallArray Topic))
    -- ^ Null means "all topics", and the empty array means "no topics".
  , allowAutoTopicCreation :: !Bool
  , includeTopicAuthorizedOperations :: !Bool
  }

data Topic = Topic
  { id :: {-# UNPACK #-} !Word128
  , name :: !(Maybe Text)
  } 

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode Request{topics,allowAutoTopicCreation,includeTopicAuthorizedOperations} =
  Builder.compactNullableArray encodeTopic topics
  <>
  Builder.boolean allowAutoTopicCreation
  <>
  Builder.boolean includeTopicAuthorizedOperations
  <>
  Builder.word8 0 -- zero tagged fields

encodeTopic :: Topic -> Builder
encodeTopic Topic{id,name} =
  Builder.word128 id
  <>
  Builder.compactNullableString name
  <>
  Builder.word8 0 -- zero tagged fields
