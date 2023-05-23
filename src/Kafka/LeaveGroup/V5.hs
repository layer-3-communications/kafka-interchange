module Kafka.LeaveGroup.V5
  ( Rqst.Request
  , Resp.Response
  , Rqst.toChunks
  , Resp.decode
  , apiKey
  , apiVersion
  , responseHeaderVersion
  ) where

import Data.Int (Int16)

import qualified Kafka.LeaveGroup.Request.V5 as Rqst
import qualified Kafka.LeaveGroup.Response.V5 as Resp
import qualified Kafka.ApiKey as K

responseHeaderVersion :: Int16
responseHeaderVersion = 1

apiVersion :: Int16
apiVersion = 5

apiKey :: K.ApiKey
apiKey = K.LeaveGroup
