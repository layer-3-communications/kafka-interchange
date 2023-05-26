{-# language BangPatterns #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.JoinGroup.Response.V9
  ( Response(..)
  , Member(..)
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
import Kafka.ErrorCode (ErrorCode)
import Kafka.TaggedField (TaggedField)
import Kafka.Parser.Context (Context)
import Data.Text (Text)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Header.Response.V0 as Header
import qualified Kafka.TaggedField as TaggedField
import qualified Kafka.Parser

data Response = Response
  { throttleTimeMilliseconds :: !Int32
  , errorCode :: !ErrorCode
  , generationId :: !Int32
  , protocolType :: !Text
  , protocolName :: !Text
  , leader :: !Text
  , skipAssignment :: !Bool
  , memberId :: !Text
  , members :: !(SmallArray Member)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving (Show)

data Member = Member
  { memberId :: !Text
  , groupInstanceId :: !Text
  , metadata :: !Bytes
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

parserMember :: Context -> Parser Context s Member
parserMember ctx = do
  memberId <- Kafka.Parser.compactString (Ctx.Field Ctx.MemberId ctx)
  groupInstanceId <- Kafka.Parser.compactString (Ctx.Field Ctx.GroupInstanceId ctx)
  metadata <- Kafka.Parser.compactBytes (Ctx.Field Ctx.Metadata ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Member{memberId,groupInstanceId,metadata,taggedFields}

parser :: Context -> Parser Context s Response
parser ctx = do
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  errorCode <- Kafka.Parser.errorCode (Ctx.Field Ctx.ErrorCode ctx)
  generationId <- Kafka.Parser.int32 (Ctx.Field Ctx.GenerationId ctx)
  protocolType <- Kafka.Parser.compactString (Ctx.Field Ctx.ProtocolType ctx)
  protocolName <- Kafka.Parser.compactString (Ctx.Field Ctx.ProtocolName ctx)
  leader <- Kafka.Parser.compactString (Ctx.Field Ctx.Leader ctx)
  skipAssignment <- Kafka.Parser.boolean (Ctx.Field Ctx.SkipAssignment ctx)
  memberId <- Kafka.Parser.compactString (Ctx.Field Ctx.MemberId ctx)
  members <- Kafka.Parser.compactArray parserMember (Ctx.Field Ctx.Members ctx) 
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response
    { throttleTimeMilliseconds
    , errorCode
    , generationId
    , protocolType
    , protocolName
    , leader
    , skipAssignment
    , memberId
    , members
    , taggedFields
    }

