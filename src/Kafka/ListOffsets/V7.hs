module Kafka.ListOffsets.V7
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.ListOffsets.Request.V7 as Rqst
import qualified Kafka.ListOffsets.Response.V7 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 7

apiKey :: K.ApiKey
apiKey = K.ListOffsets
