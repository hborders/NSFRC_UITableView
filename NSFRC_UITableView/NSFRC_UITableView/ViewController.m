//
//  ViewController.m
//  NSFRC_UITableView
//
//  Created by Heath Borders on 10/9/15.
//  Copyright © 2015 Heath Borders. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "BatchFetchedResultsControllerDelegate.h"
#import "Entity.h"

@interface NSManagedObjectContext(ViewController)

- (NSManagedObjectID *)insertAndSaveEntityWithActive:(BOOL)active
                                                name:(NSString *)name
                                               order:(double)order;
- (Entity *)insertEntityWithActive:(BOOL)active
                              name:(NSString *)name
                             order:(double)order;

- (void)updateEntityWithID:(NSManagedObjectID *)entityID
                    active:(NSNumber *)active
                      name:(NSString *)name
                     order:(NSNumber *)order;

- (void)deleteEntityWIthID:(NSManagedObjectID *)entityID;

@end

NSString *stringFromFetchedResultsChangeType(NSFetchedResultsChangeType type) {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            return @"Insert";
        case NSFetchedResultsChangeDelete:
            return @"Delete";
        case NSFetchedResultsChangeUpdate:
            return @"Update";
        case NSFetchedResultsChangeMove:
            return @"Move";
    }
}

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSManagedObjectContext *fetchedResultsControllerManagedObjectContext;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BatchFetchedResultsControllerDelegate *batchFetchedResultsControllerDelegate;

@property (nonatomic) NSManagedObjectID *entityAa02ID;
@property (nonatomic) NSManagedObjectID *entityBb01ID;
@property (nonatomic) NSManagedObjectID *entityC_ID;
@property (nonatomic) NSManagedObjectID *entityD_ID;
@property (nonatomic) NSManagedObjectID *entityEe09ID;
@property (nonatomic) NSManagedObjectID *entityFF06ID;
@property (nonatomic) NSManagedObjectID *entityGg07ID;
@property (nonatomic) NSManagedObjectID *entityJJ11ID;
@property (nonatomic) NSManagedObjectID *entityKK10ID;

@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"]]];
    
    BOOL useInMemoryPersistentStore = NO;
    if (useInMemoryPersistentStore) {
        if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                           configuration:nil
                                                                     URL:nil
                                                                 options:nil
                                                                   error:NULL]) {
            abort();
        }
    } else {
        NSURL *documentsURL = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0]];
        // force each invocation to get a unique database
        NSURL *sqliteURL = [documentsURL URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
        if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:sqliteURL
                                                                 options:nil
                                                                   error:NULL]) {
            abort();
        }
    }
    
    NSManagedObjectContext *insertingManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    insertingManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    [insertingManagedObjectContext performBlockAndWait:^{
        self.entityAa02ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"A"
                                                                                   order:1];
        self.entityBb01ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"B"
                                                                                   order:2];
        self.entityC_ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                  name:@"C"
                                                                                 order:3];
        self.entityD_ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                  name:@"D"
                                                                                 order:4];
        self.entityEe09ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"E"
                                                                                   order:5];
        self.entityFF06ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"F"
                                                                                   order:6];
        self.entityGg07ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"G"
                                                                                   order:7];
        self.entityJJ11ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"J"
                                                                                   order:10];
        self.entityKK10ID = [insertingManagedObjectContext insertAndSaveEntityWithActive:YES
                                                                                    name:@"K"
                                                                                   order:11];
    }];
    
    self.fetchedResultsControllerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.fetchedResultsControllerManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"active == true"];
    fetchRequest.sortDescriptors = @[
                                     [NSSortDescriptor sortDescriptorWithKey:@"order"
                                                                   ascending:YES],
                                     ];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.fetchedResultsControllerManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.batchFetchedResultsControllerDelegate = [BatchFetchedResultsControllerDelegate new];
    
    [self.fetchedResultsController performFetch:NULL];
    self.fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(managedObjectContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.fetchedResultsController.fetchedObjects.count;
        case 1:
            return 1;
        default:
            NSLog(@"Unexpected section: %@", @(section));
            abort();
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"cell"];
            }
            Entity *entity = self.fetchedResultsController.fetchedObjects[indexPath.row];
            if (entity) {
                cell.textLabel.text = entity.name;
            } else {
                cell.textLabel.text = [NSString stringWithFormat:@"Unexpected object in row: %@",
                                       @(indexPath.row)];
            }
            
            return cell;
        }
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"button"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"button"];
            }
            cell.textLabel.text = @"Change Data";
            return cell;
        }
            
        default:
            NSLog(@"Unexpected indexPath section: %@", @(indexPath.section));
            abort();
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [managedObjectContext performBlock:^{
            [managedObjectContext updateEntityWithID:self.entityBb01ID
                                              active:nil
                                                name:@"b"
                                               order:@(1)];
            [managedObjectContext updateEntityWithID:self.entityAa02ID
                                              active:nil
                                                name:@"a"
                                               order:@(2)];
            [managedObjectContext deleteEntityWIthID:self.entityC_ID];
            Entity *entity_c03 = [managedObjectContext insertEntityWithActive:YES
                                                                         name:@"c"
                                                                        order:3];
            [managedObjectContext deleteEntityWIthID:self.entityD_ID];
            // entityFF06 is unchanged
            [managedObjectContext updateEntityWithID:self.entityGg07ID
                                              active:nil
                                                name:@"g"
                                               order:nil];
            Entity *entity_h08 = [managedObjectContext insertEntityWithActive:YES
                                                                         name:@"h"
                                                                        order:8];
            [managedObjectContext updateEntityWithID:self.entityEe09ID
                                              active:nil
                                                name:@"e"
                                               order:@(9)];
            [managedObjectContext updateEntityWithID:self.entityKK10ID
                                              active:nil
                                                name:nil
                                               order:@(10)];
            [managedObjectContext updateEntityWithID:self.entityJJ11ID
                                              active:nil
                                                name:nil
                                               order:@(11)];
            
            [managedObjectContext save:NULL];
            
            NSLog(@"inserted %@ as %@", entity_c03.name, entity_c03.objectID);
            NSLog(@"inserted %@ as %@", entity_h08.name, entity_h08.objectID);
        }];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.batchFetchedResultsControllerDelegate controllerWillChangeContent:controller];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    Entity *entity = anObject;
    NSLog(@"entity: %@, type: %@, indexPath: %@, newIndexPath: %@",
          entity.name,
          stringFromFetchedResultsChangeType(type),
          indexPath,
          newIndexPath);
    [self.batchFetchedResultsControllerDelegate controller:controller
                                           didChangeObject:anObject
                                               atIndexPath:indexPath
                                             forChangeType:type
                                              newIndexPath:newIndexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.batchFetchedResultsControllerDelegate controllerDidChangeContent:controller];
    [self.batchFetchedResultsControllerDelegate clearAfterApplyingToTableView:self.tableView];
}

#pragma mark - notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    NSManagedObjectContext *(^findSavingManagedObjectContext)(NSString *) = ^(NSString *key) {
        NSSet *managedObjects = notification.userInfo[key];
        for (NSManagedObject *managedObject in managedObjects) {
            NSManagedObjectContext *managedObjectContext = managedObject.managedObjectContext;
            if (managedObjectContext) {
                return managedObjectContext;
            } else {
                // NSManagedObjectContexts and NSManagedObjects don't retain each other by default
                // so it's legal for `managedObject.managedObjectContext` to be nil.
            }
        }
        
        return (NSManagedObjectContext *)nil;
    };
    
    NSManagedObjectContext *savingManagedObjectContext = findSavingManagedObjectContext(NSInsertedObjectsKey);
    if (!savingManagedObjectContext) {
        savingManagedObjectContext = findSavingManagedObjectContext(NSUpdatedObjectsKey);
    }
    if (!savingManagedObjectContext) {
        savingManagedObjectContext = findSavingManagedObjectContext(NSDeletedObjectsKey);
    }
    
    if (savingManagedObjectContext &&
        savingManagedObjectContext.persistentStoreCoordinator == self.persistentStoreCoordinator &&
        savingManagedObjectContext != self.fetchedResultsControllerManagedObjectContext) {
        void (^printEntitiesForUserInfoKey)(NSString *) = ^(NSString *key) {
            NSLog(@"Begin %@", key);
            
            for (Entity *entity in notification.userInfo[key]) {
                NSLog(@"Entity(active: %@, name: %@, order: %@)",
                      @(entity.active),
                      entity.name,
                      @(entity.order));
            }
            
            NSLog(@"End %@", key);
        };
        
        printEntitiesForUserInfoKey(NSInsertedObjectsKey);
        printEntitiesForUserInfoKey(NSUpdatedObjectsKey);
        printEntitiesForUserInfoKey(NSDeletedObjectsKey);
        
        BOOL useUpdatedManagedObjectsWorkaround = YES;
        if (useUpdatedManagedObjectsWorkaround) {
            // this method is guaranteed to be called on the saving NSManagedObjectContext's thread.
            // thus, it is only safe to access the updated NSManagedObjects from here.
            NSMutableArray *updatedOrMovedManagedObjectIDs = [NSMutableArray new];
            void (^appendManagedObjectIDsFromNSSetInUserInfoWithKey)(NSString *) = ^(NSString *key) {
                for (NSManagedObject *managedObject in notification.userInfo[key]) {
                    [updatedOrMovedManagedObjectIDs addObject:managedObject.objectID];
                }
            };
            appendManagedObjectIDsFromNSSetInUserInfoWithKey(NSUpdatedObjectsKey);
            [self.fetchedResultsControllerManagedObjectContext performBlock:^{
                // Fix/workaround from http://stackoverflow.com/a/3927811/9636
                for (NSManagedObjectID *updatedManagedObjectID in updatedOrMovedManagedObjectIDs) {
                    [[self.fetchedResultsControllerManagedObjectContext objectWithID:updatedManagedObjectID] willAccessValueForKey:nil];
                }
                [self.fetchedResultsControllerManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            }];
        } else {
            // this method is guaranteed to be called on the saving NSManagedObjectContext's thread.
            // we're allowed to pass a notification from this thread into mergeChangesFromContextDidSaveNotification,
            // but the documentation doesn't say we're allowed to call mergeChangesFromContextDidSaveNotification
            // from the other thread, so out of caution, we call it on fetchedResultsControllerManagedObjectContext's.
            [self.fetchedResultsControllerManagedObjectContext performBlock:^{
                [self.fetchedResultsControllerManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
            }];
        }
    }
}

@end

@implementation NSManagedObjectContext(ViewController)

- (NSManagedObjectID *)insertAndSaveEntityWithActive:(BOOL)active
                                                name:(NSString *)name
                                               order:(double)order {
    Entity *entity = [self insertEntityWithActive:active
                                             name:name
                                            order:order];
    
    [self save:NULL];
    
    NSLog(@"Inserted and saved %@ as %@", name, entity.objectID);
    
    return entity.objectID;
}

- (Entity *)insertEntityWithActive:(BOOL)active
                              name:(NSString *)name
                             order:(double)order {
    Entity *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                                   inManagedObjectContext:self];
    entity.active = active;
    entity.name = name;
    entity.order = order;
    
    return entity;
}

- (void)updateEntityWithID:(NSManagedObjectID *)entityID
                    active:(NSNumber *)active
                      name:(NSString *)name
                     order:(NSNumber *)order {
    Entity *entity = (Entity *)[self objectWithID:entityID];
    if (active) {
        entity.active = [active boolValue];
    }
    if (name) {
        entity.name = name;
    }
    if (order) {
        entity.order = [order doubleValue];
    }
}

- (void)deleteEntityWIthID:(NSManagedObjectID *)entityID {
    [self deleteObject:[self objectWithID:entityID]];
}

@end
