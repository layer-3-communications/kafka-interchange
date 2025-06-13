module Kafka.Metadata.Request.V11
  ( module X
  ) where

-- The only differences between V11 and V12 of the metadata API are:
--
-- * V11 does not correctly support providing a topic ID, so the topic must
--   be set to zero in the request.
-- * In V12, the topic names in the response are nullable.
--
-- The data types, builders, and parsers work out so that they can be used
-- for either V11 or V12.
import Kafka.Metadata.Request.V12 as X
