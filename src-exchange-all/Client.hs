module Client
  ( produceV9
  , apiVersionsV3
  , metadataV12
  , syncGroupV5
  , joinGroupV9
  , fetchV13
  , findCoordinatorV4
  , listOffsetsV7
  , initProducerIdV4
  ) where

import Channel (M)

import qualified Kafka.Interchange.Produce.V9
import qualified Produce.V9
import qualified Kafka.Interchange.ApiVersions.V3
import qualified ApiVersions.V3
import qualified Kafka.Interchange.Metadata.V12
import qualified Metadata.V12
import qualified Kafka.Interchange.SyncGroup.V5 as SyncGroup.V5
import qualified SyncGroup.V5
import qualified Kafka.Interchange.JoinGroup.V9 as JoinGroup.V9
import qualified JoinGroup.V9
import qualified Kafka.Interchange.Fetch.V13 as Fetch.V13
import qualified Fetch.V13
import qualified Kafka.Interchange.FindCoordinator.V4 as FindCoordinator.V4
import qualified FindCoordinator.V4
import qualified Kafka.Interchange.ListOffsets.V7 as ListOffsets.V7
import qualified ListOffsets.V7
import qualified Kafka.Interchange.InitProducerId.V4 as InitProducerId.V4
import qualified InitProducerId.V4

listOffsetsV7 ::
     ListOffsets.V7.Request
  -> M ListOffsets.V7.Response
listOffsetsV7 = ListOffsets.V7.exchange

findCoordinatorV4 ::
     FindCoordinator.V4.Request
  -> M FindCoordinator.V4.Response
findCoordinatorV4 = FindCoordinator.V4.exchange

initProducerIdV4 ::
     InitProducerId.V4.Request
  -> M InitProducerId.V4.Response
initProducerIdV4 = InitProducerId.V4.exchange

fetchV13 ::
     Fetch.V13.Request
  -> M Fetch.V13.Response
fetchV13 = Fetch.V13.exchange

joinGroupV9 ::
     JoinGroup.V9.Request
  -> M JoinGroup.V9.Response
joinGroupV9 = JoinGroup.V9.exchange

syncGroupV5 ::
     SyncGroup.V5.Request
  -> M SyncGroup.V5.Response
syncGroupV5 = SyncGroup.V5.exchange

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
