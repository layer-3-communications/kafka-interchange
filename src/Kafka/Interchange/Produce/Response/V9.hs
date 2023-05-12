{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Interchange.Produce.Response.V9
  ( Response(..)
  , Topic(..)
  , Partition(..)
  , Error(..)
  , parser
  , decode
  , decodeHeaded
  ) where

import Control.Applicative (liftA2)
import Data.Bytes (Bytes)
import Data.Bytes.Parser (Parser)
import Data.Int (Int16,Int32,Int64)
import Data.Primitive (SmallArray)
import Data.Text (Text)
import Kafka.TaggedField (TaggedField)
import Kafka.Parser.Context (Context)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser
import qualified Kafka.Interchange.Header.Response.V1 as Header

data Response = Response
  { topics :: !(SmallArray Topic)
  , throttleTimeMilliseconds :: !Int32
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
  topics <- Kafka.Parser.compactArray parserTopic ctx
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{topics,throttleTimeMilliseconds,taggedFields}

parserTopic :: Context -> Parser Context s Topic
parserTopic ctx = do
  name <- Kafka.Parser.compactString (Ctx.Field Ctx.Name ctx)
  partitions <- Kafka.Parser.compactArray parserPartition
    (Ctx.Field Ctx.Partitions ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Topic{name,partitions,taggedFields}

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
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Partition
    { index
    , errorCode
    , baseOffset
    , logAppendTimeMilliseconds
    , logStartOffset
    , errors
    , errorMessage
    , taggedFields
    }

parserError :: Context -> Parser Context s Error
parserError ctx = do
  index <- Kafka.Parser.int32 (Ctx.Field Ctx.Ix ctx)
  message <- Kafka.Parser.compactString (Ctx.Field Ctx.Message ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Error{index,message,taggedFields}
