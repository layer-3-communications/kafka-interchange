module Kafka.InitProducerId.V4
  ( Rqst.Request(Request)
  , Resp.Response(Response)
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.InitProducerId.Request.V4 as Rqst
import qualified Kafka.InitProducerId.Response.V4 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 4

apiKey :: K.ApiKey
apiKey = K.InitProducerId
