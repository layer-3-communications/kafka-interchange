module Kafka.JoinGroup.V9
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.JoinGroup.Request.V9 as Rqst
import qualified Kafka.JoinGroup.Response.V9 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 9

apiKey :: K.ApiKey
apiKey = K.JoinGroup
