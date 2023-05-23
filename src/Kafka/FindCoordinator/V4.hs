module Kafka.FindCoordinator.V4
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.FindCoordinator.Request.V4 as Rqst
import qualified Kafka.FindCoordinator.Response.V4 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 4

apiKey :: K.ApiKey
apiKey = K.FindCoordinator
