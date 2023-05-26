{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.LeaveGroup.Response.V5
  ( Response(..)
  , Member(..)
  , parser
  , decode
  ) where

import Prelude hiding (id)

import Control.Applicative (liftA2)
import Data.Bytes (Bytes)
import Data.Bytes.Parser (Parser)
import Data.Int (Int16,Int32,Int64)
import Data.Primitive (SmallArray)
import Data.Text (Text)
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
  , members :: !(SmallArray Member)
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

data Member = Member
  { memberId :: !Text
  , groupInstanceId :: !(Maybe Text)
  , errorCode :: !ErrorCode
  , taggedFields :: !(SmallArray TaggedField)
  } deriving stock (Show)

decode :: Bytes -> Either Context Response
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.End) b

parser :: Context -> Parser Context s Response
parser ctx = do
  throttleTimeMilliseconds <- Kafka.Parser.int32 (Ctx.Field Ctx.ThrottleTimeMilliseconds ctx)
  errorCode <- Kafka.Parser.errorCode (Ctx.Field Ctx.ErrorCode ctx)
  members <- Kafka.Parser.compactArray parserMember (Ctx.Field Ctx.Members ctx) 
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Response{throttleTimeMilliseconds,errorCode,members,taggedFields}

parserMember :: Context -> Parser Context s Member
parserMember ctx = do
  memberId <- Kafka.Parser.compactString (Ctx.Field Ctx.MemberId ctx)
  groupInstanceId <- Kafka.Parser.compactNullableString (Ctx.Field Ctx.GroupInstanceId ctx)
  errorCode <- Kafka.Parser.errorCode (Ctx.Field Ctx.ErrorCode ctx)
  taggedFields <- TaggedField.parserMany (Ctx.Field Ctx.TagBuffer ctx)
  pure Member{memberId,groupInstanceId,errorCode,taggedFields}
