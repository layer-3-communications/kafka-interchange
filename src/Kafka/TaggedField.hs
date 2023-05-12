{-# language NamedFieldPuns #-}

module Kafka.TaggedField
  ( TaggedField(..)
  , parser
  , parserMany
  ) where

import Kafka.Parser.Context (Context)
import Data.Bytes.Parser (Parser)
import Data.Primitive (SmallArray)
import Data.Bytes (Bytes)
import Data.Word (Word32)

import qualified Data.Bytes.Parser.Leb128 as Leb128
import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Kafka.Parser

data TaggedField = TaggedField
  { tag :: !Word32
  , contents :: {-# UNPACK #-} !Bytes
  } deriving (Show)

parserMany :: Context -> Parser Context s (SmallArray TaggedField)
parserMany ctx = Kafka.Parser.varintLengthPrefixedArray parser ctx

parser :: Context -> Parser Context s TaggedField
parser ctx = do
  tag <- Leb128.word32 (Ctx.Field Ctx.TaggedFieldTag ctx)
  len <- Leb128.word32 (Ctx.Field Ctx.TaggedFieldLength ctx)
  contents <- Parser.take (Ctx.Field Ctx.TaggedFieldContents ctx) (fromIntegral len)
  pure TaggedField{tag,contents}
