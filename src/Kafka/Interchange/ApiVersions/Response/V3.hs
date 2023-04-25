{-# language BangPatterns #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Interchange.ApiVersions.Response.V3
  ( Response(..)
  , parser
  , decode
  ) where

import Data.Primitive (SmallArray)
import Data.Int (Int16)
import Data.Int (Int32)
import Kafka.Parser.Context (Context)
import Data.Bytes.Parser (Parser)
import Data.Bytes (Bytes)
import Kafka.Data.TaggedField (TaggedField)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Data.TaggedField as TaggedField
import qualified Kafka.Parser

data Response = Response
  { errorCode :: !Int16
  , apiKeys :: !(SmallArray ApiKeyVersionSupport)
  , throttleTimeMilliseconds :: !Int32
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving (Show)

data ApiKeyVersionSupport = ApiKeyVersionSupport
  { apiKey :: !Int16
  , minVersion :: !Int16
  , maxVersion :: !Int16
  , tagBuffer :: !(SmallArray TaggedField)
  } deriving (Show)

decode :: Bytes -> Either Context Response
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.Top) b

parserApiKey :: Context -> Parser Context s ApiKeyVersionSupport
parserApiKey ctx = do
  apiKey <- Kafka.Parser.int16 (Ctx.Field Ctx.ApiKey ctx)
  minVersion <- Kafka.Parser.int16 (Ctx.Field Ctx.MinVersion ctx)
  maxVersion <- Kafka.Parser.int16 (Ctx.Field Ctx.MaxVersion ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure ApiKeyVersionSupport{apiKey,minVersion,maxVersion,tagBuffer}

parser :: Context -> Parser Context s Response
parser ctx = do
  errorCode <- Kafka.Parser.int16 (Ctx.Field Ctx.ErrorCode ctx)
  apiKeys <- Kafka.Parser.compactArray parserApiKey (Ctx.Field Ctx.ApiKeys ctx) 
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  tagBuffer <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{errorCode,apiKeys,throttleTimeMilliseconds,tagBuffer}
