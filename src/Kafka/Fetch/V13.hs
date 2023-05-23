module Kafka.Fetch.V13
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.Fetch.Request.V13 as Rqst
import qualified Kafka.Fetch.Response.V13 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 13

apiKey :: K.ApiKey
apiKey = K.Fetch
