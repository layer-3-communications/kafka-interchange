{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.InitProducerId.Response.V4
  ( Response(..)
  , parser
  , decode
  , decodeHeaded
  ) where

import Prelude hiding (id)

import Control.Applicative (liftA2)
import Data.Bytes (Bytes)
import Data.Bytes.Parser (Parser)
import Data.Int (Int16,Int32,Int64)
import Data.Primitive (SmallArray)
import Kafka.ErrorCode (ErrorCode)
import Kafka.Parser.Context (Context)
import Kafka.TaggedField (TaggedField)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser
import qualified Kafka.Header.Response.V1 as Header

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , errorCode :: !ErrorCode
  , producerId :: !Int64
  , producerEpoch :: !Int16
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
  errorCode <- Kafka.Parser.errorCode (Ctx.Field Ctx.ErrorCode ctx)
  producerId <- Kafka.Parser.int64 (Ctx.Field Ctx.ProducerId ctx)
  producerEpoch <- Kafka.Parser.int16 (Ctx.Field Ctx.ProducerEpoch ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,errorCode,producerId,producerEpoch,taggedFields}
