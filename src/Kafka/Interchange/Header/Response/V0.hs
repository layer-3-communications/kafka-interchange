{-# language BangPatterns #-}
{-# language DerivingStrategies #-}
{-# language DuplicateRecordFields #-}
{-# language NamedFieldPuns #-}

module Kafka.Interchange.Header.Response.V0
  ( Header(..)
  , Headed(..)
  , parser
  , decode
  ) where

import Data.Int (Int32)
import Kafka.Parser.Context (Context)
import Data.Bytes.Parser (Parser)
import Data.Bytes (Bytes)

import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Parser

data Headed a = Headed
  { header :: !Header
  , response :: !a
  } deriving stock (Show)

newtype Header = Header
  { correlationId :: Int32
  } deriving stock (Show)

-- | Note: Decode is here for the benefit of the test suite. A response
-- header prefaces another message, so in an actual kafka client,
-- it makes more sense to monadically sequence the two parsers.
decode :: Bytes -> Either Context Header
decode !b = Parser.parseBytesEither (parser Ctx.Top <* Parser.endOfInput Ctx.End) b

parser :: Context -> Parser Context s Header
parser ctx = do
  correlationId <- Kafka.Parser.int32 (Ctx.Field Ctx.CorrelationId ctx)
  pure Header{correlationId}

