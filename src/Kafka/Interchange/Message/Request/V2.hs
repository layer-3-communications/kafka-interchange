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

module Kafka.Interchange.Message.Request.V2
  ( Request(..)
  , Header(..)
  , toChunks
  ) where

import Data.Int
import Data.Text (Text)
import Data.Bytes.Chunks (Chunks(ChunksCons))
import Kafka.Builder (Builder)

import qualified Kafka.Builder as Builder
import qualified Kafka.Builder.Bounded as Bounded
import qualified Data.Bytes.Chunks as Chunks
import qualified Arithmetic.Nat as Nat
import qualified Data.Bytes.Encode.BigEndian as Encode.BigEndian

data Header = Header
  { apiKey :: !Int16
  , apiVersion :: !Int16
  , correlationId :: !Int32
  , clientId :: !(Maybe Text)
  }

-- | A Kafka request. This data type does not enforce the agreement of
-- the @apiKey@ and the serialized @body@. That resposibility is left
-- to the user.
data Request = Request
  { header :: !Header
  , body :: !Chunks
    -- ^ Pre-encoded body
  }

toChunks :: Request -> Chunks
toChunks Request{header,body} =
  let payload = Builder.runOnto 64 (builderHeader header) body
      len = Chunks.length payload
   in ChunksCons (Encode.BigEndian.word32 (fromIntegral len)) payload

builderHeader :: Header -> Builder
builderHeader Header{apiKey,apiVersion,correlationId,clientId} =
  Builder.fromBounded Nat.constant
    ( Bounded.int16 apiKey
      `Bounded.append`
      Bounded.int16 apiVersion
      `Bounded.append`
      Bounded.int32 correlationId
    )
  <>
  Builder.nullableString clientId
  <>
  -- Zero tagged fields. There are currently no tagged fields that
  -- can appear in the header, so we do not bother allowing the user
  -- to set these.
  Builder.word8 0
