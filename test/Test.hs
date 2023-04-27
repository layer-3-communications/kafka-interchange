{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}

module Main (main) where

import Data.Int
import Data.Primitive.ByteArray
import Data.Word
import Test.Tasty
import Test.Tasty.Golden
import Prelude hiding (readFile)
import Data.Bytes (Bytes)
import Data.Bytes.Chunks (Chunks)
import Data.Bytes.Parser (Parser)
import Kafka.Parser.Context (Context)
import Text.Show.Pretty (ppShow)

import qualified Kafka.Interchange.ApiVersions.Response.V3
import qualified Test.Tasty.Golden.Advanced as Advanced
import qualified Data.ByteString.Char8 as BC8
import qualified Data.Bytes.Chunks as Chunks
import qualified Data.Primitive as PM
import qualified Data.Bytes.Parser as Parser
import qualified Data.Bytes as Bytes
import qualified Data.Bytes.Text.Latin1 as Latin1
import qualified Data.Bytes.Parser.Latin as Latin
import qualified Data.ByteString.Lazy.Char8 as LBC8
import qualified Data.ByteString.Base16 as Base16
import qualified Kafka.Interchange.Produce.Request.V9 as ProduceReqV9
import qualified Kafka.Interchange.Produce.Response.V9
import qualified Kafka.Interchange.ApiVersions.Request.V3 as ApiVersionsReqV3
import qualified Kafka.Interchange.Message.Request.V2 as Req
import qualified Kafka.Data.RecordBatch as RecordBatch
import qualified Kafka.Data.Record as Record
import qualified GHC.Exts as Exts
import qualified Kafka.Data.Acknowledgments as Acknowledgments

main :: IO ()
main = defaultMain $ testGroup "kafka"
  [ goldenHex
      "produce-request-v9-001"
      "golden/produce-request/v9/001.txt"
      produceRequestV9_001
  , goldenHex
      "produce-request-v9-002"
      "golden/produce-request/v9/002.txt"
      produceRequestV9_002
  , goldenHex
      "produce-request-v9-003"
      "golden/produce-request/v9/003.txt"
      produceRequestV9_003
  , goldenHex
      "api-versions-request-v3-001"
      "golden/api-versions-request/v3/001.txt"
      apiVersionsRequestV3_001
  , goldenHexDecode
      "api-versions-request-v3-001"
      Kafka.Interchange.ApiVersions.Response.V3.decode
      "golden/api-versions-response/v3/001.input.txt"
      "golden/api-versions-response/v3/001.output.txt"
  , goldenHexDecode
      "produce-response-v9-001"
      Kafka.Interchange.Produce.Response.V9.decode
      "golden/produce-response/v9/001.input.txt"
      "golden/produce-response/v9/001.output.txt"
  ]

apiVersionsRequestV3_001 :: Chunks
apiVersionsRequestV3_001 =
  let encApiVersionsReq = ApiVersionsReqV3.toChunks ApiVersionsReqV3.Request
        { clientSoftwareName = "apache-kafka-java"
        , clientSoftwareVersion = "3.3.1"
        }
      req = Req.Request
        { header = Req.Header
          { apiKey = ApiVersionsReqV3.apiKey
          , apiVersion = ApiVersionsReqV3.apiVersion
          , correlationId = 0
          , clientId = Just "admin-1"
          }
        , body = encApiVersionsReq
        }
   in Req.toChunks req

produceRequestV9_001 :: Chunks
produceRequestV9_001 =
  let record = Record.Record
        { timestampDelta = 0
        , offsetDelta = 0
        , key = Bytes.empty
        , value = Latin1.fromString "abcdefghijklmnopqrst"
        , headers = mempty
        }
      produceReq = ProduceReqV9.Request
        { transactionalId = Nothing
        , acks = Acknowledgments.FullIsr
        , timeoutMilliseconds = 1500
        , topicData = Exts.fromList
          [ ProduceReqV9.Topic
            { name = "example"
            , partitions = Exts.fromList
              [ ProduceReqV9.Partition
                { index = 0
                , records = RecordBatch.RecordBatch
                  { baseOffset = 0
                  , partitionLeaderEpoch = (-1)
                  , attributes = 0x0000
                  , lastOffsetDelta = 0
                  , baseTimestamp = 0x0000_0185_e070_6054
                  , maxTimestamp = 0x0000_0185_e070_6054
                  , producerId = 0x0000_0000_0000_03eb
                  , producerEpoch = 0
                  , baseSequence = 0
                  , recordsCount = 1
                  , recordsPayload = Record.toChunks record
                  }
                }
              ]
            }
          ]
        }
      encProduceReq = ProduceReqV9.toChunks produceReq
      req = Req.Request
        { header = Req.Header
          { apiKey = ProduceReqV9.apiKey
          , apiVersion = ProduceReqV9.apiVersion
          , correlationId = 4
          , clientId = Just "console-producer"
          } 
        , body = encProduceReq
        }
   in Req.toChunks req

produceRequestV9_002 :: Chunks
produceRequestV9_002 =
  let record = Record.Record
        { timestampDelta = 0
        , offsetDelta = 0
        , key = Latin1.fromString "thekey"
        , value = Latin1.fromString "Gotham City is in trouble"
        , headers = Exts.fromList
            [ Record.Header
                { key = "sender"
                , value = Latin1.fromString "jdoe"
                }
            , Record.Header
                { key = "recipient"
                , value = Latin1.fromString "batman"
                }
            ]
        }
      produceReq = ProduceReqV9.Request
        { transactionalId = Nothing
        , acks = Acknowledgments.FullIsr
        , timeoutMilliseconds = 1500
        , topicData = Exts.fromList
          [ ProduceReqV9.Topic
            { name = "incidents"
            , partitions = Exts.fromList
              [ ProduceReqV9.Partition
                { index = 0
                , records = RecordBatch.RecordBatch
                  { baseOffset = 0
                  , partitionLeaderEpoch = (-1)
                  , attributes = 0x0000
                  , lastOffsetDelta = 0
                  , baseTimestamp = 0x0000_0187_2e52_5e0e
                  , maxTimestamp = 0x0000_0187_2e52_5e0e
                  , producerId = 0x0000_0000_0000_0000
                  , producerEpoch = 0
                  , baseSequence = 0
                  , recordsCount = 1
                  , recordsPayload = Record.toChunks record
                  }
                }
              ]
            }
          ]
        }
      encProduceReq = ProduceReqV9.toChunks produceReq
      req = Req.Request
        { header = Req.Header
          { apiKey = ProduceReqV9.apiKey
          , apiVersion = ProduceReqV9.apiVersion
          , correlationId = 5
          , clientId = Just "console-producer"
          } 
        , body = encProduceReq
        }
   in Req.toChunks req

produceRequestV9_003 :: Chunks
produceRequestV9_003 =
  let records =
        [ Record.Record
          { timestampDelta = 0
          , offsetDelta = 0
          , key = Bytes.empty
          , value = Latin1.fromString "healthy"
          , headers = Exts.fromList
              [ Record.Header
                  { key = "host"
                  , value = Latin1.fromString "example.com"
                  }
              ]
          }
        , Record.Record
          { timestampDelta = 12
          , offsetDelta = 1
          , key = Bytes.empty
          , value = Latin1.fromString "unhealthy"
          , headers = Exts.fromList
              [ Record.Header
                  { key = "host"
                  , value = Latin1.fromString "example.com"
                  }
              ]
          }
        , Record.Record
          { timestampDelta = 12
          , offsetDelta = 2
          , key = Bytes.empty
          , value = Latin1.fromString "healthy"
          , headers = Exts.fromList
              [ Record.Header
                  { key = "host"
                  , value = Latin1.fromString "foo.example.com"
                  }
              ]
          }
        ]
      produceReq = ProduceReqV9.Request
        { transactionalId = Nothing
        , acks = Acknowledgments.FullIsr
        , timeoutMilliseconds = 1500
        , topicData = Exts.fromList
          [ ProduceReqV9.Topic
            { name = "incidents"
            , partitions = Exts.fromList
              [ ProduceReqV9.Partition
                { index = 0
                , records = RecordBatch.RecordBatch
                  { baseOffset = 0
                  , partitionLeaderEpoch = (-1)
                  , attributes = 0x0000
                  , lastOffsetDelta = 2
                  , baseTimestamp = 0x0000_0187_2efb_bd01
                  , maxTimestamp = 0x0000_0187_2efb_bd0d
                  , producerId = 0x0000_0000_0000_03e8
                  , producerEpoch = 0
                  , baseSequence = 0
                  , recordsCount = 3
                  , recordsPayload = foldMap Record.toChunks records
                  }
                }
              ]
            }
          ]
        }
      encProduceReq = ProduceReqV9.toChunks produceReq
      req = Req.Request
        { header = Req.Header
          { apiKey = ProduceReqV9.apiKey
          , apiVersion = ProduceReqV9.apiVersion
          , correlationId = 4
          , clientId = Just "console-producer"
          } 
        , body = encProduceReq
        }
   in Req.toChunks req

goldenHexDecode
  :: Show a
  => TestName -- ^ test name
  -> (Bytes -> Either Context a)
  -> FilePath -- ^ path to the hex file to be decoded
  -> FilePath -- ^ path to the golden file with the expected result of Show
  -> TestTree
goldenHexDecode name decode src ref = Advanced.goldenTest
  name
  (fmap Latin1.toString (Bytes.readFile ref))
  (do contents <- Bytes.readFile src
      case cleanAsciiHex contents of
        Nothing -> fail "input file was malformed"
        Just contents' -> case decode (Bytes.fromByteArray contents') of
          Left e -> fail (show e)
          Right r -> pure (ppShow r)
  )
  (\expected actual -> pure $ if expected == actual
    then Nothing
    else Just $ concat
      [ "Test output did not match.\nExpected:\n"
      , expected
      , "\nGot:\n"
      , actual
      , "\n"
      ]
  )
  upd
  where
  upd str = createDirectoriesAndWriteFile ref (LBC8.pack str)

-- | Compare a given string against the golden file's contents.
goldenHex
  :: TestName -- ^ test name
  -> FilePath -- ^ path to the golden file (the file that contains correct output)
  -> Chunks.Chunks -- ^ action that returns a string
  -> TestTree -- ^ the test verifies that the returned string is the same as the golden file contents
goldenHex name ref act = Advanced.goldenTest
  name
  ((maybe (fail "expected output malformed") pure . cleanAsciiHex) =<< Bytes.readFile ref)
  (pure (Chunks.concatU act))
  (\expected actual -> pure $ if expected == actual
    then Nothing
    else Just $ concat
      [ "Test output did not match.\nExpected:\n"
      , prettyByteArray expected
      , "\nGot:\n"
      , prettyByteArray actual
      , "\n"
      ]
  )
  upd
  where
  upd bytes = createDirectoriesAndWriteFile ref
    $ LBC8.pack
    $ prettyByteArray bytes

prettyByteArray :: ByteArray -> String
prettyByteArray =
    injectSpaces
  . BC8.unpack
  . Base16.encode
  . Bytes.toByteString
  . Bytes.fromByteArray

injectSpaces :: String -> String
injectSpaces (w0 : w1 : w2 : w3 : w4 : w5 : w6 : w7 : w8 : w9 : w10 : w11 : w12 : w13 : w14 : w15 : zs) =
  w0 : w1 : ' ' : w2 : w3 : ' ' : w4 : w5 : ' ' : w6 : w7 : ' ' : w8 : w9 : ' ' : w10 : w11 : ' ' : w12 : w13 : ' ' : w14 : w15 : '\n' : injectSpaces zs
injectSpaces (x : y : zs) = x : y : ' ' : injectSpaces zs
injectSpaces [] = []
injectSpaces _ = error "injectSpaces: expected an even number of characters"

cleanAsciiHex :: Bytes -> Maybe ByteArray
cleanAsciiHex =
    decodeSpacedHex
  . Bytes.intercalate (Bytes.singleton 0x20)
  . fmap (Bytes.takeWhile (/= 0x23))
  . Bytes.split 0x0A
  . Bytes.dropWhileEnd (==0x20)
  . Bytes.dropWhile (==0x20)

-- | Decode a byte sequence that looks like this:
--
-- > cd 0a bf ea 09 ...
--
-- There must be one or more space between each two-character representation
-- of an octet.
decodeSpacedHex :: Bytes -> Maybe ByteArray
decodeSpacedHex !b = Parser.parseBytesMaybe
  ( do let len = Bytes.length b
       dst <- Parser.effect (PM.newByteArray (len + 1))
       Parser.effect (PM.setByteArray dst 0 len (0 :: Word8))
       Latin.skipChar ' '
       parserSpacedHex dst 0
  ) b

parserSpacedHex :: MutableByteArray s -> Int -> Parser () s ByteArray
parserSpacedHex !dst !ix = do
  w <- Latin.hexFixedWord8 ()
  Parser.effect (PM.writeByteArray dst ix w)
  Parser.isEndOfInput >>= \case
    False -> do
      Latin.skipChar1 () ' '
      Parser.isEndOfInput >>= \case
        True -> Parser.effect $ do
          PM.shrinkMutableByteArray dst (ix + 1)
          PM.unsafeFreezeByteArray dst
        False -> parserSpacedHex dst (ix + 1)
    True -> Parser.effect $ do
      PM.shrinkMutableByteArray dst (ix + 1)
      PM.unsafeFreezeByteArray dst
