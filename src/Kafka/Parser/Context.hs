{-# language BangPatterns #-}
{-# language LambdaCase #-}

-- Note: This actually gets used in more places than the
-- parser. Should probably get rid of End.
module Kafka.Parser.Context
  ( Context(..)
  , ContextualizedErrorCode(..)
  , Field(..)
  , encodeContextString
  ) where

import Kafka.ErrorCode (ErrorCode)

data ContextualizedErrorCode = ContextualizedErrorCode
  { context :: !Context
  , errorCode :: !ErrorCode
  }

encodeContextString :: Context -> String
encodeContextString = \case
  Top -> ""
  End -> "!"
  Index !ix c -> encodeContextString c ++ "." ++ show ix
  Field f c -> encodeContextString c ++ "." ++ show f

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
      !Int -- number of bytes that were available
      !Int -- number of bytes that were needed
  | Brokers
  | ClusterId
  | CommittedLeaderEpoch
  | CommittedOffset
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
  | Groups
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
