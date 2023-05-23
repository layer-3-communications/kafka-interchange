{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.OffsetFetch.Response.V8
  ( Response(..)
  , Group(..)
  , Topic(..)
  , Partition(..)
  , parser
  , decode
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

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser
import qualified Kafka.Header.Response.V1 as Header

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , groups :: !(SmallArray Group)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Group = Group
  { id :: !Text
  , topics :: !(SmallArray Topic)
  , errorCode :: !Int16
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Topic = Topic
  { name :: !Text
  , partitions :: !(SmallArray Partition)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Partition = Partition
  { index :: !Int32
  , committedOffset :: !Int64
  , committedLeaderEpoch :: !Int32
  , metadata :: !Text
  , errorCode :: !Int16
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

decode :: Bytes -> Either Context Response
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.End) b

parser :: Context -> Parser Context s Response
parser ctx = do
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  groups <- Kafka.Parser.compactArray parserGroup (Ctx.Field Ctx.Groups ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,groups,taggedFields}

parserGroup :: Context -> Parser Context s Group
parserGroup ctx = do
  id <- Kafka.Parser.compactString (Ctx.Field Ctx.Id ctx)
  topics <- Kafka.Parser.compactArray parserTopic (Ctx.Field Ctx.Topics ctx)
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Group{id,topics,errorCode,taggedFields}

parserTopic :: Context -> Parser Context s Topic
parserTopic ctx = do
  name <- Kafka.Parser.compactString (Ctx.Field Ctx.Name ctx)
  partitions <- Kafka.Parser.compactArray parserPartition (Ctx.Field Ctx.Partitions ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Topic{name,partitions,taggedFields}

parserPartition :: Context -> Parser Context s Partition
parserPartition ctx = do
  index <- Kafka.Parser.int32 (Ctx.Field Ctx.Ix ctx)
  committedOffset <- Kafka.Parser.int64 (Ctx.Field Ctx.CommittedOffset ctx)
  committedLeaderEpoch <- Kafka.Parser.int32 (Ctx.Field Ctx.CommittedLeaderEpoch ctx)
  metadata <- Kafka.Parser.compactString (Ctx.Field Ctx.Metadata ctx)
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Partition
    { index
    , committedOffset
    , committedLeaderEpoch
    , metadata
    , errorCode
    , taggedFields
    }
