module Client
  ( produceV9
  , apiVersionsV3
  , metadataV12
  ) where

import Channel (M)

import qualified Kafka.Interchange.Produce.V9
import qualified Produce.V9
import qualified Kafka.Interchange.ApiVersions.V3
import qualified ApiVersions.V3
import qualified Kafka.Interchange.Metadata.V12
import qualified Metadata.V12

produceV9 ::
     Kafka.Interchange.Produce.V9.Request
  -> M Kafka.Interchange.Produce.V9.Response
produceV9 = Produce.V9.exchange

apiVersionsV3 ::
     Kafka.Interchange.ApiVersions.V3.Request
  -> M Kafka.Interchange.ApiVersions.V3.Response
apiVersionsV3 = ApiVersions.V3.exchange

metadataV12 ::
     Kafka.Interchange.Metadata.V12.Request
  -> M Kafka.Interchange.Metadata.V12.Response
metadataV12 = Metadata.V12.exchange
