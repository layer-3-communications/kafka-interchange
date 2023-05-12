{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language LambdaCase #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Interchange.Fetch.Response.V13
  ( Response(..)
  , Topic(..)
  , Partition(..)
  , parser
  , decode
  , decodeHeaded
  ) where

import Prelude hiding (id)

import Control.Applicative (liftA2)
import Data.WideWord (Word128)
import Data.Primitive (SmallArray,PrimArray)
import Data.Int (Int16,Int32,Int64)
import Data.Word (Word32)
import Kafka.Parser.Context (Context)
import Data.Text (Text)
import Data.Bytes.Parser (Parser)
import Data.Bytes (Bytes)
import Kafka.TaggedField (TaggedField)
import Kafka.Interchange.RecordBatch.Response (RecordBatch)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser
import qualified Kafka.Interchange.Header.Response.V1 as Header
import qualified Kafka.Interchange.RecordBatch.Response as RecordBatch

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , errorCode :: !Int16
  , sessionId :: !Int32
  , topics :: !(SmallArray Topic)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Topic = Topic
  { id :: {-# UNPACK #-} !Word128
  , partitions :: !(SmallArray Partition)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Partition = Partition
  { index :: !Int32
  , errorCode :: !Int16
  , highWatermark :: !Int64
  , lastStableOffset :: !Int64
  , logStartOffset :: !Int64
  , preferredReadReplica :: !Int32
  , records :: !(SmallArray RecordBatch)
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
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  sessionId <- Kafka.Parser.int32 (Ctx.Field Ctx.SessionId ctx)
  topics <- Kafka.Parser.compactArray parserTopic (Ctx.Field Ctx.Topics ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,errorCode,sessionId,topics,taggedFields}

parserTopic :: Context -> Parser Context s Topic
parserTopic ctx = do
  id <- Kafka.Parser.word128 (Ctx.Field Ctx.Id ctx)
  partitions <- Kafka.Parser.compactArray parserPartition (Ctx.Field Ctx.Partitions ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Topic{id,partitions,taggedFields}

parserPartition :: Context -> Parser Context s Partition
parserPartition ctx = do
  index <- Kafka.Parser.int32 (Ctx.Field Ctx.Ix ctx)
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  highWatermark <- Kafka.Parser.int64 (Ctx.Field Ctx.HighWatermark ctx)
  lastStableOffset <- Kafka.Parser.int64 (Ctx.Field Ctx.LastStableOffset ctx)
  logStartOffset <- Kafka.Parser.int64 (Ctx.Field Ctx.LogStartOffset ctx)
  -- I do not have an example of a log with an aborted transaction, so
  -- I'm not sure how this would look if it were present.
  Parser.any (Ctx.Field Ctx.AbortedTransactions ctx) >>= \case
    0 -> pure ()
    _ -> Parser.fail (Ctx.Field Ctx.AbortedTransactions ctx)
  preferredReadReplica <- Kafka.Parser.int32 (Ctx.Field Ctx.PreferredReadReplica ctx)
  sizeSucc <- Kafka.Parser.varWordNative (Ctx.Field Ctx.RecordBatchLength ctx)
  size <- case sizeSucc of
    0 -> Kafka.Parser.fail (Ctx.Field Ctx.RecordBatchLength ctx)
    _ -> pure (fromIntegral (sizeSucc - 1) :: Int)
  records <- Parser.delimit
    (Ctx.Field Ctx.RecordBatchNotEnoughBytes ctx)
    (Ctx.Field Ctx.RecordBatchLeftoverBytes ctx)
    size
    (RecordBatch.parserArray (Ctx.Field Ctx.RecordBatch ctx))
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Partition
    { index
    , errorCode
    , highWatermark
    , lastStableOffset
    , logStartOffset
    , preferredReadReplica
    , records
    , taggedFields
    }

