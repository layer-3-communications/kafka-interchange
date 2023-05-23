{-# language DataKinds #-}
{-# language NamedFieldPuns #-}
{-# language TypeApplications #-}

module Kafka.Builder.Bounded
  ( int16
  , int32
  , int64
  , word16
  , word32
  , varIntNative
  , apiKey
    -- * Re-exports
  , Builder
  , append
  , word8
  , run
  ) where

import Data.Int (Int8,Int16,Int32,Int64)
import Data.Word (Word16,Word32)
import Data.Bytes.Builder.Bounded (Builder,append,word8,run)
import Data.Word.Zigzag (toZigzagNative)
import Kafka.ApiKey (ApiKey(ApiKey))
import qualified Data.Bytes.Builder.Bounded as Bounded

int64 :: Int64 -> Builder 8
int64 = Bounded.int64BE

int32 :: Int32 -> Builder 4
int32 = Bounded.int32BE

word32 :: Word32 -> Builder 4
word32 = Bounded.word32BE

int16 :: Int16 -> Builder 2
int16 = Bounded.int16BE

apiKey :: ApiKey -> Builder 2
apiKey (ApiKey k) = Bounded.int16BE k

word16 :: Word16 -> Builder 2
word16 = Bounded.word16BE

varIntNative :: Int -> Builder 10
{-# inline varIntNative #-}
varIntNative = Bounded.wordLEB128 . toZigzagNative

