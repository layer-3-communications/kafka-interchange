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
  | CorrelationId
  | ErrorCode
  | ErrorMessage
  | Errors
  | Id
  | Ix
  | LogAppendTimeMilliseconds
  | LogStartOffset
  | MaxVersion
  | Message
  | MinVersion
  | Name
  | NodeId
  | Partitions
  | TagBuffer
  | TaggedFieldContents
  | TaggedFieldLength
  | TaggedFieldTag
  | ThrottleTimeMilliseconds
  | IsrNodes
  | ReplicaNodes
  | OfflineReplicas
  | Internal
  | AuthorizedOperations
  | LeaderId
  | LeaderEpoch
  | Topics
  | Host
  | Port
  | ControllerId
  | Brokers
  | ClusterId
  | Rack
  deriving (Show)
