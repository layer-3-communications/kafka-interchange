# kafka-interchange

This library provides serialization and deserialization for exchanges
with Kafka. This takes the form of: data types, encode functions, and
decode functions. This library is not a Kafka client. A Kafka client must
be a much more opinionated piece of software. The purpose of this library
is for Kafka clients to be built on top of it.

## Module Structure

There are two module namespaces in this library: `Kafka.Interchange` and
`Kafka.Data`. Pseudoregex for modules in the `Kafka.Interchange` namespace:

    Kafka.Interchange.{msgtype}.(Request|Response).V[0-9]+

For example:

    Kafka.Interchange.Message.Request.V2
    Kafka.Interchange.Message.Response.V1
    Kafka.Interchange.Produce.Request.V9

The message type "Message" is special. It's the wrapper that all other message
types are serialized inside of. Request modules include a encode function.
Response modules include a decode function.

Some shared types are used by both requests and responses. For such types, we
use the `Kafka.Data` namespace. For example:

    Kafka.Data.Acknowledgments

These are not versioned, and they include both encode and decode functions.
