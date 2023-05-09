{-# language BangPatterns #-}
{-# language DataKinds #-}
{-# language DerivingStrategies #-}
{-# language LambdaCase #-}
{-# language NamedFieldPuns #-}
{-# language TypeApplications #-}

module Kafka.Interchange.RecordBatch.Response
  ( RecordBatch(..)
  , parser
  , parserArray
  ) where

import Control.Monad (when)
import Data.Bytes (Bytes)
import Data.Bytes.Parser (Parser)
import Data.Int (Int32,Int64,Int16)
import Data.Primitive (SmallArray)
import Data.Word (Word16)
import Kafka.Parser.Context (Context)

import qualified Arithmetic.Nat as Nat
import qualified Crc32c
import qualified Data.Bytes as Bytes
import qualified Data.Bytes.Parser as Parser
import qualified Data.Primitive.Contiguous as C
import qualified Kafka.Parser
import qualified Kafka.Parser.Context as Ctx

-- | A record batch. The following fields are not made explicit since
-- they are only for framing and checksum:
--
-- * batchLength
-- * magic (always the number 2)
-- * crc
--
-- From kafka documentation:
--
-- > baseOffset: int64
-- > batchLength: int32
-- > partitionLeaderEpoch: int32
-- > magic: int8 (current magic value is 2)
-- > crc: int32
-- > attributes: int16
-- >     bit 0~2:
-- >         0: no compression
-- >         1: gzip
-- >         2: snappy
-- >         3: lz4
-- >         4: zstd
-- >     bit 3: timestampType
-- >     bit 4: isTransactional (0 means not transactional)
-- >     bit 5: isControlBatch (0 means not a control batch)
-- >     bit 6: hasDeleteHorizonMs (0 means baseTimestamp is not set as the delete horizon for compaction)
-- >     bit 7~15: unused
-- > lastOffsetDelta: int32
-- > baseTimestamp: int64
-- > maxTimestamp: int64
-- > producerId: int64
-- > producerEpoch: int16
-- > baseSequence: int32
-- > records: [Record]
--
-- A few of my own observations:
--
-- * The docs add a note that that last field @records@ is not really what
--   it looks like. The array length is always serialized in the usual way,
--   but the payload might be compressed.
-- * The field @batchLength@ includes the size of everything after it.
--   So, not itself and not @baseOffset@.
data RecordBatch = RecordBatch
  { baseOffset :: !Int64
  , partitionLeaderEpoch :: !Int32
  , attributes :: !Word16
  , lastOffsetDelta :: !Int32
  , baseTimestamp :: !Int64
  , maxTimestamp :: !Int64
  , producerId :: !Int64
  , producerEpoch :: !Int16
  , baseSequence :: !Int32
  , recordsCount :: !Int32
  , recordsPayload :: !Bytes
    -- ^ Records might be compressed. Look at @attributes@ to check for
    -- compression, and with that information, you can decode this field.
  } deriving stock (Show)

-- This is not encoded like of the other arrays in kafka. Here, the
-- record batches are just encoded and then concatenated one after
-- the next. There is no length prefix that signals how many batches
-- are present. To my knowledge, this is undocumented.
parserArray :: Context -> Parser Context s (SmallArray RecordBatch)
parserArray !ctx = go [] 0
  where
  go !acc !n = Parser.isEndOfInput >>= \case
    True -> pure $! C.unsafeFromListReverseN n acc
    False -> do
      batch <- parser (Ctx.Index n ctx)
      go (batch : acc) (n + 1)

parser :: Context -> Parser Context s RecordBatch
parser !ctx = do
  baseOffset <- Kafka.Parser.int64 (Ctx.Field Ctx.BaseOffset ctx)
  batchLength <- Kafka.Parser.int32 (Ctx.Field Ctx.BatchLength ctx)
  when (batchLength < 0) (Parser.fail (Ctx.Field Ctx.BatchLengthNegative ctx))
  Parser.delimit
    (Ctx.Field Ctx.BatchLengthNotEnoughBytes ctx)
    (Ctx.Field Ctx.BatchLengthLeftoverBytes ctx)
    (fromIntegral batchLength :: Int) $ do
      partitionLeaderEpoch <- Kafka.Parser.int32 (Ctx.Field Ctx.PartitionLeaderEpoch ctx)
      Parser.any (Ctx.Field Ctx.Magic ctx) >>= \case
        2 -> pure ()
        _ -> Parser.fail (Ctx.Field Ctx.Magic ctx)
      crc <- Kafka.Parser.word32 (Ctx.Field Ctx.Crc ctx)
      remaining <- Parser.peekRemaining
      when (Crc32c.bytes 0 remaining /= crc) $ do
        Parser.fail (Ctx.Field Ctx.CrcMismatch ctx)
      attributes <- Kafka.Parser.word16 (Ctx.Field Ctx.Attributes ctx)
      lastOffsetDelta <- Kafka.Parser.int32 (Ctx.Field Ctx.LastOffsetDelta ctx)
      baseTimestamp <- Kafka.Parser.int64 (Ctx.Field Ctx.BaseTimestamp ctx)
      maxTimestamp <- Kafka.Parser.int64 (Ctx.Field Ctx.MaxTimestamp ctx)
      producerId <- Kafka.Parser.int64 (Ctx.Field Ctx.ProducerId ctx)
      producerEpoch <- Kafka.Parser.int16 (Ctx.Field Ctx.ProducerEpoch ctx)
      baseSequence <- Kafka.Parser.int32 (Ctx.Field Ctx.BaseSequence ctx)
      recordsCount <- Kafka.Parser.int32 (Ctx.Field Ctx.RecordsCount ctx)
      recordsPayload <- Parser.remaining
      pure RecordBatch
        { baseOffset, partitionLeaderEpoch, attributes 
        , lastOffsetDelta, baseTimestamp, maxTimestamp
        , producerId, producerEpoch, baseSequence, recordsCount
        , recordsPayload
        }
