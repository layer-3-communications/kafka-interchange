{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language LambdaCase #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.ListOffsets.Response.V7
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
import Kafka.RecordBatch.Response (RecordBatch)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser
import qualified Kafka.Header.Response.V1 as Header
import qualified Kafka.RecordBatch.Response as RecordBatch

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , topics :: !(SmallArray Topic)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Topic = Topic
  { name :: !Text
  , partitions :: !(SmallArray Partition)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Partition = Partition
  { index :: !Int32
  , errorCode :: !Int16
  , timestamp :: !Int64
  , offset :: !Int64
  , leaderEpoch :: !Int32
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
  topics <- Kafka.Parser.compactArray parserTopic (Ctx.Field Ctx.Topics ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,topics,taggedFields}

parserTopic :: Context -> Parser Context s Topic
parserTopic ctx = do
  name <- Kafka.Parser.compactString (Ctx.Field Ctx.Name ctx)
  partitions <- Kafka.Parser.compactArray parserPartition (Ctx.Field Ctx.Partitions ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Topic{name,partitions,taggedFields}

parserPartition :: Context -> Parser Context s Partition
parserPartition ctx = do
  index <- Kafka.Parser.int32 (Ctx.Field Ctx.Ix ctx)
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  timestamp <- Kafka.Parser.int64 (Ctx.Field Ctx.Timestamp ctx)
  offset <- Kafka.Parser.int64 (Ctx.Field Ctx.Offset ctx)
  leaderEpoch <- Kafka.Parser.int32 (Ctx.Field Ctx.LeaderEpoch ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Partition
    { index
    , errorCode
    , timestamp
    , offset
    , leaderEpoch
    , taggedFields
    }


