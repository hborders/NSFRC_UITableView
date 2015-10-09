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
    
    var entityManagedObjectContext: NSManagedObjectContext!
    
    // variable format:
    // entity<first value, ordered alphabetically><second value><second order priority>
    // underscore means that the entity is inactive at that stage.
    // examples:
    // entityAa02 will initially have value "A" and be ordered first
    // and after the change will have value "a" and be ordered second
    var entityAa02: Entity!
    var entityBb01: Entity!
    var entityC_  : Entity!
    var entity_c03: Entity!
    var entityE_  : Entity!
    var entityFf09: Entity!
    var entityGG06: Entity!
    var entityHh07: Entity!
    var entity_i08: Entity!
    var entityJJ11: Entity!
    var entityKK10: Entity!
    var entity__  : Entity!
    
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
        
        entityManagedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        entityManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        entityAa02 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityAa02.active = true
        entityAa02.name = "A"
        entityAa02.order = 1
        
        entityBb01 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityBb01.active = true
        entityBb01.name = "B"
        entityBb01.order = 2
        
        entityC_ = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityC_.active = true
        entityC_.name = "C"
        entityC_.order = 3
        
        entity_c03 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entity_c03.active = false
        entity_c03.name = "c"
        entity_c03.order = 3
        
        entityE_ = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityE_.active = true
        entityE_.name = "E"
        entityE_.order = 4
        
        entityFf09 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityFf09.active = true
        entityFf09.name = "F"
        entityFf09.order = 5
        
        entityGG06 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityGG06.active = true
        entityGG06.name = "G"
        entityGG06.order = 6
        
        entityHh07 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityHh07.active = true
        entityHh07.name = "H"
        entityHh07.order = 7
        
        entity_i08 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entity_i08.active = false
        entity_i08.name = "i"
        entity_i08.order = 8
        
        entityJJ11 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityJJ11.active = true
        entityJJ11.name = "J"
        entityJJ11.order = 10
        
        entityKK10 = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entityKK10.active = true
        entityKK10.name = "K"
        entityKK10.order = 11
        
        entity__ = NSEntityDescription.insertNewObjectForEntityForName("Entity",
            inManagedObjectContext: entityManagedObjectContext) as! Entity
        entity__.active = false
        entity__.name = "inactive"
        entity__.order = -1
        
        try! entityManagedObjectContext.save()
        
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
            object: entityManagedObjectContext)
    }
    
    @objc
    func entityManagedObjectContextDidSave(notification: NSNotification) {
        fetchedResultsControllerManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
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
            entityBb01.name = "b"
            entityBb01.order = 1
            
            entityAa02.name = "a"
            entityAa02.order = 2
            
            entityC_.active = false
            
            entity_c03.active = true
            
            entityE_.active = false
            
            // entityGG06 is unchanged
            
            entityHh07.name = "h"
            
            entity_i08.active = true
            
            entityFf09.name = "f"
            entityFf09.order = 9
            
            entityKK10.order = 10
            
            entityJJ11.order = 11
            
            // entity__ is unchanged
            
            try! entityManagedObjectContext.save()
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
