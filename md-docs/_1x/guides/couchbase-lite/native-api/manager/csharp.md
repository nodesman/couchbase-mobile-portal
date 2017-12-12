---
id: manager
title: Manager
permalink: guides/couchbase-lite/native-api/manager/csharp.html
---

A `Manager` is the top-level object that manages a collection of Couchbase Lite `Database` instances. You need to create a `Manager` instance before you can work with Couchbase Lite objects in your Application.

## Creating a manager

You create a Manager object by calling a constructor or initializer on the Manager class.

```c
var manager = Manager.SharedInstance;
```

## Default database path

The Manager creates a directory in the filesystem and stores databases inside it. Normally, you don't need to care where that is -- your application shouldn't be directly accessing those files. But sometimes it does matter. Depending on the platform you are developing for, the default database path will be:


|Platform|Path|
|:-------|:---|
|Windows (WPF)|TODO|
|Xamarin Android|TODO|
|Xamarin iOS|TODO|

You can change the location of the databases by instantiating the `Manager` via a constructor/initializer that takes a path as a parameter. This directory will be created if it doesn't already exist.

```c
var options = new ManagerOptions();
options.ReadOnly = true;
Manager manager = new Manager(Directory.CreateDirectory(dbPath), options);
```

## Global logging settings

You can customize the global logging settings for Couchbase Lite via the `Manager` class. Log messages are tagged, allowing them to be logically grouped by activity. You can control whether individual tag groups are logged.

The available tags are:

```c
Log tags

Log.Domains.Database
Log.Domains.Query
Log.Domains.View
Log.Domains.Router
Log.Domains.Sync
Log.Domains.ChangeTracker
Log.Domains.Validation
Log.Domains.Upgrade
Log.Domains.Listener
Log.Domains.Discovery
Log.Domains.TaskScheduling
Log.Domains.All

Log levels

Log.LogLevel.Verbose
Log.LogLevel.Debug
Log.LogLevel.Error
Log.LogLevel.Warning
Log.LogLevel.Information
```

The following code snippet enables logging for the **Sync** tag.

```c
Log.Domains.Sync.Level = Log.LogLevel.Verbose
```

TODO: Add any other content relevant to the C# SDK.

## Concurrency Support

TODO: Does the following also apply to the C# SDK? If so, please replace any mention of other platforms with C#/Windows.

In Objective-C, a `Manager` instance and the object graph associated with it may only be accessed from the thread or dispatch queue that created the `Manager` instance. Concurrency is supported through explicit method calls.

### Running individual blocks in the background

TODO: Does the following also apply to the C# SDK? If so, please replace any mention of other platforms with C#/Windows.

You can use the `CBLManager` method `backgroundTellDatabaseNamed:to:` to perform any operation in the background. Be careful with this, though! Couchbase Lite objects are per-thread, and your block runs on a background thread, so:

- You can’t use any of the Couchbase Lite objects (databases, documents, models…) you were using on the main thread. Instead, you have to use the CBLDatabase object passed to the block, and the other objects reachable from it.
- You can’t save any of the Couchbase Lite objects in the block and then call them on the main thread. (For example, if in the block you allocated some CBLModels and assigned them to properties of application objects, bad stuff would happen if they got called later on by application code.)
- And of course, since the block is called on a background thread, any application or system APIs you call from it need to be thread-safe.

In general, it’s best to do only very limited things using this API, otherwise it becomes too easy to accidentally use main-thread Couchbase Lite objects in the block, or store background-thread Couchbase Lite objects in places where they’ll be called on the main thread.

Here’s an example that deletes a number of documents given an array of IDs:

TODO: Need the analogue to ObjC if it applies [https://github.com/couchbaselabs/couchbase-mobile-portal/blame/master/md-docs/_1x/guides/couchbase-lite/native-api/manager.md#L255-L264](https://github.com/couchbaselabs/couchbase-mobile-portal/blame/master/md-docs/_1x/guides/couchbase-lite/native-api/manager.md#L255-L264)

```c
No code example is currently available.
```

### Running Couchbase Lite on a background thread

TODO: Does the following also apply to the C# SDK? If so, please replace any mention of other platforms with C#/Windows.

If you want to do lots of Couchbase Lite processing in the background in Objective-C, the best way to do it is to start your own background thread and use a new `Manager` instance on it.

TODO: Need the analogue to ObjC if it applies [https://github.com/couchbaselabs/couchbase-mobile-portal/blame/master/md-docs/_1x/guides/couchbase-lite/native-api/manager.md#L292-L314](https://github.com/couchbaselabs/couchbase-mobile-portal/blame/master/md-docs/_1x/guides/couchbase-lite/native-api/manager.md#L292-L314)

```c
No code example is currently available.
```

If you don't plan to use Couchbase Lite on the main thread at all, the setup is even easier. Just have the background thread create a new instance of CBLManager from scratch and use that:

TODO: Need the analogue to ObjC if it applies [https://github.com/couchbaselabs/couchbase-mobile-portal/blame/master/md-docs/_1x/guides/couchbase-lite/native-api/manager.md#L343-L361](https://github.com/couchbaselabs/couchbase-mobile-portal/blame/master/md-docs/_1x/guides/couchbase-lite/native-api/manager.md#L343-L361)

```c
No code example is currently available.
```
