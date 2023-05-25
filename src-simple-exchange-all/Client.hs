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
  , offsetFetchV8
  , heartbeatV4
  , leaveGroupV5
  ) where

import Channel (M,Environment)
import Error (Error)

import qualified Kafka.Produce.V9
import qualified Produce.V9
import qualified Kafka.ApiVersions.V3
import qualified ApiVersions.V3
import qualified Kafka.Metadata.V12
import qualified Metadata.V12
import qualified Kafka.SyncGroup.V5 as SyncGroup.V5
import qualified SyncGroup.V5
import qualified Kafka.JoinGroup.V9 as JoinGroup.V9
import qualified JoinGroup.V9
import qualified Kafka.Fetch.V13 as Fetch.V13
import qualified Fetch.V13
import qualified Kafka.FindCoordinator.V4 as FindCoordinator.V4
import qualified FindCoordinator.V4
import qualified Kafka.ListOffsets.V7 as ListOffsets.V7
import qualified ListOffsets.V7
import qualified Kafka.InitProducerId.V4 as InitProducerId.V4
import qualified InitProducerId.V4
import qualified Kafka.OffsetFetch.V8 as OffsetFetch.V8
import qualified OffsetFetch.V8
import qualified Kafka.Heartbeat.V4 as Heartbeat.V4
import qualified Heartbeat.V4
import qualified Kafka.LeaveGroup.V5 as LeaveGroup.V5
import qualified LeaveGroup.V5

listOffsetsV7 ::
     Environment
  -> ListOffsets.V7.Request
  -> M (Either Error ListOffsets.V7.Response)
listOffsetsV7 = ListOffsets.V7.exchange

findCoordinatorV4 ::
     Environment
  -> FindCoordinator.V4.Request
  -> M (Either Error FindCoordinator.V4.Response)
findCoordinatorV4 = FindCoordinator.V4.exchange

heartbeatV4 ::
     Environment
  -> Heartbeat.V4.Request
  -> M (Either Error Heartbeat.V4.Response)
heartbeatV4 = Heartbeat.V4.exchange

leaveGroupV5 ::
     Environment
  -> LeaveGroup.V5.Request
  -> M (Either Error LeaveGroup.V5.Response)
leaveGroupV5 = LeaveGroup.V5.exchange

initProducerIdV4 ::
     Environment
  -> InitProducerId.V4.Request
  -> M (Either Error InitProducerId.V4.Response)
initProducerIdV4 = InitProducerId.V4.exchange

fetchV13 ::
     Environment
  -> Fetch.V13.Request
  -> M (Either Error Fetch.V13.Response)
fetchV13 = Fetch.V13.exchange

joinGroupV9 ::
     Environment
  -> JoinGroup.V9.Request
  -> M (Either Error JoinGroup.V9.Response)
joinGroupV9 = JoinGroup.V9.exchange

syncGroupV5 ::
     Environment
  -> SyncGroup.V5.Request
  -> M (Either Error SyncGroup.V5.Response)
syncGroupV5 = SyncGroup.V5.exchange

produceV9 ::
     Environment
  -> Kafka.Produce.V9.Request
  -> M (Either Error Kafka.Produce.V9.Response)
produceV9 = Produce.V9.exchange

apiVersionsV3 ::
     Environment
  -> Kafka.ApiVersions.V3.Request
  -> M (Either Error Kafka.ApiVersions.V3.Response)
apiVersionsV3 = ApiVersions.V3.exchange

metadataV12 ::
     Environment
  -> Kafka.Metadata.V12.Request
  -> M (Either Error Kafka.Metadata.V12.Response)
metadataV12 = Metadata.V12.exchange

offsetFetchV8 ::
     Environment
  -> OffsetFetch.V8.Request
  -> M (Either Error OffsetFetch.V8.Response)
offsetFetchV8 = OffsetFetch.V8.exchange
