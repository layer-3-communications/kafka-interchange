{-# language DeriveAnyClass #-}
{-# language DerivingStrategies #-}

module Kafka.Exchange.Error
  ( Error(..)
  , Message(..)
  ) where

import Control.Exception (Exception)

import qualified Kafka.Interchange.Message.Request.V2 as Message.Request

data Error = Error
  { context :: !Message.Request.Header
    -- ^ This tells us what kind of request was made and
    -- what the correlation ID was.
  , message :: Message
    -- ^ What kind of failure happened?
  }
  deriving stock (Show)
  deriving anyclass (Exception)

data Message
  = RequestMessageNotSent
  | ResponseLengthNotReceived
  | ResponseLengthNegative
  | ResponseLengthTooHigh
  | ResponseMessageNotReceived
  | ResponseHeaderMalformed
  | ResponseBodyMalformed
  | ResponseHeaderVersionUnsupported
  | ResponseIncorrectCorrelationId
  deriving stock (Show)
