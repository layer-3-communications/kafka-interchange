module Kafka.Interchange.ListOffsets.V7
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.Interchange.ListOffsets.Request.V7 as Rqst
import qualified Kafka.Interchange.ListOffsets.Response.V7 as Resp

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 7

apiKey :: Int16
apiKey = 2
