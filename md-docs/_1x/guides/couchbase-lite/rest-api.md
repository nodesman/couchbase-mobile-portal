---
title: REST API
---

The Couchbase Lite Listener exposes the same functionality as the native API through a common RESTful API. You can perform the same operations on the database by making HTTP calls.

The Listener API handles data as JSON documents, and uses the same concepts such as revisions, documents, replications, views and queries. This page lists a few common operations, you open it on Codepen and edit the code for each one.

## Query

### Pagination

The code below shows you how to:

- Create a database.
- Add 10 documents.
- Register a simple query.
- Use the `startkey` and `limit` parameters.

```javascript
client.query.get_db_design_ddoc_view_view({
	view: 'byMenu',
	ddoc: 'main',
	db: db,
	startkey: document.getElementById('startkey').value,
	limit: document.getElementById('limit').value
})
	.then(function (res) {
		console.log("View query returned " + res.obj.rows.length + " docs");
	})
	.catch(function (err) {console.log(err);});
```
{% include java-codepen.html preview="https://cl.ly/1D2y0u2G1E44/codepen-pagination.gif" codepen="http://codepen.io/Jamiltz/pen/ZeWPeV?editors=1011" %}

### Query documents by keys

The code below shows you how to:

- Create a database.
- Register a view with the database.
- Add documents.
- Query the view.

```javascript
client.query.post_db_design_ddoc_view_view({
	view: 'byMenu',
	ddoc: 'main',
	db: db,
	body: {keys: [1]}
})
	.then(function (res) {
		console.log("View query returned " + res.obj.rows.length + " docs");
	})
	.catch(function (err) {console.log(err);});
```
{% include java-codepen.html preview="https://cl.ly/1H391k2t3F3D/codepen-view-query.gif" codepen="http://codepen.io/Jamiltz/pen/zNLqyL?editors=1011" %}

### Data aggregation

The following view code shows you how to:

- Create a database.
- Insert documents in bulk.
- Query the number of documents whose `type` property is equal to `task`.

```javascript
var views = {
  views: {
    byMenu: {
      map: function(doc) {
        if (doc.type && (doc.type === 'task')) {
          emit(doc._id, null);
        }
      }.toString(),
      reduce: function(keys, values) {
        return values.length;
      }.toString()
    }
  }
};
```
{% include java-codepen.html preview="https://cl.ly/313E3P2R2E2j/grouping-query.gif" codepen="http://codepen.io/Jamiltz/pen/LWQRYE?editors=1011" %}

## Replication

### Session expiry

The following code shows you how to:

- Create a session id using the Sync Gateway `/{db}/_session` Public endpoint.
- Start a replication with that session id using the Couchbase Lite REST API `/_replicate` endpoint.
- Verify that the documents are pushed from Couchbase Lite to Sync Gateway.
- Destroy the session id using the Sync Gateway `/{db}/_session/{id}` Admin endpoint.
- Add more documents to Couchbase Lite and verify that they are not replicated to Sync Gateway since the session isn't valid anymore.
- Create a new session id and update the replication with the new session id.
- Verify that the documents are pushed from Couchbase Lite to Sync Gateway with the new session id.

<br>

{% include lite-sg-codepen.html preview="https://cl.ly/0K2O2Q343K3T/session-expiry.mp4" codepen="http://codepen.io/Jamiltz/pen/mWgbGK?editors=1011" %}