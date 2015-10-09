//
//  ViewController.swift
//  TableViewMoveTest
//
//  Created by Heath Borders on 10/8/15.
//  Copyright © 2015 Heath Borders. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    var tableView: UITableView!
    var fetchedResultsControllerManagedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    
    // variable format:
    // entity<first value, ordered alphabetically><second value><second order priority>
    // underscore means that the entity is inactive at that stage.
    // examples:
    // entityAa02 will initially have value "A" and be ordered first
    // and after the change will have value "a" and be ordered second
    var entityAa02ID: NSManagedObjectID!
    var entityBb01ID: NSManagedObjectID!
    var entityC_ID  : NSManagedObjectID!
    var entityD_ID  : NSManagedObjectID!
    var entityEe09ID: NSManagedObjectID!
    var entityFF06ID: NSManagedObjectID!
    var entityGg07ID: NSManagedObjectID!
    var entityJJ11ID: NSManagedObjectID!
    var entityKK10ID: NSManagedObjectID!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(
            frame: self.view.bounds,
            style: .Plain)
        tableView.autoresizingMask = [
            .FlexibleWidth,
            .FlexibleHeight,
        ]
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel(contentsOfURL: NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!)!)
        
        let useInMemoryPersistentStore = true
        if ({ return useInMemoryPersistentStore }()) {
            try! persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
                configuration: .None,
                URL: .None,
                options: .None)
        } else {
            let documentsURL = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
            // force each invocation to get a unique database
            let sqliteURL = documentsURL.URLByAppendingPathComponent(NSUUID().UUIDString)
            
            try! persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: .None,
                URL: sqliteURL,
                options: .None)
        }
        
        let entityManagedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        entityManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        entityManagedObjectContext.performBlockAndWait() {
            self.entityAa02ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "A",
                order: 1)
            self.entityBb01ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "B",
                order: 2)
            self.entityC_ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "C",
                order: 3)
            self.entityD_ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "D",
                order: 4)
            self.entityEe09ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "E",
                order: 5)
            self.entityFF06ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "F",
                order: 6)
            self.entityGg07ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "G",
                order: 7)
            self.entityJJ11ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "J",
                order: 10)
            self.entityKK10ID = entityManagedObjectContext.insertAndSaveEntityWithActive(true,
                name: "K",
                order: 11)
        }
        
        fetchedResultsControllerManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        fetchedResultsControllerManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let fetchRequest = NSFetchRequest(entityName: "Entity")
        fetchRequest.predicate = NSPredicate(format: "active == true")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "order",
                ascending: true),
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: fetchedResultsControllerManagedObjectContext,
            sectionNameKeyPath: .None,
            cacheName: .None)
        
        try! fetchedResultsController.performFetch()
        fetchedResultsController.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "entityManagedObjectContextDidSave:",
            name: NSManagedObjectContextDidSaveNotification,
            object: .None)
    }
    
    @objc
    func entityManagedObjectContextDidSave(notification: NSNotification) {
        func findSavingManagedObjectContextWithKey(key: String) -> NSManagedObjectContext? {
            if let managedObjects = notification.userInfo?[key] as? NSSet {
                for managedObjectObject in managedObjects {
                    if let managedObject = managedObjectObject as? NSManagedObject {
                        if let managedObjectContext = managedObject.managedObjectContext {
                            return managedObjectContext
                        } else {
                            // NSManagedObjectContexts and NSManagedObjects don't retain each other by default
                            // so it's legal for `managedObject.managedObjectContext` to be nil.
                        }
                    } else {
                        fatalError("Expected NSManagedObject: \(managedObjectObject)")
                    }
                }
            }
            return .None
        }
        
        let savingManagedObjectContext: NSManagedObjectContext?
        if let foundSavingManagedObjectContext = findSavingManagedObjectContextWithKey(NSInsertedObjectsKey) {
            savingManagedObjectContext = foundSavingManagedObjectContext
        } else if let foundSavingManagedObjectContext = findSavingManagedObjectContextWithKey(NSUpdatedObjectsKey) {
            savingManagedObjectContext = foundSavingManagedObjectContext
        } else if let foundSavingManagedObjectContext = findSavingManagedObjectContextWithKey(NSDeletedObjectsKey) {
            savingManagedObjectContext = foundSavingManagedObjectContext
        } else {
            savingManagedObjectContext = .None
        }
        
        if let savingManagedObjectContext = savingManagedObjectContext {
            if savingManagedObjectContext.persistentStoreCoordinator === persistentStoreCoordinator &&
                savingManagedObjectContext !== fetchedResultsControllerManagedObjectContext {
                    func printEntitiesForUserInfoKey(key: String) {
                        NSLog("Begin \(key)")
                        if let entityObjects = notification.userInfo?[key] as? NSSet {
                            for entityObject in entityObjects {
                                if let entity = entityObject as? Entity {
                                    NSLog("Entity(active: \(entity.active), name: \(entity.name), order: \(entity.order))")
                                } else {
                                    fatalError("Expected Entity: \(entityObject)")
                                }
                            }
                        }
                        NSLog("End \(key)")
                    }
                    printEntitiesForUserInfoKey(NSInsertedObjectsKey)
                    printEntitiesForUserInfoKey(NSUpdatedObjectsKey)
                    printEntitiesForUserInfoKey(NSDeletedObjectsKey)
                    
                    let useUpdatedManagedObjectsWorkaround = false
                    if ({ return useUpdatedManagedObjectsWorkaround })() {
                        // this method is guaranteed to be called on the saving NSManagedObjectContext's thread.
                        // thus, it is only safe to access the updated NSManagedObjects from here.
                        var updatedOrMovedManagedObjectIDs = [NSManagedObjectID]()
                        func appendManagedObjectIDsFromNSSetInUserInfoWithKey(key: String) {
                            if let managedObjectObjects = notification.userInfo?[key] as? NSSet {
                                for managedObjectObject in managedObjectObjects {
                                    if let managedObject = managedObjectObject as? NSManagedObject {
                                        updatedOrMovedManagedObjectIDs.append(managedObject.objectID)
                                    } else {
                                        fatalError("Expected NSManagedObject: \(managedObjectObject)")
                                    }
                                }
                            }
                        }
                        appendManagedObjectIDsFromNSSetInUserInfoWithKey(NSUpdatedObjectsKey)
                        fetchedResultsControllerManagedObjectContext.performBlock() {
                            // Fix/workaround from http://stackoverflow.com/a/3927811/9636
                            for updatedManagedObjectID in updatedOrMovedManagedObjectIDs {
                                self.fetchedResultsControllerManagedObjectContext.objectWithID(updatedManagedObjectID).willAccessValueForKey(nil)
                            }
                            self.fetchedResultsControllerManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
                        }
                    } else {
                        // this method is guaranteed to be called on the saving NSManagedObjectContext's thread.
                        // we're allowed to pass a notification from this thread into mergeChangesFromContextDidSaveNotification,
                        // but the documentation doesn't say we're allowed to call mergeChangesFromContextDidSaveNotification
                        // from the other thread, so out of caution, we call it on fetchedResultsControllerManagedObjectContext's.
                        fetchedResultsControllerManagedObjectContext.performBlock() {
                            self.fetchedResultsControllerManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
                        }
                    }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return fetchedResultsController.fetchedObjects?.count ?? 0
        case 1:
            return 1
        default:
            fatalError("Unexpected section: \(section)")
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("cell") ?? UITableViewCell(
                style: .Default,
                reuseIdentifier: "cell")
            if let entity = fetchedResultsController.fetchedObjects?[indexPath.row] as? Entity {
                cell.textLabel?.text = "\(entity.name)"
            } else {
                cell.textLabel?.text = "Unexpected object in row: \(indexPath.row)"
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("button") ?? UITableViewCell(
                style: .Default,
                reuseIdentifier: "button")
            cell.textLabel?.text = "Change Data"
            return cell
        default:
            fatalError("Unexpected indexPath: \(indexPath)")
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath,
            animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
            managedObjectContext.performBlock() {
                managedObjectContext.updateEntityWithID(self.entityBb01ID,
                    name: "b",
                    order: 1)
                managedObjectContext.updateEntityWithID(self.entityAa02ID,
                    name: "a",
                    order: 2)
                managedObjectContext.deleteEntityWithID(self.entityC_ID)
                let entity_c03 = managedObjectContext.insertEntityWithActive(true,
                    name: "c",
                    order: 3)
                managedObjectContext.deleteEntityWithID(self.entityD_ID)
                // entityFF06 is unchanged
                managedObjectContext.updateEntityWithID(self.entityGg07ID,
                    name: "g")
                let entity_h08 = managedObjectContext.insertEntityWithActive(true,
                    name: "h",
                    order: 8)
                managedObjectContext.updateEntityWithID(self.entityEe09ID,
                    name: "e",
                    order: 9)
                managedObjectContext.updateEntityWithID(self.entityKK10ID,
                    order: 10)
                managedObjectContext.updateEntityWithID(self.entityJJ11ID,
                    order: 11)
                
                try! managedObjectContext.save()
                
                NSLog("inserted \(entity_c03.name) as \(entity_c03.objectID)")
                NSLog("inserted \(entity_h08.name) as \(entity_h08.objectID)")
            }
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            let entity = anObject as! Entity
            switch (
                type,
                indexPath,
                newIndexPath) {
            case (
                .Insert,
                .None,
                .Some(let newIndexPath)):
                NSLog("inserting \(entity.name) at \(newIndexPath.row)")
                tableView.insertRowsAtIndexPaths([
                    newIndexPath,
                    ],
                    withRowAnimation: .Automatic)
            case (
                .Delete,
                .Some(let indexPath),
                .None):
                NSLog("deleting \(entity.name) at \(indexPath.row)")
                tableView.deleteRowsAtIndexPaths([
                    indexPath,
                    ],
                    withRowAnimation: .Automatic)
            case (
                .Move,
                .Some(let indexPath),
                .Some(let newIndexPath)):
                let representMoveAsDeleteThenInsert = true
                if ({ return representMoveAsDeleteThenInsert }()) {
                    NSLog("deleting \(entity.name) at \(indexPath.row) and inserting at \(newIndexPath.row)")
                    tableView.deleteRowsAtIndexPaths([
                        indexPath,
                        ],
                        withRowAnimation: .Automatic)
                    tableView.insertRowsAtIndexPaths([
                        newIndexPath,
                        ],
                        withRowAnimation: .Automatic)
                } else {
                    NSLog("moving \(entity.name) from \(indexPath.row) to \(newIndexPath.row)")
                    tableView.moveRowAtIndexPath(indexPath,
                        toIndexPath: newIndexPath)
                }
            case (
                .Update,
                .Some(let indexPath),
                .None):
                NSLog("updating \(entity.name) at \(indexPath)")
                tableView.reloadRowsAtIndexPaths([
                    indexPath,
                    ],
                    withRowAnimation: .Automatic)
            default:
                fatalError("Unexpected (type, indexPath, newIndexPath): (\(type), \(indexPath), \(newIndexPath)) for object: \(anObject) in NSFetchedResultsController: \(controller)")
            }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        fatalError("controller:didChangeSection:atIndex:forChangeType: shouldn't be called")
    }
    
    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String? {
        fatalError("controller:sectionIndexTitleForSectionName: shouldn't be called")
    }
}

private extension NSManagedObjectContext {
    func insertAndSaveEntityWithActive(
        active: Bool,
        name: String,
        order: Double) -> NSManagedObjectID {
            let entity = insertEntityWithActive(active,
                name: name,
                order: order)
            
            try! save()
            
            NSLog("Inserted and saved \(name) as \(entity.objectID)")
            
            return entity.objectID
    }
    
    func insertEntityWithActive(
        active: Bool,
        name: String,
        order: Double) -> Entity {
            let entity = NSEntityDescription.insertNewObjectForEntityForName("Entity",
                inManagedObjectContext: self) as! Entity
            entity.active = active
            entity.name = name
            entity.order = order
            
            return entity
    }
    
    func updateEntityWithID(
        entityID: NSManagedObjectID,
        active: Bool? = .None,
        name: String? = .None,
        order: Double? = .None) {
            let entity = self.objectWithID(entityID) as! Entity
            if let active = active {
                entity.active = active
            }
            if let name = name {
                entity.name = name
            }
            if let order = order {
                entity.order = order
            }
    }
    
    func deleteEntityWithID(entityID: NSManagedObjectID) {
        self.deleteObject(self.objectWithID(entityID))
    }
}
