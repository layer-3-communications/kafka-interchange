{-# language DataKinds #-}
{-# language NamedFieldPuns #-}
{-# language TypeApplications #-}

module Kafka.RecordBatch.Request
  ( RecordBatch(..)
  , toChunks
  ) where

import Data.Int (Int32,Int64,Int16)
import Data.Word (Word16)
import Kafka.Builder (Builder)
import Data.Bytes.Chunks (Chunks(ChunksCons))

import qualified Arithmetic.Nat as Nat
import qualified Data.Bytes as Bytes
import qualified Data.Bytes.Chunks as Chunks
import qualified Kafka.Builder as Builder
import qualified Kafka.Builder.Bounded as Bounded
import qualified Crc32c

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
    -- ^ When producing records, this should always be set to zero.
    -- It might make sense to just remove this field. The actual base
    -- offset assigned to the batch can be found at
    -- @Kafka.Produce.Response.V9:Partition.baseOffset@.
  , partitionLeaderEpoch :: !Int32
    -- ^ It looks like this is always set to -1 during production.
  , attributes :: !Word16
  , lastOffsetDelta :: !Int32
    -- ^ Should be set to the number of records minus one.
  , baseTimestamp :: !Int64
  , maxTimestamp :: !Int64
  , producerId :: !Int64
    -- ^ Producer ID. This comes from the @InitProducerId@ response.
  , producerEpoch :: !Int16
    -- ^ Producer epoch. This comes from the @InitProducerId@ response.
  , baseSequence :: !Int32
    -- ^ This is not documented very well anywhere, but it appears that,
    -- for a producer (identifier by a producer id), the sequence number
    -- starts as zero and is increased by 1 for every message that is produced.
    -- So, if the first base sequence number is 0, and a batch of 50 messages
    -- is produces, then next base sequence number will be 50.
  , recordsCount :: !Int32
    -- ^ Number of records.
  , recordsPayload :: !Chunks
    -- ^ Records might be compressed. Look at @attributes@ to check for
    -- compression, and with that information, you can decode this field.
  }

toChunks :: RecordBatch -> Chunks
toChunks RecordBatch
  { baseOffset, partitionLeaderEpoch, attributes 
  , lastOffsetDelta, baseTimestamp, maxTimestamp
  , producerId, producerEpoch, baseSequence, recordsCount
  , recordsPayload
  } =
  ChunksCons
    ( Bytes.fromByteArray $ Bounded.run Nat.constant
      ( Bounded.int64 baseOffset
        `Bounded.append`
        Bounded.int32 (fromIntegral (Chunks.length postCrc + (4 + 1 + 4)))
        `Bounded.append`
        Bounded.int32 partitionLeaderEpoch
        `Bounded.append`
        Bounded.word8 0x02
        `Bounded.append`
        Bounded.word32 (Crc32c.chunks 0 postCrc)
      )
    ) postCrc
  where
  postCrc :: Chunks
  postCrc = ChunksCons
    ( Bytes.fromByteArray $ Bounded.run Nat.constant
      ( Bounded.word16 attributes
        `Bounded.append`
        Bounded.int32 lastOffsetDelta
        `Bounded.append`
        Bounded.int64 baseTimestamp
        `Bounded.append`
        Bounded.int64 maxTimestamp
        `Bounded.append`
        Bounded.int64 producerId
        `Bounded.append`
        Bounded.int16 producerEpoch
        `Bounded.append`
        Bounded.int32 baseSequence
        `Bounded.append`
        Bounded.int32 recordsCount
      )
    ) recordsPayload
