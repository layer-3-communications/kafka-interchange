{-# language BangPatterns #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Interchange.Subscription.Response.V1
  ( Subscription(..)
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
import Kafka.Interchange.Subscription.Request.V1 (Subscription(..),Ownership(..))

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Parser

parserOwnership :: Context -> Parser Context s Ownership
parserOwnership ctx = do
  topic <- Kafka.Parser.string (Ctx.Field Ctx.Topic ctx)
  partitions <- Kafka.Parser.int32Array
    (Ctx.Field Ctx.Partitions ctx)
  pure Ownership{topic,partitions}

parser :: Context -> Parser Context s Subscription
parser ctx = do
  version <- Kafka.Parser.int16 (Ctx.Field Ctx.Version ctx)
  -- Since this is the V1 subscription, we require that the serialized
  -- message indicated V1 or greater.
  when (version <= 0) (Parser.fail (Ctx.Field Ctx.Version ctx))
  topics <- Kafka.Parser.array Kafka.Parser.string
    (Ctx.Field Ctx.Topics ctx) 
  userData <- Kafka.Parser.nonCompactBytes
    (Ctx.Field Ctx.UserData ctx)
  ownedPartitions <- Kafka.Parser.array parserOwnership
    (Ctx.Field Ctx.OwnedPartitions ctx) 
  pure Subscription{topics,userData,ownedPartitions}

-- | Decode allows trailing content since we should be able
-- to parse newer versions of subscription and discard the
-- parts that we do not understand.
decode :: Bytes -> Either Context Subscription
decode !b = Parser.parseBytesEither (parser Ctx.Top) b
