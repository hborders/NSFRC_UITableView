Using a naive NSFetchedResultsControllerDelegate implementation for a 
UITableView doesn't work on Xcode Version 7.0.1 (7A1001) or
Version 7.1 beta 3 (7B85).

I haven't outlined all the ways that NSFetchedResultsController doesn't
work. However, this test creates a single very complicated transaction,
so it is a good test of NSFetchedResultsController+UITableView 
integration.

Run the app, and tap 'Change Data' to execute the transaction. The 
transaction may only be executed once.

The following behaviors may be changed within the app:
*useInMemoryPersistentStore*
Whether to use a SQLite (NO) or in-memory (YES) persistent store. In the past, I’ve observed different CoreData behaviors with these two stores, so for completeness, it is important to test with both.

*ADD_REMOVE_FETCHED_OBJECTS_WITH_UPDATES*
Whether to add and remove from the NSFetchedResultsController’s fetchedObjects using CoreData updates (YES) or using CoreData inserts and deletes (NO). 
