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

import qualified Kafka.Interchange.Fetch.Request.V13
import qualified Kafka.Interchange.FindCoordinator.Request.V4
import qualified Kafka.Interchange.InitProducerId.Request.V4
import qualified Kafka.Interchange.JoinGroup.Request.V9
import qualified Kafka.Interchange.ListOffsets.Request.V7
import qualified Kafka.Interchange.Metadata.Request.V12
import qualified Kafka.Interchange.Subscription.Request.V1
import qualified Kafka.Interchange.SyncGroup.Request.V5

instance FromJSON Word128 where
  parseJSON = fmap fromInteger . parseJSON

instance FromJSON Bytes where
  parseJSON = Aeson.withText "Bytes" $ \t ->
    case decodeBase16' t of
      Left{} -> fail "not base16-encoded bytes"
      Right bs -> pure (Bytes.fromByteString bs)

$(deriveFromJSON defaultOptions ''Kafka.Interchange.Metadata.Request.V12.Topic)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.Metadata.Request.V12.Request)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.InitProducerId.Request.V4.Request)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.FindCoordinator.Request.V4.Request)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.ListOffsets.Request.V7.Partition)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.ListOffsets.Request.V7.Topic)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.ListOffsets.Request.V7.Request)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.Fetch.Request.V13.Partition)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.Fetch.Request.V13.Topic)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.Fetch.Request.V13.Request)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.JoinGroup.Request.V9.Protocol)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.JoinGroup.Request.V9.Request)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.SyncGroup.Request.V5.Assignment)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.SyncGroup.Request.V5.Request)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.Subscription.Request.V1.Ownership)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.Subscription.Request.V1.Subscription)
