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