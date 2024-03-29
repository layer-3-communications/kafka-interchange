{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE ScopedTypeVariables #-}
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
import Kafka.Parser.Context (Context(Top))
import Text.Show.Pretty (ppShow)
import KafkaFromJson ()

import qualified Data.Aeson as Aeson
import qualified Data.Base16.Types
import qualified Data.ByteString.Base16 as Base16
import qualified Data.ByteString.Char8 as BC8
import qualified Data.ByteString.Lazy.Char8 as LBC8
import qualified Data.Bytes as Bytes
import qualified Data.Bytes.Chunks as Chunks
import qualified Data.Bytes.Parser as Parser
import qualified Data.Bytes.Parser.Latin as Latin
import qualified Data.Bytes.Text.Latin1 as Latin1
import qualified Data.List as List
import qualified Data.Primitive as PM
import qualified GHC.Exts as Exts
import qualified Kafka.Acknowledgments as Acknowledgments
import qualified Kafka.ApiKey as ApiKey
import qualified Kafka.ApiVersions.Request.V3 as ApiVersionsReqV3
import qualified Kafka.ApiVersions.Response.V3
import qualified Kafka.ApiVersions.V3 as ApiVersionsV3
import qualified Kafka.Fetch.Request.V13
import qualified Kafka.Fetch.Response.V13
import qualified Kafka.FindCoordinator.Request.V4
import qualified Kafka.FindCoordinator.Response.V4
import qualified Kafka.InitProducerId.Request.V4
import qualified Kafka.InitProducerId.Response.V4
import qualified Kafka.JoinGroup.Request.V9
import qualified Kafka.JoinGroup.Response.V9
import qualified Kafka.ListOffsets.Request.V7
import qualified Kafka.ListOffsets.Response.V7
import qualified Kafka.Message.Request.V2 as Req
import qualified Kafka.Metadata.Request.V12
import qualified Kafka.Metadata.Response.V12
import qualified Kafka.Produce.Request.V9 as ProduceReqV9
import qualified Kafka.Produce.Response.V9
import qualified Kafka.Produce.V9 as ProduceV9
import qualified Kafka.Record.Request as Record
import qualified Kafka.Record.Response
import qualified Kafka.RecordBatch.Request as RecordBatch
import qualified Kafka.Subscription.Request.V1
import qualified Kafka.Subscription.Response.V1
import qualified Kafka.SyncGroup.Request.V5
import qualified Kafka.SyncGroup.Response.V5
import qualified Kafka.OffsetFetch.Request.V8
import qualified Kafka.OffsetFetch.Response.V8
import qualified Kafka.Heartbeat.Request.V4
import qualified Kafka.Heartbeat.Response.V4
import qualified Kafka.LeaveGroup.Request.V5
import qualified Kafka.LeaveGroup.Response.V5
import qualified Test.Tasty.Golden.Advanced as Advanced

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
      Kafka.ApiVersions.Response.V3.decode
      "golden/api-versions-response/v3/001.input.txt"
      "golden/api-versions-response/v3/001.output.txt"
  , goldenHexDecode
      "produce-response-v9-001"
      Kafka.Produce.Response.V9.decode
      "golden/produce-response/v9/001.input.txt"
      "golden/produce-response/v9/001.output.txt"
  , goldenHexDecode
      "metadata-response-v12-001"
      Kafka.Metadata.Response.V12.decode
      "golden/metadata-response/v12/001.input.txt"
      "golden/metadata-response/v12/001.output.txt"
  , goldenHexEncode
      "metadata-request-v12-001"
      Kafka.Metadata.Request.V12.toChunks
      "golden/metadata-request/v12/001.input.json"
      "golden/metadata-request/v12/001.output.txt"
  , goldenHexDecode
      "init-producer-id-response-v4-001"
      Kafka.InitProducerId.Response.V4.decode
      "golden/init-producer-id-response/v4/001.input.txt"
      "golden/init-producer-id-response/v4/001.output.txt"
  , goldenHexEncode
      "init-producer-id-request-v4-001"
      Kafka.InitProducerId.Request.V4.toChunks
      "golden/init-producer-id-request/v4/001.input.json"
      "golden/init-producer-id-request/v4/001.output.txt"
  , goldenHexEncode
      "find-coordinator-request-v4-001"
      Kafka.FindCoordinator.Request.V4.toChunks
      "golden/find-coordinator-request/v4/001.input.json"
      "golden/find-coordinator-request/v4/001.output.txt"
  , goldenHexDecode
      "find-coordinator-response-v4-001"
      Kafka.FindCoordinator.Response.V4.decode
      "golden/find-coordinator-response/v4/001.input.txt"
      "golden/find-coordinator-response/v4/001.output.txt"
  , goldenHexEncode
      "list-offsets-request-v7-001"
      Kafka.ListOffsets.Request.V7.toChunks
      "golden/list-offsets-request/v7/001.input.json"
      "golden/list-offsets-request/v7/001.output.txt"
  , goldenHexDecode
      "list-offsets-response-v7-001"
      Kafka.ListOffsets.Response.V7.decode
      "golden/list-offsets-response/v7/001.input.txt"
      "golden/list-offsets-response/v7/001.output.txt"
  , goldenHexEncode
      "fetch-request-v13-001"
      Kafka.Fetch.Request.V13.toChunks
      "golden/fetch-request/v13/001.input.json"
      "golden/fetch-request/v13/001.output.txt"
  , goldenHexDecode
      "fetch-response-v13-001"
      Kafka.Fetch.Response.V13.decode
      "golden/fetch-response/v13/001.input.txt"
      "golden/fetch-response/v13/001.output.txt"
  , goldenHexDecode
      "records-001"
      (maybe (Left Top) Right . Kafka.Record.Response.decodeArray)
      "golden/records-response/001.input.txt"
      "golden/records-response/001.output.txt"
  , goldenHexEncode
      "join-group-request-v9-001"
      Kafka.JoinGroup.Request.V9.toChunks
      "golden/join-group-request/v9/001.input.json"
      "golden/join-group-request/v9/001.output.txt"
  , goldenHexEncode
      "join-group-request-v9-002"
      Kafka.JoinGroup.Request.V9.toChunks
      "golden/join-group-request/v9/002.input.json"
      "golden/join-group-request/v9/002.output.txt"
  , goldenHexDecode
      "join-group-response-v9-001"
      Kafka.JoinGroup.Response.V9.decode
      "golden/join-group-response/v9/001.input.txt"
      "golden/join-group-response/v9/001.output.txt"
  , goldenHexDecode
      "join-group-response-v9-002"
      Kafka.JoinGroup.Response.V9.decode
      "golden/join-group-response/v9/002.input.txt"
      "golden/join-group-response/v9/002.output.txt"
  , goldenHexEncode
      "offset-fetch-request-v8-001"
      Kafka.OffsetFetch.Request.V8.toChunks
      "golden/offset-fetch-request/v8/001.input.json"
      "golden/offset-fetch-request/v8/001.output.txt"
  , goldenHexDecode
      "offset-fetch-response-v8-001"
      Kafka.OffsetFetch.Response.V8.decode
      "golden/offset-fetch-response/v8/001.input.txt"
      "golden/offset-fetch-response/v8/001.output.txt"
  , goldenHexEncode
      "sync-group-request-v5-001"
      Kafka.SyncGroup.Request.V5.toChunks
      "golden/sync-group-request/v5/001.input.json"
      "golden/sync-group-request/v5/001.output.txt"
  , goldenHexDecode
      "sync-group-response-v5-001"
      Kafka.SyncGroup.Response.V5.decode
      "golden/sync-group-response/v5/001.input.txt"
      "golden/sync-group-response/v5/001.output.txt"
  , goldenHexEncode
      "subscription-request-v1-001"
      Kafka.Subscription.Request.V1.toChunks
      "golden/subscription-request/v1/001.input.json"
      "golden/subscription-request/v1/001.output.txt"
  , goldenHexDecode
      "subscription-response-v1-001"
      Kafka.Subscription.Response.V1.decode
      "golden/subscription-response/v1/001.input.txt"
      "golden/subscription-response/v1/001.output.txt"
  , goldenHexEncode
      "heartbeat-request-v4-001"
      Kafka.Heartbeat.Request.V4.toChunks
      "golden/heartbeat-request/v4/001.input.json"
      "golden/heartbeat-request/v4/001.output.txt"
  , goldenHexDecode
      "heartbeat-response-v4-001"
      Kafka.Heartbeat.Response.V4.decode
      "golden/heartbeat-response/v4/001.input.txt"
      "golden/heartbeat-response/v4/001.output.txt"
  , goldenHexEncode
      "leave-group-request-v5-001"
      Kafka.LeaveGroup.Request.V5.toChunks
      "golden/leave-group-request/v5/001.input.json"
      "golden/leave-group-request/v5/001.output.txt"
  , goldenHexDecode
      "leave-group-response-v5-001"
      Kafka.LeaveGroup.Response.V5.decode
      "golden/leave-group-response/v5/001.input.txt"
      "golden/leave-group-response/v5/001.output.txt"
  ]

apiVersionsRequestV3_001 :: Chunks
apiVersionsRequestV3_001 =
  let encApiVersionsReq = ApiVersionsReqV3.toChunks ApiVersionsReqV3.Request
        { clientSoftwareName = "apache-kafka-java"
        , clientSoftwareVersion = "3.3.1"
        }
      req = Req.Request
        { header = Req.Header
          { apiKey = ApiVersionsV3.apiKey
          , apiVersion = ApiVersionsV3.apiVersion
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
          { apiKey = ProduceV9.apiKey
          , apiVersion = ProduceV9.apiVersion
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
          { apiKey = ProduceV9.apiKey
          , apiVersion = ProduceV9.apiVersion
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
          { apiKey = ProduceV9.apiKey
          , apiVersion = ProduceV9.apiVersion
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
          Right r ->
            let s = ppShow r
             in case List.isSuffixOf "\n" s of
                  True -> pure s
                  False -> pure $ s ++ "\n"
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

goldenHexEncode :: forall a.
     Aeson.FromJSON a
  => TestName -- ^ test name
  -> (a -> Chunks.Chunks)
  -> FilePath -- ^ path to the json file to decode
  -> FilePath -- ^ path to the golden file (the file that contains correct output)
  -> TestTree
goldenHexEncode name encode src ref = Advanced.goldenTest
  name
  ((maybe (fail "expected output malformed") pure . cleanAsciiHex) =<< Bytes.readFile ref)
  (do Aeson.eitherDecodeFileStrict src >>= \case
        Left e -> fail e
        Right (r :: a) -> pure (Chunks.concatU (encode r))
  )
  (\expected actual -> pure $ if expected == actual
    then Nothing
    else Just $ concat
      [ "Test output did not match.\nExpected:\n"
      , prettyByteArray expected
      , "\nGot:\n"
      , prettyByteArray actual
      , "\nFirst differing byte at index "
      , show (findFirstDifferingByteIndex expected actual)
      , ".\n"
      ]
  )
  upd
  where
  upd bytes = createDirectoriesAndWriteFile ref
    $ LBC8.pack
    $ prettyByteArray bytes

findFirstDifferingByteIndex :: ByteArray -> ByteArray -> Int
findFirstDifferingByteIndex a b = go 0
  where
  len = min (PM.sizeofByteArray a) (PM.sizeofByteArray b)
  go !ix = if ix < len
    then if PM.indexByteArray a ix == (PM.indexByteArray b ix :: Word8)
      then go (ix + 1)
      else ix
    else len

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
  . Data.Base16.Types.extractBase16
  . Base16.encodeBase16'
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
