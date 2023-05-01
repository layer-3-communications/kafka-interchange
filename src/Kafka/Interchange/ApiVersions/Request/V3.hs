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

module Kafka.Interchange.ApiVersions.Request.V3
  ( Request(..)
  , toChunks
  , apiVersion
  ) where

import Data.Int (Int16)
import Data.Text (Text)
import Data.Bytes.Chunks (Chunks)

import qualified Kafka.Builder as Builder

apiVersion :: Int16
apiVersion = 3

-- | Kafka API Versions request V3.
data Request = Request
  { clientSoftwareName :: !Text
  , clientSoftwareVersion :: !Text
  }

toChunks :: Request -> Chunks
toChunks Request{clientSoftwareName,clientSoftwareVersion} =
  Builder.run 128 $
    Builder.compactString clientSoftwareName
    <>
    Builder.compactString clientSoftwareVersion
    <>
    Builder.word8 0 -- tag buffer with zero entries 
