{-# language BangPatterns #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Assignment.Response.V1
  ( Assignment(..)
  , Ownership(..)
  , parser
  , decode
  ) where

import Control.Monad (when)
import Data.Bytes (Bytes)
import Data.Bytes.Parser (Parser)
import Data.Int (Int16,Int32)
import Data.Primitive (SmallArray)
import Data.Text (Text)
import Kafka.Parser.Context (Context)
import Kafka.Assignment.Request.V1 (Assignment(..),Ownership(..))
import Kafka.Subscription.Response.V1 (parserOwnership)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Parser

parser :: Context -> Parser Context s Assignment
parser ctx = do
  version <- Kafka.Parser.int16 (Ctx.Field Ctx.Version ctx)
  -- Since this is the V1 subscription, we require that the serialized
  -- message indicated V1 or greater.
  when (version <= 0) (Parser.fail (Ctx.Field Ctx.Version ctx))
  assignedPartitions <- Kafka.Parser.array parserOwnership
    (Ctx.Field Ctx.AssignedPartitions ctx) 
  userData <- Kafka.Parser.nonCompactBytes
    (Ctx.Field Ctx.UserData ctx)
  pure Assignment{assignedPartitions,userData}

-- | Decode allows trailing content since we should be able
-- to parse newer versions of subscription and discard the
-- parts that we do not understand.
decode :: Bytes -> Either Context Assignment
decode !b = Parser.parseBytesEither (parser Ctx.Top) b
