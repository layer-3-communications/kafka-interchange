module Kafka.Produce.V9
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.Produce.Request.V9 as Rqst
import qualified Kafka.Produce.Response.V9 as Resp

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 9

apiKey :: Int16
apiKey = 0
