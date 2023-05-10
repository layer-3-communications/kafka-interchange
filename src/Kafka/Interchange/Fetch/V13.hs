module Kafka.Interchange.Fetch.V13
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.Interchange.Fetch.Request.V13 as Rqst
import qualified Kafka.Interchange.Fetch.Response.V13 as Resp

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 13

apiKey :: Int16
apiKey = 1
