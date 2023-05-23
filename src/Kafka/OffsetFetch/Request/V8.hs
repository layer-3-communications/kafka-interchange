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

module Kafka.OffsetFetch.Request.V8
  ( Request(..)
  , Group(..)
  , Topic(..)
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Int (Int32)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)
import Data.Primitive (SmallArray,PrimArray)

import qualified Kafka.Builder as Builder

-- | Kafka API Versions request V3.
data Request = Request
  { groups :: !(SmallArray Group)
  , requireStable :: !Bool
  }

data Group = Group
  { id :: !Text
  , topics :: !(SmallArray Topic)
  }

data Topic = Topic
  { name :: !Text
  , partitions :: !(PrimArray Int32)
  } 

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode Request{groups,requireStable} =
  Builder.compactArray encodeGroup groups
  <>
  Builder.boolean requireStable
  <>
  Builder.word8 0 -- zero tagged fields

encodeGroup :: Group -> Builder
encodeGroup Group{id,topics} =
  Builder.compactString id
  <>
  Builder.compactArray encodeTopic topics
  <>
  Builder.word8 0 -- zero tagged fields

encodeTopic :: Topic -> Builder
encodeTopic Topic{name,partitions} =
  Builder.compactString name
  <>
  Builder.compactInt32Array partitions
  <>
  Builder.word8 0 -- zero tagged fields

