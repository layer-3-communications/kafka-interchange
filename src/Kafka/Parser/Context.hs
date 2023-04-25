module Kafka.Parser.Context
  ( Context(..)
  , Field(..)
  ) where

data Context
  = Top
  | Field Field !Context
  | Index !Int !Context
  deriving (Show)

-- | This exists so that we can get better error messages when decoding fails.
data Field
  = ErrorCode
  | ApiKey
  | ApiKeys
  | ThrottleTimeMilliseconds
  | TaggedFieldTag
  | TaggedFieldLength
  | TaggedFieldContents
  | MinVersion
  | MaxVersion
  | TagBuffer
  deriving (Show)
