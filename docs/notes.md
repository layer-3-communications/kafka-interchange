# Personal Notes

## ListOffsets vs OffsetFetch

What is the difference between ListOffsets and OffsetFetch? ListOffsets
provides information about the topics, and OffsetFetch provides information
about consumer groups.

## Fetching from End of Partition

The first fetch request can be used to create a fetch session. Subsequent
fetches do not need to enumerate the partitions (or even the topics) again.
But, to change the offset that we fetch from, we must send the update the
partition. So in practice, we only get to exploit the session when we get
no records back from the broker. The brokers appears to behave differently
depending on whether or not a sesion id was used. On the first request
(the one without a session id), we get a partition with an empty record
batch. On subsequent requests, the partition is missing entirely. I'm not
sure why this works this way. It might be because some of the information
in the partition object is useful.

## Decoding RecordSet

Kafka groups records into "record batches". In produce requests and fetch
response, there is a RecordSet (also something just called "records") that
is an array of record batches. The encoding of a record set is not documented
in the kafka wire protocol. For the versions of the Kafka API that this
library supports, the successor of the byte length of the record set is
encoded with LEB128.

Kafka's RecordSet encoding includes a peculiar design decision. The final
batch in the set may be truncated (and consequently unusable). This is
undocumented but can be discovered by reading Kafka's source code. Bits of
documentation in Kafka's source code hint that this decision was made
so that brokers could respond with messages in a zero-copy (i.e. sendfile)
way. I've never seen any message serialization format that does this.
