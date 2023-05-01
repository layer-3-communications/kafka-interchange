{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Interchange.Metadata.Response.V12
  ( Response(..)
  , parser
  , decode
  ) where

import Prelude hiding (id)

import Data.WideWord (Word128)
import Data.Primitive (SmallArray,PrimArray)
import Data.Int (Int16,Int32)
import Data.Word (Word32)
import Kafka.Parser.Context (Context)
import Data.Text (Text)
import Data.Bytes.Parser (Parser)
import Data.Bytes (Bytes)
import Kafka.Data.TaggedField (TaggedField)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Data.TaggedField as TaggedField
import qualified Kafka.Parser

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , brokers :: !(SmallArray Broker)
  , clusterId :: !Text
  , controllerId :: !Int32
  , topics :: !(SmallArray Topic)
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Broker = Broker
  { nodeId :: !Int32
  , host :: !Text
  , port :: !Int32
  , rack :: !Text
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Topic = Topic
  { errorCode :: !Int16
  , name :: !Text
  , id :: {-# UNPACK #-} !Word128
  , internal :: !Bool
  , partitions :: !(SmallArray Partition)
  , authorizedOperations :: !Word32
    -- ^ Authorized Operations: a bitfield. The spec has this as a
    -- signed integral type, but that was probably only done because
    -- of limitations with Java.
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Partition = Partition
  { errorCode :: !Int16
  , index :: !Int32
  , leaderId :: !Int32
  , leaderEpoch :: !Int32
  , replicaNodes :: !(PrimArray Int32)
  , isrNodes :: !(PrimArray Int32)
  , offlineReplicas :: !(PrimArray Int32)
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Error = Error
  { index :: !Int32
  , message :: !Text
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving stock (Show)

decode :: Bytes -> Either Context Response
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.End) b

parser :: Context -> Parser Context s Response
parser ctx = do
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  brokers <- Kafka.Parser.compactArray parserBroker (Ctx.Field Ctx.Brokers ctx)
  clusterId <- Kafka.Parser.compactString (Ctx.Field Ctx.ClusterId ctx)
  controllerId <- Kafka.Parser.int32 (Ctx.Field Ctx.ControllerId ctx)
  topics <- Kafka.Parser.compactArray parserTopic (Ctx.Field Ctx.Topics ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,brokers,clusterId,controllerId,topics,tagBuffer}

parserBroker :: Context -> Parser Context s Broker
parserBroker ctx = do
  nodeId <- Kafka.Parser.int32 (Ctx.Field Ctx.NodeId ctx)
  host <- Kafka.Parser.compactString (Ctx.Field Ctx.Host ctx)
  port <- Kafka.Parser.int32 (Ctx.Field Ctx.Port ctx)
  rack <- Kafka.Parser.compactString (Ctx.Field Ctx.Rack ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Broker{nodeId,host,port,rack,tagBuffer}

parserTopic :: Context -> Parser Context s Topic
parserTopic ctx = do
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  name <- Kafka.Parser.compactString (Ctx.Field Ctx.Name ctx)
  id <- Kafka.Parser.word128 (Ctx.Field Ctx.Id ctx)
  internal <- Kafka.Parser.boolean (Ctx.Field Ctx.Internal ctx)
  partitions <- Kafka.Parser.compactArray parserPartition
    (Ctx.Field Ctx.Partitions ctx)
  authorizedOperations <- Kafka.Parser.word32 (Ctx.Field Ctx.AuthorizedOperations ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Topic{errorCode,name,id,internal,partitions,authorizedOperations,tagBuffer}

parserPartition :: Context -> Parser Context s Partition
parserPartition ctx = do
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  index <- Kafka.Parser.int32 (Ctx.Field Ctx.Ix ctx)
  leaderId <- Kafka.Parser.int32 (Ctx.Field Ctx.LeaderId ctx)
  leaderEpoch <- Kafka.Parser.int32 (Ctx.Field Ctx.LeaderEpoch ctx)
  replicaNodes <- Kafka.Parser.compactInt32Array (Ctx.Field Ctx.ReplicaNodes ctx)
  isrNodes <- Kafka.Parser.compactInt32Array (Ctx.Field Ctx.IsrNodes ctx)
  offlineReplicas <- Kafka.Parser.compactInt32Array (Ctx.Field Ctx.OfflineReplicas ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Partition
    { errorCode
    , index
    , leaderId
    , leaderEpoch
    , replicaNodes
    , isrNodes
    , offlineReplicas
    , tagBuffer
    }
