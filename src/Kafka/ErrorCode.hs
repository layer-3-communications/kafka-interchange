{-# language DerivingStrategies #-}
{-# language GeneralizedNewtypeDeriving #-}
{-# language PatternSynonyms #-}

module Kafka.ErrorCode
  ( -- * Type
    ErrorCode(..)
    -- * Patterns
  , pattern UnknownServerError
  , pattern None
  , pattern OffsetOutOfRange
  , pattern CorruptMessage
  , pattern UnknownTopicOrPartition
  , pattern InvalidFetchSize
  , pattern LeaderNotAvailable
  , pattern NotLeaderOrFollower
  , pattern RequestTimedOut
  , pattern BrokerNotAvailable
  , pattern ReplicaNotAvailable
  , pattern MessageTooLarge
  , pattern StaleControllerEpoch
  , pattern OffsetMetadataTooLarge
  , pattern NetworkException
  , pattern CoordinatorLoadInProgress
  , pattern CoordinatorNotAvailable
  , pattern NotCoordinator
  , pattern InvalidTopicException
  , pattern RecordListTooLarge
  , pattern NotEnoughReplicas
  , pattern NotEnoughReplicasAfterAppend
  , pattern InvalidRequiredAcks
  , pattern IllegalGeneration
  , pattern InconsistentGroupProtocol
  , pattern InvalidGroupId
  , pattern UnknownMemberId
  , pattern InvalidSessionTimeout
  , pattern RebalanceInProgress
  , pattern InvalidCommitOffsetSize
  , pattern TopicAuthorizationFailed
  , pattern GroupAuthorizationFailed
  , pattern ClusterAuthorizationFailed
  , pattern InvalidTimestamp
  , pattern UnsupportedSaslMechanism
  , pattern IllegalSaslState
  , pattern UnsupportedVersion
  , pattern TopicAlreadyExists
  , pattern InvalidPartitions
  , pattern InvalidReplicationFactor
  , pattern InvalidReplicaAssignment
  , pattern InvalidConfig
  , pattern NotController
  , pattern InvalidRequest
  , pattern UnsupportedForMessageFormat
  , pattern PolicyViolation
  , pattern OutOfOrderSequenceNumber
  , pattern DuplicateSequenceNumber
  , pattern InvalidProducerEpoch
  , pattern InvalidTxnState
  , pattern InvalidProducerIdMapping
  , pattern InvalidTransactionTimeout
  , pattern ConcurrentTransactions
  , pattern TransactionCoordinatorFenced
  , pattern TransactionalIdAuthorizationFailed
  , pattern SecurityDisabled
  , pattern OperationNotAttempted
  , pattern KafkaStorageError
  , pattern LogDirNotFound
  , pattern SaslAuthenticationFailed
  , pattern UnknownProducerId
  , pattern ReassignmentInProgress
  , pattern DelegationTokenAuthDisabled
  , pattern DelegationTokenNotFound
  , pattern DelegationTokenOwnerMismatch
  , pattern DelegationTokenRequestNotAllowed
  , pattern DelegationTokenAuthorizationFailed
  , pattern DelegationTokenExpired
  , pattern InvalidPrincipalType
  , pattern NonEmptyGroup
  , pattern GroupIdNotFound
  , pattern FetchSessionIdNotFound
  , pattern InvalidFetchSessionEpoch
  , pattern ListenerNotFound
  , pattern TopicDeletionDisabled
  , pattern FencedLeaderEpoch
  , pattern UnknownLeaderEpoch
  , pattern UnsupportedCompressionType
  , pattern StaleBrokerEpoch
  , pattern OffsetNotAvailable
  , pattern MemberIdRequired
  , pattern PreferredLeaderNotAvailable
  , pattern GroupMaxSizeReached
  , pattern FencedInstanceId
  , pattern EligibleLeadersNotAvailable
  , pattern ElectionNotNeeded
  , pattern NoReassignmentInProgress
  , pattern GroupSubscribedToTopic
  , pattern InvalidRecord
  , pattern UnstableOffsetCommit
  , pattern ThrottlingQuotaExceeded
  , pattern ProducerFenced
  , pattern ResourceNotFound
  , pattern DuplicateResource
  , pattern UnacceptableCredential
  , pattern InconsistentVoterSet
  , pattern InvalidUpdateVersion
  , pattern FeatureUpdateFailed
  , pattern PrincipalDeserializationFailure
  , pattern SnapshotNotFound
  , pattern PositionOutOfRange
  , pattern UnknownTopicId
  , pattern DuplicateBrokerRegistration
  , pattern BrokerIdNotRegistered
  , pattern InconsistentTopicId
  , pattern InconsistentClusterId
  , pattern TransactionalIdNotFound
  , pattern FetchSessionTopicIdError
  , pattern IneligibleReplica
  , pattern NewLeaderElected
  ) where

import Data.Int (Int16)

-- | An ErrorCode. This is given its own type because it improves a lot
-- of derived 'Show' instances and because it makes several type
-- signatures more clear.
newtype ErrorCode = ErrorCode Int16
  deriving newtype (Eq)

instance Show ErrorCode where
  showsPrec _ c@(ErrorCode e) s = case c of
    UnknownServerError -> "UnknownServerError" ++ s
    None -> "None" ++ s
    OffsetOutOfRange -> "OffsetOutOfRange" ++ s
    CorruptMessage -> "CorruptMessage" ++ s
    UnknownTopicOrPartition -> "UnknownTopicOrPartition" ++ s
    InvalidFetchSize -> "InvalidFetchSize" ++ s
    LeaderNotAvailable -> "LeaderNotAvailable" ++ s
    NotLeaderOrFollower -> "NotLeaderOrFollower" ++ s
    RequestTimedOut -> "RequestTimedOut" ++ s
    BrokerNotAvailable -> "BrokerNotAvailable" ++ s
    ReplicaNotAvailable -> "ReplicaNotAvailable" ++ s
    MessageTooLarge -> "MessageTooLarge" ++ s
    StaleControllerEpoch -> "StaleControllerEpoch" ++ s
    OffsetMetadataTooLarge -> "OffsetMetadataTooLarge" ++ s
    NetworkException -> "NetworkException" ++ s
    CoordinatorLoadInProgress -> "CoordinatorLoadInProgress" ++ s
    CoordinatorNotAvailable -> "CoordinatorNotAvailable" ++ s
    NotCoordinator -> "NotCoordinator" ++ s
    InvalidTopicException -> "InvalidTopicException" ++ s
    RecordListTooLarge -> "RecordListTooLarge" ++ s
    NotEnoughReplicas -> "NotEnoughReplicas" ++ s
    NotEnoughReplicasAfterAppend -> "NotEnoughReplicasAfterAppend" ++ s
    InvalidRequiredAcks -> "InvalidRequiredAcks" ++ s
    IllegalGeneration -> "IllegalGeneration" ++ s
    InconsistentGroupProtocol -> "InconsistentGroupProtocol" ++ s
    InvalidGroupId -> "InvalidGroupId" ++ s
    UnknownMemberId -> "UnknownMemberId" ++ s
    InvalidSessionTimeout -> "InvalidSessionTimeout" ++ s
    RebalanceInProgress -> "RebalanceInProgress" ++ s
    InvalidCommitOffsetSize -> "InvalidCommitOffsetSize" ++ s
    TopicAuthorizationFailed -> "TopicAuthorizationFailed" ++ s
    GroupAuthorizationFailed -> "GroupAuthorizationFailed" ++ s
    ClusterAuthorizationFailed -> "ClusterAuthorizationFailed" ++ s
    InvalidTimestamp -> "InvalidTimestamp" ++ s
    UnsupportedSaslMechanism -> "UnsupportedSaslMechanism" ++ s
    IllegalSaslState -> "IllegalSaslState" ++ s
    UnsupportedVersion -> "UnsupportedVersion" ++ s
    TopicAlreadyExists -> "TopicAlreadyExists" ++ s
    InvalidPartitions -> "InvalidPartitions" ++ s
    InvalidReplicationFactor -> "InvalidReplicationFactor" ++ s
    InvalidReplicaAssignment -> "InvalidReplicaAssignment" ++ s
    InvalidConfig -> "InvalidConfig" ++ s
    NotController -> "NotController" ++ s
    InvalidRequest -> "InvalidRequest" ++ s
    UnsupportedForMessageFormat -> "UnsupportedForMessageFormat" ++ s
    PolicyViolation -> "PolicyViolation" ++ s
    OutOfOrderSequenceNumber -> "OutOfOrderSequenceNumber" ++ s
    DuplicateSequenceNumber -> "DuplicateSequenceNumber" ++ s
    InvalidProducerEpoch -> "InvalidProducerEpoch" ++ s
    InvalidTxnState -> "InvalidTxnState" ++ s
    InvalidProducerIdMapping -> "InvalidProducerIdMapping" ++ s
    InvalidTransactionTimeout -> "InvalidTransactionTimeout" ++ s
    ConcurrentTransactions -> "ConcurrentTransactions" ++ s
    TransactionCoordinatorFenced -> "TransactionCoordinatorFenced" ++ s
    TransactionalIdAuthorizationFailed -> "TransactionalIdAuthorizationFailed" ++ s
    SecurityDisabled -> "SecurityDisabled" ++ s
    OperationNotAttempted -> "OperationNotAttempted" ++ s
    KafkaStorageError -> "KafkaStorageError" ++ s
    LogDirNotFound -> "LogDirNotFound" ++ s
    SaslAuthenticationFailed -> "SaslAuthenticationFailed" ++ s
    UnknownProducerId -> "UnknownProducerId" ++ s
    ReassignmentInProgress -> "ReassignmentInProgress" ++ s
    DelegationTokenAuthDisabled -> "DelegationTokenAuthDisabled" ++ s
    DelegationTokenNotFound -> "DelegationTokenNotFound" ++ s
    DelegationTokenOwnerMismatch -> "DelegationTokenOwnerMismatch" ++ s
    DelegationTokenRequestNotAllowed -> "DelegationTokenRequestNotAllowed" ++ s
    DelegationTokenAuthorizationFailed -> "DelegationTokenAuthorizationFailed" ++ s
    DelegationTokenExpired -> "DelegationTokenExpired" ++ s
    InvalidPrincipalType -> "InvalidPrincipalType" ++ s
    NonEmptyGroup -> "NonEmptyGroup" ++ s
    GroupIdNotFound -> "GroupIdNotFound" ++ s
    FetchSessionIdNotFound -> "FetchSessionIdNotFound" ++ s
    InvalidFetchSessionEpoch -> "InvalidFetchSessionEpoch" ++ s
    ListenerNotFound -> "ListenerNotFound" ++ s
    TopicDeletionDisabled -> "TopicDeletionDisabled" ++ s
    FencedLeaderEpoch -> "FencedLeaderEpoch" ++ s
    UnknownLeaderEpoch -> "UnknownLeaderEpoch" ++ s
    UnsupportedCompressionType -> "UnsupportedCompressionType" ++ s
    StaleBrokerEpoch -> "StaleBrokerEpoch" ++ s
    OffsetNotAvailable -> "OffsetNotAvailable" ++ s
    MemberIdRequired -> "MemberIdRequired" ++ s
    PreferredLeaderNotAvailable -> "PreferredLeaderNotAvailable" ++ s
    GroupMaxSizeReached -> "GroupMaxSizeReached" ++ s
    FencedInstanceId -> "FencedInstanceId" ++ s
    EligibleLeadersNotAvailable -> "EligibleLeadersNotAvailable" ++ s
    ElectionNotNeeded -> "ElectionNotNeeded" ++ s
    NoReassignmentInProgress -> "NoReassignmentInProgress" ++ s
    GroupSubscribedToTopic -> "GroupSubscribedToTopic" ++ s
    InvalidRecord -> "InvalidRecord" ++ s
    UnstableOffsetCommit -> "UnstableOffsetCommit" ++ s
    ThrottlingQuotaExceeded -> "ThrottlingQuotaExceeded" ++ s
    ProducerFenced -> "ProducerFenced" ++ s
    ResourceNotFound -> "ResourceNotFound" ++ s
    DuplicateResource -> "DuplicateResource" ++ s
    UnacceptableCredential -> "UnacceptableCredential" ++ s
    InconsistentVoterSet -> "InconsistentVoterSet" ++ s
    InvalidUpdateVersion -> "InvalidUpdateVersion" ++ s
    FeatureUpdateFailed -> "FeatureUpdateFailed" ++ s
    PrincipalDeserializationFailure -> "PrincipalDeserializationFailure" ++ s
    SnapshotNotFound -> "SnapshotNotFound" ++ s
    PositionOutOfRange -> "PositionOutOfRange" ++ s
    UnknownTopicId -> "UnknownTopicId" ++ s
    DuplicateBrokerRegistration -> "DuplicateBrokerRegistration" ++ s
    BrokerIdNotRegistered -> "BrokerIdNotRegistered" ++ s
    InconsistentTopicId -> "InconsistentTopicId" ++ s
    InconsistentClusterId -> "InconsistentClusterId" ++ s
    TransactionalIdNotFound -> "TransactionalIdNotFound" ++ s
    FetchSessionTopicIdError -> "FetchSessionTopicIdError" ++ s
    IneligibleReplica -> "IneligibleReplica" ++ s
    NewLeaderElected -> "NewLeaderElected" ++ s
    _ -> "(ErrorCode " ++ shows e (')':s)

pattern UnknownServerError :: ErrorCode
pattern UnknownServerError = ErrorCode (-1)

pattern None :: ErrorCode
pattern None = ErrorCode 0

pattern OffsetOutOfRange :: ErrorCode
pattern OffsetOutOfRange = ErrorCode 1

pattern CorruptMessage :: ErrorCode
pattern CorruptMessage = ErrorCode 2

pattern UnknownTopicOrPartition :: ErrorCode
pattern UnknownTopicOrPartition = ErrorCode 3

pattern InvalidFetchSize :: ErrorCode
pattern InvalidFetchSize = ErrorCode 4

pattern LeaderNotAvailable :: ErrorCode
pattern LeaderNotAvailable = ErrorCode 5

pattern NotLeaderOrFollower :: ErrorCode
pattern NotLeaderOrFollower = ErrorCode 6

pattern RequestTimedOut :: ErrorCode
pattern RequestTimedOut = ErrorCode 7

pattern BrokerNotAvailable :: ErrorCode
pattern BrokerNotAvailable = ErrorCode 8

pattern ReplicaNotAvailable :: ErrorCode
pattern ReplicaNotAvailable = ErrorCode 9

pattern MessageTooLarge :: ErrorCode
pattern MessageTooLarge = ErrorCode 10

pattern StaleControllerEpoch :: ErrorCode
pattern StaleControllerEpoch = ErrorCode 11

pattern OffsetMetadataTooLarge :: ErrorCode
pattern OffsetMetadataTooLarge = ErrorCode 12

pattern NetworkException :: ErrorCode
pattern NetworkException = ErrorCode 13

pattern CoordinatorLoadInProgress :: ErrorCode
pattern CoordinatorLoadInProgress = ErrorCode 14

pattern CoordinatorNotAvailable :: ErrorCode
pattern CoordinatorNotAvailable = ErrorCode 15

pattern NotCoordinator :: ErrorCode
pattern NotCoordinator = ErrorCode 16

pattern InvalidTopicException :: ErrorCode
pattern InvalidTopicException = ErrorCode 17

pattern RecordListTooLarge :: ErrorCode
pattern RecordListTooLarge = ErrorCode 18

pattern NotEnoughReplicas :: ErrorCode
pattern NotEnoughReplicas = ErrorCode 19

pattern NotEnoughReplicasAfterAppend :: ErrorCode
pattern NotEnoughReplicasAfterAppend = ErrorCode 20

pattern InvalidRequiredAcks :: ErrorCode
pattern InvalidRequiredAcks = ErrorCode 21

pattern IllegalGeneration :: ErrorCode
pattern IllegalGeneration = ErrorCode 22

pattern InconsistentGroupProtocol :: ErrorCode
pattern InconsistentGroupProtocol = ErrorCode 23

pattern InvalidGroupId :: ErrorCode
pattern InvalidGroupId = ErrorCode 24

pattern UnknownMemberId :: ErrorCode
pattern UnknownMemberId = ErrorCode 25

pattern InvalidSessionTimeout :: ErrorCode
pattern InvalidSessionTimeout = ErrorCode 26

pattern RebalanceInProgress :: ErrorCode
pattern RebalanceInProgress = ErrorCode 27

pattern InvalidCommitOffsetSize :: ErrorCode
pattern InvalidCommitOffsetSize = ErrorCode 28

pattern TopicAuthorizationFailed :: ErrorCode
pattern TopicAuthorizationFailed = ErrorCode 29

pattern GroupAuthorizationFailed :: ErrorCode
pattern GroupAuthorizationFailed = ErrorCode 30

pattern ClusterAuthorizationFailed :: ErrorCode
pattern ClusterAuthorizationFailed = ErrorCode 31

pattern InvalidTimestamp :: ErrorCode
pattern InvalidTimestamp = ErrorCode 32

pattern UnsupportedSaslMechanism :: ErrorCode
pattern UnsupportedSaslMechanism = ErrorCode 33

pattern IllegalSaslState :: ErrorCode
pattern IllegalSaslState = ErrorCode 34

pattern UnsupportedVersion :: ErrorCode
pattern UnsupportedVersion = ErrorCode 35

pattern TopicAlreadyExists :: ErrorCode
pattern TopicAlreadyExists = ErrorCode 36

pattern InvalidPartitions :: ErrorCode
pattern InvalidPartitions = ErrorCode 37

pattern InvalidReplicationFactor :: ErrorCode
pattern InvalidReplicationFactor = ErrorCode 38

pattern InvalidReplicaAssignment :: ErrorCode
pattern InvalidReplicaAssignment = ErrorCode 39

pattern InvalidConfig :: ErrorCode
pattern InvalidConfig = ErrorCode 40

pattern NotController :: ErrorCode
pattern NotController = ErrorCode 41

pattern InvalidRequest :: ErrorCode
pattern InvalidRequest = ErrorCode 42

pattern UnsupportedForMessageFormat :: ErrorCode
pattern UnsupportedForMessageFormat = ErrorCode 43

pattern PolicyViolation :: ErrorCode
pattern PolicyViolation = ErrorCode 44

pattern OutOfOrderSequenceNumber :: ErrorCode
pattern OutOfOrderSequenceNumber = ErrorCode 45

pattern DuplicateSequenceNumber :: ErrorCode
pattern DuplicateSequenceNumber = ErrorCode 46

pattern InvalidProducerEpoch :: ErrorCode
pattern InvalidProducerEpoch = ErrorCode 47

pattern InvalidTxnState :: ErrorCode
pattern InvalidTxnState = ErrorCode 48

pattern InvalidProducerIdMapping :: ErrorCode
pattern InvalidProducerIdMapping = ErrorCode 49

pattern InvalidTransactionTimeout :: ErrorCode
pattern InvalidTransactionTimeout = ErrorCode 50

pattern ConcurrentTransactions :: ErrorCode
pattern ConcurrentTransactions = ErrorCode 51

pattern TransactionCoordinatorFenced :: ErrorCode
pattern TransactionCoordinatorFenced = ErrorCode 52

pattern TransactionalIdAuthorizationFailed :: ErrorCode
pattern TransactionalIdAuthorizationFailed = ErrorCode 53

pattern SecurityDisabled :: ErrorCode
pattern SecurityDisabled = ErrorCode 54

pattern OperationNotAttempted :: ErrorCode
pattern OperationNotAttempted = ErrorCode 55

pattern KafkaStorageError :: ErrorCode
pattern KafkaStorageError = ErrorCode 56

pattern LogDirNotFound :: ErrorCode
pattern LogDirNotFound = ErrorCode 57

pattern SaslAuthenticationFailed :: ErrorCode
pattern SaslAuthenticationFailed = ErrorCode 58

pattern UnknownProducerId :: ErrorCode
pattern UnknownProducerId = ErrorCode 59

pattern ReassignmentInProgress :: ErrorCode
pattern ReassignmentInProgress = ErrorCode 60

pattern DelegationTokenAuthDisabled :: ErrorCode
pattern DelegationTokenAuthDisabled = ErrorCode 61

pattern DelegationTokenNotFound :: ErrorCode
pattern DelegationTokenNotFound = ErrorCode 62

pattern DelegationTokenOwnerMismatch :: ErrorCode
pattern DelegationTokenOwnerMismatch = ErrorCode 63

pattern DelegationTokenRequestNotAllowed :: ErrorCode
pattern DelegationTokenRequestNotAllowed = ErrorCode 64

pattern DelegationTokenAuthorizationFailed :: ErrorCode
pattern DelegationTokenAuthorizationFailed = ErrorCode 65

pattern DelegationTokenExpired :: ErrorCode
pattern DelegationTokenExpired = ErrorCode 66

pattern InvalidPrincipalType :: ErrorCode
pattern InvalidPrincipalType = ErrorCode 67

pattern NonEmptyGroup :: ErrorCode
pattern NonEmptyGroup = ErrorCode 68

pattern GroupIdNotFound :: ErrorCode
pattern GroupIdNotFound = ErrorCode 69

pattern FetchSessionIdNotFound :: ErrorCode
pattern FetchSessionIdNotFound = ErrorCode 70

pattern InvalidFetchSessionEpoch :: ErrorCode
pattern InvalidFetchSessionEpoch = ErrorCode 71

pattern ListenerNotFound :: ErrorCode
pattern ListenerNotFound = ErrorCode 72

pattern TopicDeletionDisabled :: ErrorCode
pattern TopicDeletionDisabled = ErrorCode 73

pattern FencedLeaderEpoch :: ErrorCode
pattern FencedLeaderEpoch = ErrorCode 74

pattern UnknownLeaderEpoch :: ErrorCode
pattern UnknownLeaderEpoch = ErrorCode 75

pattern UnsupportedCompressionType :: ErrorCode
pattern UnsupportedCompressionType = ErrorCode 76

pattern StaleBrokerEpoch :: ErrorCode
pattern StaleBrokerEpoch = ErrorCode 77

pattern OffsetNotAvailable :: ErrorCode
pattern OffsetNotAvailable = ErrorCode 78

pattern MemberIdRequired :: ErrorCode
pattern MemberIdRequired = ErrorCode 79

pattern PreferredLeaderNotAvailable :: ErrorCode
pattern PreferredLeaderNotAvailable = ErrorCode 80

pattern GroupMaxSizeReached :: ErrorCode
pattern GroupMaxSizeReached = ErrorCode 81

pattern FencedInstanceId :: ErrorCode
pattern FencedInstanceId = ErrorCode 82

pattern EligibleLeadersNotAvailable :: ErrorCode
pattern EligibleLeadersNotAvailable = ErrorCode 83

pattern ElectionNotNeeded :: ErrorCode
pattern ElectionNotNeeded = ErrorCode 84

pattern NoReassignmentInProgress :: ErrorCode
pattern NoReassignmentInProgress = ErrorCode 85

pattern GroupSubscribedToTopic :: ErrorCode
pattern GroupSubscribedToTopic = ErrorCode 86

pattern InvalidRecord :: ErrorCode
pattern InvalidRecord = ErrorCode 87

pattern UnstableOffsetCommit :: ErrorCode
pattern UnstableOffsetCommit = ErrorCode 88

pattern ThrottlingQuotaExceeded :: ErrorCode
pattern ThrottlingQuotaExceeded = ErrorCode 89

pattern ProducerFenced :: ErrorCode
pattern ProducerFenced = ErrorCode 90

pattern ResourceNotFound :: ErrorCode
pattern ResourceNotFound = ErrorCode 91

pattern DuplicateResource :: ErrorCode
pattern DuplicateResource = ErrorCode 92

pattern UnacceptableCredential :: ErrorCode
pattern UnacceptableCredential = ErrorCode 93

pattern InconsistentVoterSet :: ErrorCode
pattern InconsistentVoterSet = ErrorCode 94

pattern InvalidUpdateVersion :: ErrorCode
pattern InvalidUpdateVersion = ErrorCode 95

pattern FeatureUpdateFailed :: ErrorCode
pattern FeatureUpdateFailed = ErrorCode 96

pattern PrincipalDeserializationFailure :: ErrorCode
pattern PrincipalDeserializationFailure = ErrorCode 97

pattern SnapshotNotFound :: ErrorCode
pattern SnapshotNotFound = ErrorCode 98

pattern PositionOutOfRange :: ErrorCode
pattern PositionOutOfRange = ErrorCode 99

pattern UnknownTopicId :: ErrorCode
pattern UnknownTopicId = ErrorCode 100

pattern DuplicateBrokerRegistration :: ErrorCode
pattern DuplicateBrokerRegistration = ErrorCode 101

pattern BrokerIdNotRegistered :: ErrorCode
pattern BrokerIdNotRegistered = ErrorCode 102

pattern InconsistentTopicId :: ErrorCode
pattern InconsistentTopicId = ErrorCode 103

pattern InconsistentClusterId :: ErrorCode
pattern InconsistentClusterId = ErrorCode 104

pattern TransactionalIdNotFound :: ErrorCode
pattern TransactionalIdNotFound = ErrorCode 105

pattern FetchSessionTopicIdError :: ErrorCode
pattern FetchSessionTopicIdError = ErrorCode 106

pattern IneligibleReplica :: ErrorCode
pattern IneligibleReplica = ErrorCode 107

pattern NewLeaderElected :: ErrorCode
pattern NewLeaderElected = ErrorCode 108
