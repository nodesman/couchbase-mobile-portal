---
title: REST API
---

An introductory guide to the Couchbase Lite APIs. The Couchbase Lite Listener exposes the same functionality as the native SDKs through a common RESTful API. You can perform the same operations on the database by making API calls.

The Listener API handles data as JSON documents, and uses the same concepts such as revisions, documents, replications, views and queries.

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

## User session

{% include sg-codepen.html %}

<p data-height="300" data-theme-id="27686" data-slug-hash="LWPzvr" data-default-tab="js,result" data-user="Jamiltz" data-embed-version="2" data-pen-title="Guide: Sync Gateway session" class="codepen">See the Pen <a href="http://codepen.io/Jamiltz/pen/LWPzvr/">Guide: Sync Gateway session</a> by Jamiltz (<a href="http://codepen.io/Jamiltz">@Jamiltz</a>) on <a href="http://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>