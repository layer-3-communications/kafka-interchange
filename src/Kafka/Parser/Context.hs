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
  | AuthorizedOperations
  | BaseOffset
  | Brokers
  | ClusterId
  | ControllerId
  | CorrelationId
  | ErrorCode
  | ErrorMessage
  | Errors
  | Host
  | Id
  | Internal
  | IsrNodes
  | Ix
  | LeaderEpoch
  | LeaderId
  | LogAppendTimeMilliseconds
  | LogStartOffset
  | MaxVersion
  | Message
  | MinVersion
  | Name
  | NodeId
  | OfflineReplicas
  | Partitions
  | Port
  | ProducerEpoch
  | ProducerId
  | Rack
  | ReplicaNodes
  | TagBuffer
  | TaggedFieldContents
  | TaggedFieldLength
  | TaggedFieldTag
  | ThrottleTimeMilliseconds
  | Topics
  deriving (Show)
