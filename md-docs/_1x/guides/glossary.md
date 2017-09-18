---
permalink: glossary.html
---

## Tombstones

A tombstone in Couchbase Mobile is a document that is marked with the `_deleted` attribute. The main purpose of a tombstone is to let other clients know (through replication) to also remove that document from their database. A tombstone remains in the database until it is purged using the Couchbase Lite API and Sync Gateway's [/{db}/_purge](references/sync-gateway/admin-rest-api/index.html#/document/post__db___purge) admin endpoint.

#### With XATTRs

When convergence is enabled (using the `databases.foo_db.enabled_shared_bucket_access` property), Couchbase Mobile tombstones become equivalent to Couchbase Server tombstones. As a result, the process to remove tombstones that are no longer useful to the application is different (see [databases.foo_db.enabled\_shared\_bucket\_access](guides/sync-gateway/config-properties/index.html#1.5/databases-foo_db-unsupported-enable_extended_attributes))