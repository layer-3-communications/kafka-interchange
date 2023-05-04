{-# language BangPatterns #-}
{-# language NumericUnderscores #-}
{-# language DuplicateRecordFields #-}
{-# language OverloadedRecordDot #-}

module Exchange
  ( exchange
  ) where

import Channel (M)
import Communication (Request,Response)
import Data.Int (Int32)
import Data.Bytes.Types (Bytes(Bytes))
import Control.Monad (when)
import Kafka.Exchange.Error (Error(Error),Message(..))

import qualified Kafka.Interchange.Message.Request.V2 as Message.Request
import qualified Kafka.Interchange.Header.Response.V0 as Header.Response.V0
import qualified Kafka.Interchange.Header.Response.V1 as Header.Response.V1
import qualified Data.Bytes.Parser as Parser
import qualified Kafka.Parser.Context as Ctx
import qualified Channel
import qualified Communication
import qualified Data.Primitive.ByteArray.BigEndian as BigEndian
import qualified Kafka.Exchange.Error

exchange :: Request -> M Response
exchange inner = do
  clientId <- Channel.clientId
  correlationId <- Channel.nextCorrelationId
  let !hdr = Message.Request.Header
        { apiKey = Communication.apiKey
        , apiVersion = Communication.apiVersion
        , correlationId = correlationId
        , clientId = Just clientId
        }
  let !req = Message.Request.Request
        { header = hdr
        , body = Communication.toChunks inner
        }
  let enc = Message.Request.toChunks req
  Channel.send Error{context=hdr,message=RequestMessageNotSent} enc
  rawSz <- Channel.receiveExactly Error{context=hdr,message=ResponseLengthNotReceived} 4
  let sz = BigEndian.indexByteArray rawSz 0 :: Int32
  when (sz < 0) (Channel.throw Error{context=hdr,message=ResponseLengthNegative})
  -- Technically, there's nothing wrong with a response that is
  -- larger than 512MB. It's just not going to happen in practice.
  when (sz >= 512_000_000) (Channel.throw Error{context=hdr,message=ResponseLengthTooHigh})
  byteArray <- Channel.receiveExactly Error{context=hdr,message=ResponseMessageNotReceived} (fromIntegral sz)
  payload <- case Communication.responseHeaderVersion of
    0 ->  case Parser.parseByteArray (Header.Response.V0.parser Ctx.Top) byteArray of
      Parser.Failure _ -> Channel.throw Error{context=hdr,message=ResponseHeaderMalformed}
      Parser.Success (Parser.Slice off len respHdr) -> if respHdr.correlationId == correlationId
        then pure (Bytes byteArray off len)
        else Channel.throw Error{context=hdr,message=ResponseIncorrectCorrelationId}
    1 -> case Parser.parseByteArray (Header.Response.V1.parser Ctx.Top) byteArray of
      Parser.Failure _ -> Channel.throw Error{context=hdr,message=ResponseHeaderMalformed}
      Parser.Success (Parser.Slice off len respHdr) -> if respHdr.correlationId == correlationId
        then pure (Bytes byteArray off len)
        else Channel.throw Error{context=hdr,message=ResponseIncorrectCorrelationId}
    _ -> Channel.throw Error{context=hdr,message=ResponseHeaderVersionUnsupported}
  case Communication.decode payload of
    Left _ -> Channel.throw Error{context=hdr,message=ResponseBodyMalformed}
    Right r -> pure r
    
