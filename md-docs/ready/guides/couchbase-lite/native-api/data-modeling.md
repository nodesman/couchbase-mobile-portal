---
id: data-modeling
title: Data Modeling
permalink: ready/guides/couchbase-lite/native-api/data-modeling/index.html
---

A starting point for data modeling in Couchbase Lite is to look at a denormalized entity stored in a single document. Consider modeling a contact record stored in a relational database in a CONTACTS table, of the form:

|ID|FIRST_NAME|LAST_NAME|EMAIL|
|:--|:---------|:--------|:----|
|100|John|Smith|john.smith@couchbase.com|

The equivalent representation in JSON document form would be something like:

Functionally related properties can be grouped using an embedded document. If we wanted to store address information for our contact, it could be modeled as.

{% if site.languages == "swift" or site.languages == "objectivec" %}

Most applications use the Model/View/Controller design pattern to separate user interface and user interaction from underlying data structures and logic. Of course, one of the responsibilities of the app's object model is persistence.

Couchbase Lite on iOS provides support for creating model objects that persist to Couchbase Lite documents, and can be queried using Couchbase Lite queries. (This functionality is similar to Core Data's NSManagedObject.) You subclass the abstract class CBLModel and add your own Objective-C properties, plus a very small amount of annotation that defines how those properties map to JSON in the document.

Note:Model objects are currently only available in Objective-C. They may be added to the other implementations in the future, although the property-related features may be different in order to fit in with those platforms' idioms.

## Defining model classes

To create your own model class, just make it inherit from CBLModel. You can create any number of model classes, and they can inherit from each other. Each model class will correspond to a different type of persistent entity in your application.

You define persistent properties of your model classes simply by declaring Objective-C properties in its @interface block using the @property syntax. To mark a property as persistent, in the @implementation block you must declare it as being @dynamic, as shown in the next example.

```objectivec
@interface Note : CBLModel
@property (copy) NSString* text;
@property NSDate* created;
@property bool checked;    // bool not BOOL! See below for why
@end
```

```swift
@objc(Note)
class Note: CBLModel {
    @NSManaged var message: NSString
    @NSManaged var created: NSDate
    @NSManaged var checked: Bool
}
```

## Array element types

The NSArray property type often needs special handling, to ensure that the items of JSON arrays are converted to the correct type of object. By default, the items are simply parsed as JSON; this breaks round-trip fidelity if you store NSDate or NSData or CBLModel objects -- they'll all be read back in as NSStrings. And if you store objects implementing CBLJSONEncoding, they'll be read back in as whatever JSON-compatible value the object encoded itself as.

To prevent this, you can specify that the items of the array property must be of a particular class. Each item will then be converted from JSON according to the property-type rules for that class, described in the previous section. To specify the type, implement a class method with a name of the form propertynameItemClass, as in this example:

```objectivec
@interface Star : CBLModel
@property (copy) NSArray* observationDates;  // items are NSDates
@end
//
@implementation Star
@dynamic observationDates;
// Declares that the items of the observations property are NSDates.
+ (Class) observationsItemClass {
    return [NSDate class];
}
@end
```

```swift
@objc(Star)
class Star: CBLModel {
    @NSManaged var observationDates: NSArray // items are NSDates
    class func observationsItemClass() -> AnyClass {
        return NSDate.self
    }
}
```

{% elsif site.languages == "java" %}

Having typed models in your Android apps can greatly improve efficiency and productivity.

Currently, the Couchbase Mobile Android SDK does not provide an abstraction layer over revisions and documents and it can be cumbersome to have to deal with Maps everywhere.

Couchbase Lite Android uses Jackson internally to marshal/un-marshal JSON.

In this post, we’ll explore how to use it to convert the document properties (Map<String, Object>) to POJO classes and vice versa.

To keep things extensible, we’ll define a ModelHelper class with static methods.

## From POJO to Map<String, Object>

Create a new Task.java class with the following fields:

```java
@JsonIgnoreProperties(ignoreUnknown = true)
public class Task {

    @JsonProperty(value = "_id")
    private String documentId;

    private String title;

    @JsonProperty(value = "user_id")
    private int userId;

    private Date createAt;

    // getters, setters...
}
```

Couchbase Lite documents store additional metadata such as the revision id (_rev) and in this case we don’t need it on the model class. We use the @JsonIgnoreProperties annotation to ignore the JSON keys we haven’t specified here.

We can provide the JSON key as well as a custom property name in our models with the  @JsonProperty annotation.

## The ModelHelper class

Now let’s create a new class called ModelHelper.java with a static method to persist a Task model instance as a Couchbase document:

```java
public class ModelHelper {

    public static void save(Database database, Object object) {
        ObjectMapper m = new ObjectMapper();
        Map<String, Object> props = m.convertValue(object, Map.class);
        String id = (String) props.get("_id");

        Document document;
        if (id == null) {
            document = database.createDocument();
        } else {
            document = database.getExistingDocument(id);
            if (document == null) {
                document = database.getDocument(id);
            } else {
                props.put("_rev", document.getProperty("_rev"));
            }
        }

        try {
            document.putProperties(props);
        } catch (CouchbaseLiteException e) {
            e.printStackTrace();
        }
    }

}
```

We can use it in our app like so:

```java
Task task = new Task();
task.setDocumentId("123");
task.setTitle("A simple title");
task.setUserId(987);

ModelHelper.save(database, task);
```

The save method persists new documents as well as document updates. If there isn’t an _id property in the JSON, we can create a new document. Otherwise we check if the document with the _id passed in exists in the database. If it does we replace the _rev property with the latest one and call putProperties to update the document.

## From Map<String, Object> to POJO

Now we might have queries running in our app and we’d like to convert each document to a Task model instance. We can use the same convertValue method from the Jackson API to do so:

```java
public class ModelHelper {

    ...

    public static <T> T modelForDocument(Document document, Class<T> aClass) {
        ObjectMapper m = new ObjectMapper();
        return m.convertValue(document.getProperties(), aClass);
    }

}
```

Now you can create a task model instance from a document:

```java
Document doc = database.getDocument("123");
Task task = ModelHelper.modelForDocument(doc, Task.class);
```

{% elsif site.languages == "c" %}

{% endif %}

## Conclusion

Data modeling is great!