{-# language BangPatterns #-}
{-# language ScopedTypeVariables #-}
{-# language LambdaCase #-}
{-# language NumericUnderscores #-}
{-# language DuplicateRecordFields #-}
{-# language OverloadedRecordDot #-}

module Exchange
  ( exchange
  ) where

import Channel (Environment,M)
import Error (Error)
import Communication (Request,Response,apiKey)

import Data.Int (Int32)
import Data.Bytes.Types (Bytes(Bytes))
import Control.Monad (when)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (ExceptT(ExceptT),runExceptT)

import qualified Kafka.Message.Request.V2 as Message.Request
import qualified Kafka.Header.Response.V0 as Header.Response.V0
import qualified Kafka.Header.Response.V1 as Header.Response.V1
import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Channel
import qualified Communication
import qualified Data.Primitive.ByteArray.BigEndian as BigEndian
import qualified Error

exchange :: Environment -> Request -> M (Either Error Response)
exchange env inner = runExceptT $ do
  let clientId = Channel.clientId env
  let resource = Channel.resource env
  correlationId <- lift (Channel.nextCorrelationId env)
  let !hdr = Message.Request.Header
        { apiKey = apiKey
        , apiVersion = Communication.apiVersion
        , correlationId = correlationId
        , clientId = Just clientId
        }
  let !req = Message.Request.Request
        { header = hdr
        , body = Communication.toChunks inner
        }
  let enc = Message.Request.toChunks req
  ExceptT $ Channel.send resource enc >>= \case
    Right (_ :: ()) -> pure (Right ())
    Left e -> pure (Left (Error.send apiKey e))
  rawSz <- ExceptT $ Channel.receiveExactly resource 4 >>= \case
    Right rawSz -> pure (Right rawSz)
    Left e -> pure (Left (Error.receiveLength apiKey e))
  let sz = BigEndian.indexByteArray rawSz 0 :: Int32
  when (sz < 0) (ExceptT (pure (Left (Error.responseLengthNegative apiKey))))
  -- Technically, there's nothing wrong with a response that is
  -- larger than 512MB. It's just not going to happen in practice.
  when (sz >= 512_000_000) (ExceptT (pure (Left (Error.responseLengthTooHigh apiKey))))
  byteArray <- ExceptT $ Channel.receiveExactly resource (fromIntegral sz) >>= \case
    Right byteArray -> pure (Right byteArray)
    Left e -> pure (Left (Error.receiveBody apiKey e))
  payload <- ExceptT $ case Communication.responseHeaderVersion of
    0 ->  case Parser.parseByteArray (Header.Response.V0.parser Ctx.Top) byteArray of
      Parser.Failure _ -> pure (Left (Error.responseHeaderMalformed apiKey))
      Parser.Success (Parser.Slice off len respHdr) -> if respHdr.correlationId == correlationId
        then pure (Right (Bytes byteArray off len))
        else pure (Left (Error.responseHeaderIncorrectCorrelationId apiKey))
    1 -> case Parser.parseByteArray (Header.Response.V1.parser Ctx.Top) byteArray of
      Parser.Failure _ -> pure (Left (Error.responseHeaderMalformed apiKey))
      Parser.Success (Parser.Slice off len respHdr) -> if respHdr.correlationId == correlationId
        then pure (Right (Bytes byteArray off len))
        else pure (Left (Error.responseHeaderIncorrectCorrelationId apiKey))
    _ -> errorWithoutStackTrace "kafka-interchange: huge mistake, expecting a response header version other than 0 or 1"
  case Communication.decode payload of
    Left _ -> ExceptT (pure (Left (Error.responseBodyMalformed apiKey)))
    Right r -> pure r
    

