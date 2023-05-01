{-# language TemplateHaskell #-}

module KafkaFromJson () where

import Data.WideWord (Word128)
import Data.Aeson (FromJSON,parseJSON)
import Data.Aeson.TH (deriveFromJSON,defaultOptions)

import qualified Kafka.Interchange.Metadata.Request.V12

instance FromJSON Word128 where
  parseJSON = fmap fromInteger . parseJSON

$(deriveFromJSON defaultOptions ''Kafka.Interchange.Metadata.Request.V12.Topic)
$(deriveFromJSON defaultOptions ''Kafka.Interchange.Metadata.Request.V12.Request)
