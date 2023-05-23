module Kafka.Heartbeat.V4
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.Heartbeat.Request.V4 as Rqst
import qualified Kafka.Heartbeat.Response.V4 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 4

apiKey :: K.ApiKey
apiKey = K.Heartbeat
