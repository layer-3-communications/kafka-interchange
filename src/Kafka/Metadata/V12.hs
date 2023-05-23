module Kafka.Metadata.V12
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.Metadata.Request.V12 as Rqst
import qualified Kafka.Metadata.Response.V12 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 12

apiKey :: K.ApiKey
apiKey = K.Metadata
