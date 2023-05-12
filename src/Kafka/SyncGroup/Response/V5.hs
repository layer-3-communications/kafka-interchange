{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.SyncGroup.Response.V5
  ( Response(..)
  , parser
  , decode
  , decodeHeaded
  ) where

import Prelude hiding (id)

import Data.Text (Text)
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
import qualified Kafka.Header.Response.V1 as Header

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , errorCode :: !Int16
  , protocolType :: !Text
  , protocolName :: !Text
  , assignment :: !Bytes
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
  protocolType <- Kafka.Parser.compactString (Ctx.Field Ctx.ProtocolType ctx)
  protocolName <- Kafka.Parser.compactString (Ctx.Field Ctx.ProtocolName ctx)
  assignment <- Kafka.Parser.compactBytes (Ctx.Field Ctx.Assignment ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,errorCode,protocolType,protocolName,assignment,taggedFields}

