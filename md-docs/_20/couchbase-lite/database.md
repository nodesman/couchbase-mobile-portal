---
permalink: guides/couchbase-lite/native-api/database/index.html
---

<block class="all" />

## Databases

### Creating Databases

As the top-level entity in the API, new databases can be created using the {% st Database|CBLDatabase|Database|Database %} class by passing in a name, options, or both. The following example creates a database using the {% st Database(name: String)|initWithName:error:|new Database(string name)|new Database(String name, DatabaseOptions options) %} method.

<block class="swift" />

```swift
do {
  let database = try Database(name: "my-database")
} catch let error as NSError {
  NSLog("Cannot open the database: %@", error);
}
```

<block class="objc" />

```objectivec
NSError *error;
CBLDatabase* database = [[CBLDatabase alloc] initWithName:@"my-database" error:&error];
if (!database) {
	NSLog(@"Cannot open the database: %@", error);
}
```

<block class="csharp" />

```csharp
var database = new Database("my-database");
```

<block class="java" />

```java
DatabaseConfiguration config = new DatabaseConfiguration(/* Android Context*/ context);
Database database = new Database("my-database", config);
```

<block class="all" />

Just as before, the database will be created in a default location. Alternatively, the {% st Database(name: String options: DatabaseOptions?)|initWithName:options:error:|new Database(string name, DatabaseOptions options)|new Database(String name, DatabaseOptions options) %} method can be used to provide specific options (directory to create the database in, whether it is read-only etc.)

You can instantiate multiple databases with the same name and directory; these will all share the same storage. This is the recommended approach if you will be calling Couchbase Lite from multiple threads or dispatch queues, since Couchbase Lite objects are not thread-safe and can only be called from one thread/queue. Otherwise, for use on a single thread/queue, it's more efficient to use a single instance.

#### Opening 1.x databases

Databases that were created with Couchbase Mobile 1.2 or later can be read using the 2.0 API. Upon detecting it is a 1.x database file format, Couchbase Lite will automatically upgrade it to the new format used in 2.0. This feature is currently only available for the default storage type, SQLite (i.e not for ForestDB databases).

<block class="all" />

### Transactions / batch operations

As before, if you're making multiple changes to a database at once, it's *much* faster to group them together, otherwise each individual change incurs overhead, from flushing writes to the filesystem to ensure durability. In 2.0 we've renamed the method to {% st inBatch()|inBatch:do:|InBatch()|inBatch(Runnable action) %} to emphasize that Couchbase Lite does not offer transactional guarantees, and that the purpose of the method is to optimize batch operations rather than to enable ACID transactions. The following example persists a few documents in batch.

<block class="swift" />

```swift
do {
	try database.inBatch {
		for i in 0...10 {
			let doc = Document()
			doc.set("user", forKey: "type")
			doc.set("user \(i)", forKey: "name")
			try database.save(doc)
			print("saved user document \(doc.getString("name"))")
		}
	}
} catch let error {
	print(error.localizedDescription)
}
```

<block class="objc" />

```objectivec
[database inBatch:&error do:^{
	for (int i = 1; i <= 10; i++)
	{
		CBLDocument *doc = [[CBLDocument alloc] init];
		[doc setObject:@"user" forKey:@"type"];
		[doc setObject:[NSString stringWithFormat:@"user %d", i] forKey:@"name"];
		NSError* error;
		[database saveDocument:doc error:&error];
		NSLog(@"saved user document %@", [doc stringForKey:@"name"]);
	}
}];
```

<block class="csharp" />

```csharp
database.InBatch(() =>
{
	for (int i = 0; i < 10; i++)
	{
		var doc = new Document()
		doc.Set(""type", user")
		doc.Set("name", ""user {i}")
		database.Save(doc)
		Console.WriteLine($"saved user document {doc.GetString("name")}")
	}
	
	return true;
});
```

<block class="java" />

```java
database.inBatch(new TimerTask() {
	@Override
	public void run() {
		for (int i = 0; i < 10; i++) {
			Document doc = new Document()
			doc.set("type", "user");
			doc.set("name", String.format("user %s", i));
			database.save(doc);
			Log.d("app", String.format("saved user document %s", doc.getString("name")));
		}
	}
});
```

<block class="all" />

At the *local* level this operation is still transactional: no other {% st Database|CBLDatabase|Database|Database %} instances, including ones managed by the replicator or HTTP listener, can make changes during the execution of the block, and other instances will not see partial changes. But Couchbase Mobile is a *distributed* system, and due to the way replication works, there's no guarantee that Sync Gateway or other devices will receive your changes all at once.

Again, the behavior of the method hasn't changed, just its name.

<block class="swift" />

{% include swift/database.html %}

<block class="csharp" />

{% include csharp/database.html %}

<block class="java" />

{% include java/database.html %}

<block class="all" />