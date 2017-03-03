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

{% include java-codepen.html %}
<a href="http://codepen.io/Jamiltz/pen/ZeWPeV?editors=1011">
	![](https://cl.ly/1D2y0u2G1E44/codepen-pagination.gif)
</a>

### Query documents by keys

The code below shows you how to:

- Create a database.
- Register a view with the database.
- Add documents.
- Query the view.

{% include java-codepen.html %}
<a href="http://codepen.io/Jamiltz/pen/zNLqyL?editors=1011">
	![](https://cl.ly/1H391k2t3F3D/codepen-view-query.gif)
</a>