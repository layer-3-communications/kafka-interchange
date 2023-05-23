{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Heartbeat.Response.V4
  ( Response(..)
  , parser
  , decode
  ) where

import Prelude hiding (id)

import Control.Applicative (liftA2)
import Data.Primitive (SmallArray)
import Data.Int (Int16,Int32,Int64)
import Kafka.Parser.Context (Context)
import Data.Bytes.Parser (Parser)
import Data.Bytes (Bytes)
import Kafka.TaggedField (TaggedField)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , errorCode :: !Int16
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

decode :: Bytes -> Either Context Response
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.End) b

parser :: Context -> Parser Context s Response
parser ctx = do
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,errorCode,taggedFields}
