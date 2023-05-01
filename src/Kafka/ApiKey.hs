{-# language PatternSynonyms #-}

module Kafka.ApiKey
  ( pattern Produce
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

pattern Produce :: Int16
pattern Produce = 0

pattern Fetch :: Int16
pattern Fetch = 1

pattern ListOffsets :: Int16
pattern ListOffsets = 2

pattern Metadata :: Int16
pattern Metadata = 3

pattern LeaderAndIsr :: Int16
pattern LeaderAndIsr = 4

pattern StopReplica :: Int16
pattern StopReplica = 5

pattern UpdateMetadata :: Int16
pattern UpdateMetadata = 6

pattern ControlledShutdown :: Int16
pattern ControlledShutdown = 7

pattern OffsetCommit :: Int16
pattern OffsetCommit = 8

pattern OffsetFetch :: Int16
pattern OffsetFetch = 9

pattern FindCoordinator :: Int16
pattern FindCoordinator = 10

pattern JoinGroup :: Int16
pattern JoinGroup = 11

pattern Heartbeat :: Int16
pattern Heartbeat = 12

pattern LeaveGroup :: Int16
pattern LeaveGroup = 13

pattern SyncGroup :: Int16
pattern SyncGroup = 14

pattern DescribeGroups :: Int16
pattern DescribeGroups = 15

pattern ListGroups :: Int16
pattern ListGroups = 16

pattern SaslHandshake :: Int16
pattern SaslHandshake = 17

pattern ApiVersions :: Int16
pattern ApiVersions = 18

pattern CreateTopics :: Int16
pattern CreateTopics = 19

pattern DeleteTopics :: Int16
pattern DeleteTopics = 20

pattern DeleteRecords :: Int16
pattern DeleteRecords = 21

pattern InitProducerId :: Int16
pattern InitProducerId = 22

pattern OffsetForLeaderEpoch :: Int16
pattern OffsetForLeaderEpoch = 23

pattern AddPartitionsToTxn :: Int16
pattern AddPartitionsToTxn = 24

pattern AddOffsetsToTxn :: Int16
pattern AddOffsetsToTxn = 25

pattern EndTxn :: Int16
pattern EndTxn = 26

pattern WriteTxnMarkers :: Int16
pattern WriteTxnMarkers = 27

pattern TxnOffsetCommit :: Int16
pattern TxnOffsetCommit = 28

pattern DescribeAcls :: Int16
pattern DescribeAcls = 29

pattern CreateAcls :: Int16
pattern CreateAcls = 30

pattern DeleteAcls :: Int16
pattern DeleteAcls = 31

pattern DescribeConfigs :: Int16
pattern DescribeConfigs = 32

pattern AlterConfigs :: Int16
pattern AlterConfigs = 33

pattern AlterReplicaLogDirs :: Int16
pattern AlterReplicaLogDirs = 34

pattern DescribeLogDirs :: Int16
pattern DescribeLogDirs = 35

pattern SaslAuthenticate :: Int16
pattern SaslAuthenticate = 36

pattern CreatePartitions :: Int16
pattern CreatePartitions = 37

pattern CreateDelegationToken :: Int16
pattern CreateDelegationToken = 38

pattern RenewDelegationToken :: Int16
pattern RenewDelegationToken = 39

pattern ExpireDelegationToken :: Int16
pattern ExpireDelegationToken = 40

pattern DescribeDelegationToken :: Int16
pattern DescribeDelegationToken = 41

pattern DeleteGroups :: Int16
pattern DeleteGroups = 42

pattern ElectLeaders :: Int16
pattern ElectLeaders = 43

pattern IncrementalAlterConfigs :: Int16
pattern IncrementalAlterConfigs = 44

pattern AlterPartitionReassignments :: Int16
pattern AlterPartitionReassignments = 45

pattern ListPartitionReassignments :: Int16
pattern ListPartitionReassignments = 46

pattern OffsetDelete :: Int16
pattern OffsetDelete = 47
