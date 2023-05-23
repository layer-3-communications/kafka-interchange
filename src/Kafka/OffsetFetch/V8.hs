module Kafka.OffsetFetch.V8
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.OffsetFetch.Request.V8 as Rqst
import qualified Kafka.OffsetFetch.Response.V8 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 8

apiKey :: K.ApiKey
apiKey = K.OffsetFetch

