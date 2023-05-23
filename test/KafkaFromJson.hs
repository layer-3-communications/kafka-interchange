{-# language ScopedTypeVariables #-}
{-# language TemplateHaskell #-}

{-# OPTIONS_GHC -fno-warn-orphans #-}

module KafkaFromJson () where

import Data.WideWord (Word128)
import Data.Aeson (FromJSON,parseJSON)
import Data.Aeson.TH (deriveFromJSON,defaultOptions)
import Data.ByteString.Base16 (decodeBase16')
import Data.Bytes (Bytes)

import qualified Data.Aeson as Aeson
import qualified Data.Bytes as Bytes

import qualified Kafka.Fetch.Request.V13
import qualified Kafka.FindCoordinator.Request.V4
import qualified Kafka.InitProducerId.Request.V4
import qualified Kafka.JoinGroup.Request.V9
import qualified Kafka.ListOffsets.Request.V7
import qualified Kafka.Metadata.Request.V12
import qualified Kafka.Subscription.Request.V1
import qualified Kafka.SyncGroup.Request.V5
import qualified Kafka.OffsetFetch.Request.V8
import qualified Kafka.Heartbeat.Request.V4
import qualified Kafka.LeaveGroup.Request.V5

instance FromJSON Word128 where
  parseJSON = fmap fromInteger . parseJSON

instance FromJSON Bytes where
  parseJSON = Aeson.withText "Bytes" $ \t ->
    case decodeBase16' t of
      Left{} -> fail "not base16-encoded bytes"
      Right bs -> pure (Bytes.fromByteString bs)

$(deriveFromJSON defaultOptions ''Kafka.Metadata.Request.V12.Topic)
$(deriveFromJSON defaultOptions ''Kafka.Metadata.Request.V12.Request)
$(deriveFromJSON defaultOptions ''Kafka.InitProducerId.Request.V4.Request)
$(deriveFromJSON defaultOptions ''Kafka.FindCoordinator.Request.V4.Request)
$(deriveFromJSON defaultOptions ''Kafka.ListOffsets.Request.V7.Partition)
$(deriveFromJSON defaultOptions ''Kafka.ListOffsets.Request.V7.Topic)
$(deriveFromJSON defaultOptions ''Kafka.ListOffsets.Request.V7.Request)
$(deriveFromJSON defaultOptions ''Kafka.Fetch.Request.V13.Partition)
$(deriveFromJSON defaultOptions ''Kafka.Fetch.Request.V13.Topic)
$(deriveFromJSON defaultOptions ''Kafka.Fetch.Request.V13.Request)
$(deriveFromJSON defaultOptions ''Kafka.JoinGroup.Request.V9.Protocol)
$(deriveFromJSON defaultOptions ''Kafka.JoinGroup.Request.V9.Request)
$(deriveFromJSON defaultOptions ''Kafka.SyncGroup.Request.V5.Assignment)
$(deriveFromJSON defaultOptions ''Kafka.SyncGroup.Request.V5.Request)
$(deriveFromJSON defaultOptions ''Kafka.Subscription.Request.V1.Ownership)
$(deriveFromJSON defaultOptions ''Kafka.Subscription.Request.V1.Subscription)
$(deriveFromJSON defaultOptions ''Kafka.OffsetFetch.Request.V8.Topic)
$(deriveFromJSON defaultOptions ''Kafka.OffsetFetch.Request.V8.Group)
$(deriveFromJSON defaultOptions ''Kafka.OffsetFetch.Request.V8.Request)
$(deriveFromJSON defaultOptions ''Kafka.Heartbeat.Request.V4.Request)
$(deriveFromJSON defaultOptions ''Kafka.LeaveGroup.Request.V5.Member)
$(deriveFromJSON defaultOptions ''Kafka.LeaveGroup.Request.V5.Request)
