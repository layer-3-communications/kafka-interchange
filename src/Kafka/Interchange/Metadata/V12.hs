module Kafka.Interchange.Metadata.V12
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.Interchange.Metadata.Request.V12 as Rqst
import qualified Kafka.Interchange.Metadata.Response.V12 as Resp

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 12

apiKey :: Int16
apiKey = 3
