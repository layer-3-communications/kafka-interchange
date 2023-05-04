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

module Kafka.Interchange.FindCoordinator.Request.V4
  ( Request(..)
  , toChunks
  ) where

import Prelude hiding (id)

import Data.Primitive (SmallArray)
import Data.Int (Int8)
import Data.Text (Text)
import Data.Bytes.Builder (Builder)
import Data.Bytes.Chunks (Chunks)

import qualified Kafka.Builder as Builder

-- | Kafka API Versions request V3.
data Request = Request
  { keyType :: !Int8
  , coordinatorKeys :: !(SmallArray Text)
  }

toChunks :: Request -> Chunks
toChunks = Builder.run 128 . encode

encode :: Request -> Builder
encode Request{keyType,coordinatorKeys} =
  Builder.int8 keyType
  <>
  Builder.compactArray Builder.compactString coordinatorKeys
  <>
  Builder.word8 0 -- zero tagged fields
