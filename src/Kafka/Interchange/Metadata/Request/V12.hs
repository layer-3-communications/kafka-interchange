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

module Kafka.Interchange.Metadata.Request.V12
  ( Request(..)
  , Topic(..)
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Int (Int16)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.WideWord (Word128)
import Data.Primitive (SmallArray)

import qualified Kafka.Builder as Builder

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
