{-# language BangPatterns #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.ApiVersions.Response.V3
  ( Response(..)
  , ApiKeyVersionSupport(..)
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
import Kafka.ApiKey (ApiKey)
import Kafka.Parser.Context (Context)
import Kafka.TaggedField (TaggedField)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Header.Response.V0 as Header
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser

data Response = Response
  { errorCode :: !Int16
  , apiKeys :: !(SmallArray ApiKeyVersionSupport)
  , throttleTimeMilliseconds :: !Int32
  , taggedFields :: !(SmallArray TaggedField)
  } deriving (Show)

data ApiKeyVersionSupport = ApiKeyVersionSupport
  { apiKey :: !ApiKey
  , minVersion :: !Int16
  , maxVersion :: !Int16
  , taggedFields :: !(SmallArray TaggedField)
  } deriving (Show)

decodeHeaded :: Bytes -> Either Context (Header.Headed Response)
decodeHeaded !b = Parser.parseBytesEither
  (liftA2 Header.Headed
    (Header.parser Ctx.Top)
    (parser Ctx.Top <* Parser.endOfInput Ctx.End)
  ) b

decode :: Bytes -> Either Context Response
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.End) b

parserApiKey :: Context -> Parser Context s ApiKeyVersionSupport
parserApiKey ctx = do
  apiKey <- Kafka.Parser.apiKey (Ctx.Field Ctx.ApiKey ctx)
  minVersion <- Kafka.Parser.int16 (Ctx.Field Ctx.MinVersion ctx)
  maxVersion <- Kafka.Parser.int16 (Ctx.Field Ctx.MaxVersion ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure ApiKeyVersionSupport{apiKey,minVersion,maxVersion,taggedFields}

parser :: Context -> Parser Context s Response
parser ctx = do
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  apiKeys <- Kafka.Parser.compactArray parserApiKey (Ctx.Field Ctx.ApiKeys ctx) 
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{errorCode,apiKeys,throttleTimeMilliseconds,taggedFields}
