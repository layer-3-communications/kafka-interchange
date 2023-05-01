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
  , apiVersion
  ) where

import Prelude hiding (id)

import Data.Int (Int16)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.WideWord (Word128)
import Data.Primitive (SmallArray)

import qualified Kafka.Builder as Builder

apiVersion :: Int16
apiVersion = 12

-- | Kafka API Versions request V3.
data Request = Request
  { topics :: !(SmallArray Topic)
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
  Builder.compactArray encodeTopic topics
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
