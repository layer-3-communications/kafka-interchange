module Kafka.ApiVersions.V3
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.ApiVersions.Request.V3 as Rqst
import qualified Kafka.ApiVersions.Response.V3 as Resp

responseHeaderVersion :: Int16
responseHeaderVersion = 0

apiVersion :: Int16
apiVersion = 3

apiKey :: Int16
apiKey = 18
