module Kafka.Interchange.FindCoordinator.V4
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.Interchange.FindCoordinator.Request.V4 as Rqst
import qualified Kafka.Interchange.FindCoordinator.Response.V4 as Resp

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 4

apiKey :: Int16
apiKey = 10
