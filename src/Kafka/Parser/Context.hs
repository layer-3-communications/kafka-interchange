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
  = AbortedTransactions
  | ApiKey
  | ApiKeys
  | AssignedPartitions
  | Assignment
  | Attributes
  | AuthorizedOperations
  | BaseOffset
  | BaseSequence
  | BaseTimestamp
  | BatchLength
  | BatchLengthLeftoverBytes
  | BatchLengthNegative
  | BatchLengthNotEnoughBytes
  | Brokers
  | ClusterId
  | ControllerId
  | Coordinators
  | CorrelationId
  | Crc
  | CrcMismatch
  | ErrorCode
  | ErrorMessage
  | Errors
  | GenerationId
  | GroupInstanceId
  | HighWatermark
  | Host
  | Id
  | Internal
  | IsrNodes
  | Ix
  | Key
  | LastOffsetDelta
  | LastStableOffset
  | Leader
  | LeaderEpoch
  | LeaderId
  | LogAppendTimeMilliseconds
  | LogStartOffset
  | Magic
  | MaxTimestamp
  | MaxVersion
  | MemberId
  | Members
  | Message
  | Metadata
  | MinVersion
  | Name
  | NodeId
  | OfflineReplicas
  | Offset
  | OwnedPartitions
  | PartitionLeaderEpoch
  | Partitions
  | Port
  | PreferredReadReplica
  | ProducerEpoch
  | ProducerId
  | ProtocolName
  | ProtocolType
  | Rack
  | RecordBatch
  | RecordBatchLeftoverBytes
  | RecordBatchLength
  | RecordBatchNotEnoughBytes
  | RecordsCount
  | ReplicaNodes
  | SessionId
  | SkipAssignment
  | TagBuffer
  | TaggedFieldContents
  | TaggedFieldLength
  | TaggedFieldTag
  | ThrottleTimeMilliseconds
  | Timestamp
  | Topic
  | Topics
  | UserData
  | Version
  deriving (Show)
