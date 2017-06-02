---
id: document
title: Document
permalink: guides/couchbase-lite/native-api/document/index.html
---

<block class="all" />

## Documents

In Couchbase Lite, a document's body takes the form of a JSON object — a collection of key/value pairs where the values can be different types of data such as numbers, strings, arrays or even nested objects. Every document is identified by a document ID, which can be automatically generated (as a UUID) or determined by the application; the only constraints are that it must be unique within the database, and it can't be changed. The following methods/initializers can be used:

- The {% st Document()|document|new Document()|getDocument() %} initializer can be used to create a new document (check the API references for alternative initializers that accept an ID and properties as parameters).
- The {% st database.getDocument(id: String)|documentWithID:|GetDocument(string id)|getDocument(String docID) %} method can be used to  get a document. If it doesn't exist in the database, it will return {% st nil|nil|null|null %}.

[//]: # (TODO: Since this identifier must be unique, you may want to check if a document with this ID already exists in the database using the {% st a|b|c|d %} method.)

The following code example creates a document and persists it to the database.

<block class="swift" />

```swift
let newTask = Document()
newTask.set("task-list", forKey:"type")
newTask.set("todo", forKey:"owner")
newTask.set(Date(), forKey:"createAt")
try database.save(newTask)
```

<block class="objc" />

```objectivec
CBLDocument* newTask = [[CBLDocument alloc] init];
[newTask setObject:@"task-list" forKey:@"type"];
[newTask setObject:@"todo" forKey:@"owner"];
[newTask setObject:[NSDate date] forKey:@"createAt"];
NSError* error;
[database saveDocument: newTask error: &error];
```

<block class="csharp" />

```csharp
var document = new Document();
database.Save(document);
```

<block class="java" />

```java
Document document = new Document();
database.save(document);
```

<block class="all" />

### Mutability

The biggest change is that {% st Document|CBLDocument|Document|Document %} properties are now mutable. Instead of having to make a mutable copy of the properties dictionary, update it, and then save it back to the document, you can now modify individual properties in place and then save.

<block class="swift" />

```swift
newTask.set("Apples", forKey:"name")
try database.save(newTask)
```

<block class="objc" />

```objectivec
[newTask setObject:@"Apples" forKey:@"name"];
NSError* error;
[database saveDocument:newTask error:&error];
```

<block class="csharp" />

```csharp
newTask.Set("name", "Apples")
database.Save(newTask)
```

<block class="java" />

```java
newTask.set("name", "Apples");
database.save(newTask);
```

<block class="all" />

This does create the possibility of confusion, since the document's in-memory state may not match what's in the database. Unsaved changes are not visible to other {% st Database|CBLDatabase|Database|Database %} instances (i.e. other threads that may have other instances), or to queries.

### Typed Accessors

The {% st Document|CBLDocument|Document|Document %} class now offers a set of property accessors for various scalar types, including boolean, integers, floating-point and strings. These accessors take care of converting to/from JSON encoding, and make sure you get the type you're expecting: for example, {% st document.getString("name")|stringForKey:|GetString(string key)|getString(String key) %} returns either a {% st String|NSString|string|String %} or {% st nil|nil|null|null %}, so you can't get an unexpected object class and crash trying to use it as a string. (Even if the property in the document has an incompatible type, the accessor returns {% st nil|nil|null|null %}.)

In addition, as a convenience we offer {% st Date|NSDate|DateTimeOffset|Date %} accessors. Dates are a common data type, but JSON doesn't natively support them, so the convention is to store them as strings in ISO-8601 format. The following example sets the date on the `createdAt` property and reads it back using the {% st document.getDate(key: String)|dateForKey:|GetDate(string key)|getDate(String key) %} accessor method.

<block class="swift" />

```swift
newTask.set(Date(), forKey: "createdAt")
let date = newTask.getDate("createdAt")
```

<block class="objc" />

```objectivec
[newTask setObject:[NSDate date] forKey:@"createdAt"];
NSDate* date = [newTask dateForKey:@"createdAt"];
```

<block class="csharp" />

```csharp
document.Set("createdAt", DateTimeOffset.UtcNow);
database.Save(document);
Console.WriteLine($"createdAt value :: ${document.GetDate("createdAt")}");
```

<block class="java" />

```java
document.set("createdAt", new Date(System.currentTimeMillis()));
database.save(document);
Log.d("app", String.format("createdAt value :: %s", document.getDate("createdAt")));
```

<block class="swift" />

{% include swift/document.html %}

<block class="objc" />

<block class="csharp" />

{% include csharp/document.html %}