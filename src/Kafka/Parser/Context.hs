module Kafka.Parser.Context
  ( Context(..)
  , Field(..)
  ) where

data Context
  = Top
  | Field Field !Context
  | Index !Int !Context
  | End -- Signifies that end-of-input was expected
  deriving (Show)

-- | This exists so that we can get better error messages when decoding fails.
data Field
  = ApiKey
  | ApiKeys
  | BaseOffset
  | ErrorCode
  | ErrorMessage
  | Errors
  | Ix
  | LogAppendTimeMilliseconds
  | LogStartOffset
  | MaxVersion
  | Message
  | MinVersion
  | Name
  | Partitions
  | TagBuffer
  | TaggedFieldContents
  | TaggedFieldLength
  | TaggedFieldTag
  | ThrottleTimeMilliseconds
  deriving (Show)
