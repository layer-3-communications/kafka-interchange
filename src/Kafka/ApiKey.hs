{-# language DerivingStrategies #-}
{-# language GeneralizedNewtypeDeriving #-}
{-# language PatternSynonyms #-}

module Kafka.ApiKey
  ( -- * Type
    ApiKey(..)
    -- * Patterns
  , pattern Produce
  , pattern Fetch
  , pattern ListOffsets
  , pattern Metadata
  , pattern LeaderAndIsr
  , pattern StopReplica
  , pattern UpdateMetadata
  , pattern ControlledShutdown
  , pattern OffsetCommit
  , pattern OffsetFetch
  , pattern FindCoordinator
  , pattern JoinGroup
  , pattern Heartbeat
  , pattern LeaveGroup
  , pattern SyncGroup
  , pattern DescribeGroups
  , pattern ListGroups
  , pattern SaslHandshake
  , pattern ApiVersions
  , pattern CreateTopics
  , pattern DeleteTopics
  , pattern DeleteRecords
  , pattern InitProducerId
  , pattern OffsetForLeaderEpoch
  , pattern AddPartitionsToTxn
  , pattern AddOffsetsToTxn
  , pattern EndTxn
  , pattern WriteTxnMarkers
  , pattern TxnOffsetCommit
  , pattern DescribeAcls
  , pattern CreateAcls
  , pattern DeleteAcls
  , pattern DescribeConfigs
  , pattern AlterConfigs
  , pattern AlterReplicaLogDirs
  , pattern DescribeLogDirs
  , pattern SaslAuthenticate
  , pattern CreatePartitions
  , pattern CreateDelegationToken
  , pattern RenewDelegationToken
  , pattern ExpireDelegationToken
  , pattern DescribeDelegationToken
  , pattern DeleteGroups
  , pattern ElectLeaders
  , pattern IncrementalAlterConfigs
  , pattern AlterPartitionReassignments
  , pattern ListPartitionReassignments
  , pattern OffsetDelete
  ) where

import Data.Int (Int16)

-- | An ApiKey. This is given its own type because it improves a lot
-- of derived 'Show' instances and because it makes several type
-- signatures more clear.
newtype ApiKey = ApiKey Int16
  deriving newtype (Eq)

instance Show ApiKey where
  showsPrec _ (ApiKey k) s = case k of
    0  -> "Produce" ++ s
    1  -> "Fetch" ++ s
    2  -> "ListOffsets" ++ s
    3  -> "Metadata" ++ s
    4  -> "LeaderAndIsr" ++ s
    5  -> "StopReplica" ++ s
    6  -> "UpdateMetadata" ++ s
    7  -> "ControlledShutdown" ++ s
    8  -> "OffsetCommit" ++ s
    9  -> "OffsetFetch" ++ s
    10 -> "FindCoordinator" ++ s
    11 -> "JoinGroup" ++ s
    12 -> "Heartbeat" ++ s
    13 -> "LeaveGroup" ++ s
    14 -> "SyncGroup" ++ s
    15 -> "DescribeGroups" ++ s
    16 -> "ListGroups" ++ s
    17 -> "SaslHandshake" ++ s
    18 -> "ApiVersions" ++ s
    19 -> "CreateTopics" ++ s
    20 -> "DeleteTopics" ++ s
    21 -> "DeleteRecords" ++ s
    22 -> "InitProducerId" ++ s
    23 -> "OffsetForLeaderEpoch" ++ s
    24 -> "AddPartitionsToTxn" ++ s
    25 -> "AddOffsetsToTxn" ++ s
    26 -> "EndTxn" ++ s
    27 -> "WriteTxnMarkers" ++ s
    28 -> "TxnOffsetCommit" ++ s
    29 -> "DescribeAcls" ++ s
    30 -> "CreateAcls" ++ s
    31 -> "DeleteAcls" ++ s
    32 -> "DescribeConfigs" ++ s
    33 -> "AlterConfigs" ++ s
    34 -> "AlterReplicaLogDirs" ++ s
    35 -> "DescribeLogDirs" ++ s
    36 -> "SaslAuthenticate" ++ s
    37 -> "CreatePartitions" ++ s
    38 -> "CreateDelegationToken" ++ s
    39 -> "RenewDelegationToken" ++ s
    40 -> "ExpireDelegationToken" ++ s
    41 -> "DescribeDelegationToken" ++ s
    42 -> "DeleteGroups" ++ s
    43 -> "ElectLeaders" ++ s
    44 -> "IncrementalAlterConfigs" ++ s
    45 -> "AlterPartitionReassignments" ++ s
    46 -> "ListPartitionReassignments" ++ s
    47 -> "OffsetDelete" ++ s
    48 -> "DescribeClientQuotas" ++ s
    49 -> "AlterClientQuotas" ++ s
    50 -> "DescribeUserScramCredentials" ++ s
    51 -> "AlterUserScramCredentials" ++ s
    55 -> "DescribeQuorum" ++ s
    56 -> "AlterPartition" ++ s
    57 -> "UpdateFeatures" ++ s
    58 -> "Envelope" ++ s
    60 -> "DescribeCluster" ++ s
    61 -> "DescribeProducers" ++ s
    64 -> "UnregisterBroker" ++ s
    65 -> "DescribeTransactions" ++ s
    66 -> "ListTransactions" ++ s
    67 -> "AllocateProducerIds" ++ s
    _ -> "(ApiKey " ++ shows k (')':s)

pattern Produce :: ApiKey
pattern Produce = ApiKey 0

pattern Fetch :: ApiKey
pattern Fetch = ApiKey 1

pattern ListOffsets :: ApiKey
pattern ListOffsets = ApiKey 2

pattern Metadata :: ApiKey
pattern Metadata = ApiKey 3

pattern LeaderAndIsr :: ApiKey
pattern LeaderAndIsr = ApiKey 4

pattern StopReplica :: ApiKey
pattern StopReplica = ApiKey 5

pattern UpdateMetadata :: ApiKey
pattern UpdateMetadata = ApiKey 6

pattern ControlledShutdown :: ApiKey
pattern ControlledShutdown = ApiKey 7

pattern OffsetCommit :: ApiKey
pattern OffsetCommit = ApiKey 8

pattern OffsetFetch :: ApiKey
pattern OffsetFetch = ApiKey 9

pattern FindCoordinator :: ApiKey
pattern FindCoordinator = ApiKey 10

pattern JoinGroup :: ApiKey
pattern JoinGroup = ApiKey 11

pattern Heartbeat :: ApiKey
pattern Heartbeat = ApiKey 12

pattern LeaveGroup :: ApiKey
pattern LeaveGroup = ApiKey 13

pattern SyncGroup :: ApiKey
pattern SyncGroup = ApiKey 14

pattern DescribeGroups :: ApiKey
pattern DescribeGroups = ApiKey 15

pattern ListGroups :: ApiKey
pattern ListGroups = ApiKey 16

pattern SaslHandshake :: ApiKey
pattern SaslHandshake = ApiKey 17

pattern ApiVersions :: ApiKey
pattern ApiVersions = ApiKey 18

pattern CreateTopics :: ApiKey
pattern CreateTopics = ApiKey 19

pattern DeleteTopics :: ApiKey
pattern DeleteTopics = ApiKey 20

pattern DeleteRecords :: ApiKey
pattern DeleteRecords = ApiKey 21

pattern InitProducerId :: ApiKey
pattern InitProducerId = ApiKey 22

pattern OffsetForLeaderEpoch :: ApiKey
pattern OffsetForLeaderEpoch = ApiKey 23

pattern AddPartitionsToTxn :: ApiKey
pattern AddPartitionsToTxn = ApiKey 24

pattern AddOffsetsToTxn :: ApiKey
pattern AddOffsetsToTxn = ApiKey 25

pattern EndTxn :: ApiKey
pattern EndTxn = ApiKey 26

pattern WriteTxnMarkers :: ApiKey
pattern WriteTxnMarkers = ApiKey 27

pattern TxnOffsetCommit :: ApiKey
pattern TxnOffsetCommit = ApiKey 28

pattern DescribeAcls :: ApiKey
pattern DescribeAcls = ApiKey 29

pattern CreateAcls :: ApiKey
pattern CreateAcls = ApiKey 30

pattern DeleteAcls :: ApiKey
pattern DeleteAcls = ApiKey 31

pattern DescribeConfigs :: ApiKey
pattern DescribeConfigs = ApiKey 32

pattern AlterConfigs :: ApiKey
pattern AlterConfigs = ApiKey 33

pattern AlterReplicaLogDirs :: ApiKey
pattern AlterReplicaLogDirs = ApiKey 34

pattern DescribeLogDirs :: ApiKey
pattern DescribeLogDirs = ApiKey 35

pattern SaslAuthenticate :: ApiKey
pattern SaslAuthenticate = ApiKey 36

pattern CreatePartitions :: ApiKey
pattern CreatePartitions = ApiKey 37

pattern CreateDelegationToken :: ApiKey
pattern CreateDelegationToken = ApiKey 38

pattern RenewDelegationToken :: ApiKey
pattern RenewDelegationToken = ApiKey 39

pattern ExpireDelegationToken :: ApiKey
pattern ExpireDelegationToken = ApiKey 40

pattern DescribeDelegationToken :: ApiKey
pattern DescribeDelegationToken = ApiKey 41

pattern DeleteGroups :: ApiKey
pattern DeleteGroups = ApiKey 42

pattern ElectLeaders :: ApiKey
pattern ElectLeaders = ApiKey 43

pattern IncrementalAlterConfigs :: ApiKey
pattern IncrementalAlterConfigs = ApiKey 44

pattern AlterPartitionReassignments :: ApiKey
pattern AlterPartitionReassignments = ApiKey 45

pattern ListPartitionReassignments :: ApiKey
pattern ListPartitionReassignments = ApiKey 46

pattern OffsetDelete :: ApiKey
pattern OffsetDelete = ApiKey 47
