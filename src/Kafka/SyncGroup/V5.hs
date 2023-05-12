module Kafka.SyncGroup.V5
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.SyncGroup.Request.V5 as Rqst
import qualified Kafka.SyncGroup.Response.V5 as Resp

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 5

apiKey :: Int16
apiKey = 14
