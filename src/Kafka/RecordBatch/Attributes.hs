{-# language BangPatterns #-}
{-# language BinaryLiterals #-}
{-# language DerivingStrategies #-}
{-# language NumericUnderscores #-}

module Kafka.RecordBatch.Attributes
  ( -- * Types
    Compression(..)
  , TimestampType(..)
    -- * Getters
  , getCompression
  , getTimestampType
  ) where

import Data.Word (Word16)
import Data.Bits ((.&.),testBit)

data Compression
  = None
  | Gzip
  | Snappy
  | Lz4
  deriving stock (Eq,Show)

data TimestampType
  = CreateTime
  | LogAppendTime
  deriving stock (Eq,Show)

getCompression :: Word16 -> Compression
getCompression !w = case w .&. 0b0000_0000_0000_0011 of
  0 -> None
  1 -> Gzip
  2 -> Snappy
  _ -> Lz4

getTimestampType :: Word16 -> TimestampType
getTimestampType !w = if testBit w 2
  then LogAppendTime
  else CreateTime
