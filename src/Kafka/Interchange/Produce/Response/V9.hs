{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Interchange.Produce.Response.V9
  ( Response(..)
  , parser
  , decode
  ) where

import Data.Primitive (SmallArray)
import Data.Int (Int16,Int32,Int64)
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
  { topics :: !(SmallArray Topic)
  , throttleTimeMilliseconds :: !Int32
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Topic = Topic
  { name :: !Text
  , partitions :: !(SmallArray Partition)
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Partition = Partition
  { index :: !Int32
  , errorCode :: !Int16
  , baseOffset :: !Int64
  , logAppendTimeMilliseconds :: !Int64
  , logStartOffset :: !Int64
  , errors :: !(SmallArray Error)
  , errorMessage :: !Text
    -- ^ Kafka documentation describes this as: "The global error message
    -- summarizing the common root cause of the records that caused the
    -- batch to be dropped". Although kafka allows both NULL and the empty
    -- string as distinct values, we decode NULL by mapping it to the
    -- empty string.
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
  topics <- Kafka.Parser.compactArray parserTopic ctx
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{topics,throttleTimeMilliseconds,tagBuffer}

parserTopic :: Context -> Parser Context s Topic
parserTopic ctx = do
  name <- Kafka.Parser.compactString (Ctx.Field Ctx.Name ctx)
  partitions <- Kafka.Parser.compactArray parserPartition
    (Ctx.Field Ctx.Partitions ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Topic{name,partitions,tagBuffer}

parserPartition :: Context -> Parser Context s Partition
parserPartition ctx = do
  index <- Kafka.Parser.int32 (Ctx.Field Ctx.Ix ctx)
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  baseOffset <- Kafka.Parser.int64 (Ctx.Field Ctx.BaseOffset ctx)
  logAppendTimeMilliseconds <- Kafka.Parser.int64 (Ctx.Field Ctx.LogAppendTimeMilliseconds ctx)
  logStartOffset <- Kafka.Parser.int64 (Ctx.Field Ctx.LogStartOffset ctx)
  errors <- Kafka.Parser.compactArray parserError
    (Ctx.Field Ctx.Errors ctx)
  errorMessage <- Kafka.Parser.compactString (Ctx.Field Ctx.ErrorMessage ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Partition
    { index
    , errorCode
    , baseOffset
    , logAppendTimeMilliseconds
    , logStartOffset
    , errors
    , errorMessage
    , tagBuffer
    }

parserError :: Context -> Parser Context s Error
parserError ctx = do
  index <- Kafka.Parser.int32 (Ctx.Field Ctx.Ix ctx)
  message <- Kafka.Parser.compactString (Ctx.Field Ctx.Message ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Error{index,message,tagBuffer}
