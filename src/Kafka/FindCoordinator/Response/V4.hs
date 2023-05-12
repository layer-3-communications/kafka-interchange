{-# language BangPatterns #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.FindCoordinator.Response.V4
  ( Response(..)
  , Coordinator(..)
  , parser
  , decode
  , decodeHeaded
  ) where

import Control.Applicative (liftA2)
import Data.Bytes (Bytes)
import Data.Bytes.Parser (Parser)
import Data.Int (Int16)
import Data.Int (Int32)
import Data.Primitive (SmallArray)
import Data.Text (Text)
import Kafka.TaggedField (TaggedField)
import Kafka.Parser.Context (Context)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Header.Response.V0 as Header
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , coordinators :: !(SmallArray Coordinator)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving (Show)

data Coordinator = Coordinator
  { key :: !Text
  , nodeId :: !Int32
  , host :: !Text
  , port :: !Int32
  , errorCode :: !Int16
  , errorMessage :: !Text
  , taggedFields :: !(SmallArray TaggedField)
  } deriving (Show)

parserCoordinator :: Context -> Parser Context s Coordinator
parserCoordinator ctx = do
  key <- Kafka.Parser.compactString (Ctx.Field Ctx.Key ctx)
  nodeId <- Kafka.Parser.int32 (Ctx.Field Ctx.NodeId ctx)
  host <- Kafka.Parser.compactString (Ctx.Field Ctx.Host ctx)
  port <- Kafka.Parser.int32 (Ctx.Field Ctx.Port ctx)
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  errorMessage <- Kafka.Parser.compactString (Ctx.Field Ctx.ErrorMessage ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Coordinator{key,nodeId,host,port,errorCode,errorMessage,taggedFields}

parser :: Context -> Parser Context s Response
parser ctx = do
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  coordinators <- Kafka.Parser.compactArray parserCoordinator (Ctx.Field Ctx.Coordinators ctx) 
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,coordinators,taggedFields}

decodeHeaded :: Bytes -> Either Context (Header.Headed Response)
decodeHeaded !b = Parser.parseBytesEither
  (liftA2 Header.Headed
    (Header.parser Ctx.Top)
    (parser Ctx.Top <* Parser.endOfInput Ctx.End)
  ) b

decode :: Bytes -> Either Context Response
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.End) b

