{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}
{-# language ScopedTypeVariables #-}
{-# language TypeApplications #-}
{-# language OverloadedRecordDot #-}

module Kafka.Metadata.Response.V12
  ( Response(..)
  , Broker(..)
  , Topic(..)
  , Partition(..)
  , Error(..)
  , parser
  , decode
  , decodeHeaded
    -- * Predicates
  , hasErrorCode
  , findErrorCode
  ) where

import Prelude hiding (id)

import Control.Applicative (liftA2)
import Data.Bytes (Bytes)
import Data.Bytes.Parser (Parser)
import Data.Int (Int16,Int32)
import Data.Primitive (SmallArray,PrimArray)
import Data.Text (Text)
import Data.WideWord (Word128)
import Data.Word (Word32,Word16)
import Kafka.ErrorCode (ErrorCode)
import Kafka.Parser.Context (Context(Top,Field,Index))
import Kafka.Parser.Context (ContextualizedErrorCode(..))
import Kafka.TaggedField (TaggedField)
import Data.Monoid (Any(Any),getAny)

import qualified Data.Bytes.Parser as Parser
import qualified Data.Primitive as PM
import qualified Kafka.ErrorCode as ErrorCode
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser
import qualified Kafka.Header.Response.V1 as Header

-- | Search through all topics and partitions for any error codes
-- that are not set to @NONE@.
hasErrorCode :: Response -> Bool
hasErrorCode Response{topics} = getAny $ foldMap
  (\t -> Any (t.errorCode /= ErrorCode.None) <> foldMap
    (\p -> Any (p.errorCode /= ErrorCode.None)
    ) t.partitions
  ) topics

-- | Find the first error code of any kind in the response.
-- This looks for topic-level error codes first and then
-- moves on searching for partition-level error codes.
findErrorCode :: Response -> Maybe ContextualizedErrorCode
findErrorCode Response{topics}
  | c@Just{} <- goTopic 0 = c
  | c@Just{} <- goPartitionOuter 0 = c
  | otherwise = Nothing
  where
  ctxTopics = Field Ctx.Topics Top
  goTopic :: Int -> Maybe ContextualizedErrorCode
  goTopic !ix = if ix < PM.sizeofSmallArray topics
    then
      let t = PM.indexSmallArray topics ix
       in case t.errorCode of
            ErrorCode.None -> goTopic (ix + 1)
            e -> Just (ContextualizedErrorCode (Index ix ctxTopics) e)
    else Nothing
  goPartitionOuter :: Int -> Maybe ContextualizedErrorCode
  goPartitionOuter !ix = if ix < PM.sizeofSmallArray topics
    then
      let t = PM.indexSmallArray topics ix
          ps = t.partitions
          goPartitionInner !j = if j < PM.sizeofSmallArray ps
            then
              let p = PM.indexSmallArray ps j
               in case p.errorCode of
                    ErrorCode.None -> goPartitionInner (j + 1)
                    e -> Just (ContextualizedErrorCode (Index j (Field Ctx.Partitions (Index ix ctxTopics))) e)
            else Nothing
       in case goPartitionInner 0 of
            Nothing -> goPartitionOuter (ix + 1)
            x@Just{} -> x
    else Nothing

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , brokers :: !(SmallArray Broker)
  , clusterId :: !Text
  , controllerId :: !Int32
  , topics :: !(SmallArray Topic)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Broker = Broker
  { nodeId :: !Int32
  , host :: !Text
  , port :: !Word16
    -- ^ Even though Kafka has this as a 32-bit signed integer,
    -- I believe that it should only ever be a 16-bit unsigned
    -- integer.
  , rack :: !Text
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Topic = Topic
  { errorCode :: !ErrorCode
  , name :: !Text
  , id :: {-# UNPACK #-} !Word128
  , internal :: !Bool
  , partitions :: !(SmallArray Partition)
  , authorizedOperations :: !Word32
    -- ^ Authorized Operations: a bitfield. The spec has this as a
    -- signed integral type, but that was probably only done because
    -- of limitations with Java.
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Partition = Partition
  { errorCode :: !ErrorCode
  , index :: !Int32
  , leaderId :: !Int32
  , leaderEpoch :: !Int32
  , replicaNodes :: !(PrimArray Int32)
  , isrNodes :: !(PrimArray Int32)
  , offlineReplicas :: !(PrimArray Int32)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Error = Error
  { index :: !Int32
  , message :: !Text
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

decodeHeaded :: Bytes -> Either Context (Header.Headed Response)
decodeHeaded !b = Parser.parseBytesEither
  (liftA2 Header.Headed
    (Header.parser Ctx.Top)
    (parser Ctx.Top <* Parser.endOfInput Ctx.End)
  ) b

decode :: Bytes -> Either Context Response
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.End) b

parser :: Context -> Parser Context s Response
parser ctx = do
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  brokers <- Kafka.Parser.compactArray parserBroker (Ctx.Field Ctx.Brokers ctx)
  clusterId <- Kafka.Parser.compactString (Ctx.Field Ctx.ClusterId ctx)
  controllerId <- Kafka.Parser.int32 (Ctx.Field Ctx.ControllerId ctx)
  topics <- Kafka.Parser.compactArray parserTopic (Ctx.Field Ctx.Topics ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,brokers,clusterId,controllerId,topics,taggedFields}

parserBroker :: Context -> Parser Context s Broker
parserBroker ctx = do
  nodeId <- Kafka.Parser.int32 (Ctx.Field Ctx.NodeId ctx)
  host <- Kafka.Parser.compactString (Ctx.Field Ctx.Host ctx)
  port32 <- Kafka.Parser.int32 (Ctx.Field Ctx.Port ctx)
  port :: Word16 <- if port32 < 0 || port32 > 65535
    then Kafka.Parser.fail (Ctx.Field Ctx.Port ctx)
    else pure $! fromIntegral @Int32 @Word16 port32
  rack <- Kafka.Parser.compactString (Ctx.Field Ctx.Rack ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Broker{nodeId,host,port,rack,taggedFields}

parserTopic :: Context -> Parser Context s Topic
parserTopic ctx = do
  errorCode <- Kafka.Parser.errorCode (Ctx.Field Ctx.ErrorCode ctx)
  name <- Kafka.Parser.compactString (Ctx.Field Ctx.Name ctx)
  id <- Kafka.Parser.word128 (Ctx.Field Ctx.Id ctx)
  internal <- Kafka.Parser.boolean (Ctx.Field Ctx.Internal ctx)
  partitions <- Kafka.Parser.compactArray parserPartition
    (Ctx.Field Ctx.Partitions ctx)
  authorizedOperations <- Kafka.Parser.word32 (Ctx.Field Ctx.AuthorizedOperations ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Topic{errorCode,name,id,internal,partitions,authorizedOperations,taggedFields}

parserPartition :: Context -> Parser Context s Partition
parserPartition ctx = do
  errorCode <- Kafka.Parser.errorCode (Ctx.Field Ctx.ErrorCode ctx)
  index <- Kafka.Parser.int32 (Ctx.Field Ctx.Ix ctx)
  leaderId <- Kafka.Parser.int32 (Ctx.Field Ctx.LeaderId ctx)
  leaderEpoch <- Kafka.Parser.int32 (Ctx.Field Ctx.LeaderEpoch ctx)
  replicaNodes <- Kafka.Parser.compactInt32Array (Ctx.Field Ctx.ReplicaNodes ctx)
  isrNodes <- Kafka.Parser.compactInt32Array (Ctx.Field Ctx.IsrNodes ctx)
  offlineReplicas <- Kafka.Parser.compactInt32Array (Ctx.Field Ctx.OfflineReplicas ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Partition
    { errorCode
    , index
    , leaderId
    , leaderEpoch
    , replicaNodes
    , isrNodes
    , offlineReplicas
    , taggedFields
    }
