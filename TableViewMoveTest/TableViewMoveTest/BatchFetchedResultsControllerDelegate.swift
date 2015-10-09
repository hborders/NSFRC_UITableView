//
//  BatchFetchedResultsControllerDelegate.swift
//  Pods
//
//  Created by Heath Borders on 6/8/15.
//
//

import Foundation
import CoreData
import UIKit

// adapted from http://www.fruitstandsoftware.com/blog/2013/02/19/uitableview-and-nsfetchedresultscontroller-updates-done-right/
// which is licensed under CC Attribution. Need to figure out what this means for us or if I even need to worry about it:
// https://twitter.com/MrRooni/status/607938115274031104
@objc
public class BatchFetchedResultsControllerDelegate: NSObject {
    
    public override init() {}
    
    // MARK: Public API
    
    public var deletedSectionIndexes: NSIndexSet {
        switch state {
        case .Done(let changeBag):
            return changeBag.deletedSectionIndexes
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    public var insertedSectionIndexes: NSIndexSet {
        switch state {
        case .Done(let changeBag):
            return changeBag.insertedSectionIndexes
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    public var deletedRowIndexPaths: [NSIndexPath] {
        switch state {
        case .Done(let changeBag):
            return changeBag.deletedRowIndexPaths
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    public var insertedRowIndexPaths: [NSIndexPath] {
        switch state {
        case .Done(let changeBag):
            return changeBag.insertedRowIndexPaths
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    public var updatedRowIndexPaths: [NSIndexPath] {
        switch state {
        case .Done(let changeBag):
            return changeBag.updatedRowIndexPaths
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    public var movedIndexPaths: [NSIndexPath] {
        switch state {
        case .Done(let changeBag):
            return changeBag.movedIndexPaths
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    public func clear() {
        switch state {
        case .AwaitingWillChangeContent, .Done:
            state = .AwaitingWillChangeContent
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    public func clearAfterApplyingToTableView(tableView: UITableView) {
        switch state {
        case .Done(let changeBag):
            tableView.beginUpdates()
            
            tableView.deleteSections(changeBag.deletedSectionIndexes,
                withRowAnimation: .Left)
            tableView.insertSections(changeBag.insertedSectionIndexes,
                withRowAnimation: .Fade)
            
            tableView.deleteRowsAtIndexPaths(changeBag.deletedRowIndexPaths,
                withRowAnimation: .Left)
            tableView.insertRowsAtIndexPaths(changeBag.insertedRowIndexPaths,
                withRowAnimation: .Fade)
            tableView.reloadRowsAtIndexPaths(changeBag.updatedRowIndexPaths,
                withRowAnimation: .None)
            
            tableView.endUpdates()
            
            clear()
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    public func clearAfterApplyingToCollectionView(collectionView: UICollectionView) {
        switch state {
        case .Done(let changeBag):
            collectionView.performBatchUpdates({
                collectionView.deleteSections(changeBag.deletedSectionIndexes)
                collectionView.insertSections(changeBag.insertedSectionIndexes)
                
                collectionView.deleteItemsAtIndexPaths(changeBag.deletedRowIndexPaths)
                collectionView.insertItemsAtIndexPaths(changeBag.insertedRowIndexPaths)
                collectionView.reloadItemsAtIndexPaths(changeBag.updatedRowIndexPaths)
                },
                completion: .None)
            
            clear()
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    // MARK: Private API
    
    private var state: State = .AwaitingWillChangeContent
}

extension BatchFetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate {
    @objc
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        switch state {
        case .AwaitingWillChangeContent, .Done:
            state = .Changing(ChangeBag())
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
    
    @objc
    public func controller(
        controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            switch state {
            case .Changing(var changeBag):
                switch (
                    type,
                    indexPath,
                    newIndexPath) {
                case (
                    .Insert,
                    .None,
                    .Some(let newIndexPath)):
                    if changeBag.insertedSectionIndexes.containsIndex(newIndexPath.section) {
                        // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
                    } else {
                        changeBag.insertedRowIndexPaths.append(newIndexPath)
                    }
                case (
                    .Delete,
                    .Some(let indexPath),
                    .None):
                    if changeBag.deletedSectionIndexes.containsIndex(indexPath.section) {
                        // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
                    } else {
                        changeBag.deletedRowIndexPaths.append(indexPath);
                    }
                case (
                    .Move,
                    .Some(let indexPath),
                    .Some(let newIndexPath)):
                    // Instead of moving a row around the table, adding and deleting avoids errors that occur when trying to move a row from a deleted section
                    changeBag.deletedRowIndexPaths.append(indexPath)
                    changeBag.insertedRowIndexPaths.append(newIndexPath)
                case (
                    .Update,
                    .Some(let indexPath),
                    .None):
                    changeBag.updatedRowIndexPaths.append(indexPath)
                default:
                    fatalError("Unexpected (type, indexPath, newIndexPath): (\(type), \(indexPath), \(newIndexPath)) for object: \(anObject) in NSFetchedResultsController: \(controller)")
                }
                
                state = .Changing(changeBag)
            case let illegalState:
                fatalError("Illegal state: \(illegalState)")
            }
    }
    
    @objc
    public func controller(
        controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            switch state {
            case .Changing(let changeBag):
                switch type {
                case .Insert:
                    changeBag.insertedSectionIndexes.addIndex(sectionIndex)
                case .Delete:
                    changeBag.deletedSectionIndexes.addIndex(sectionIndex)
                default:
                    fatalError("Unexpected type: \(type) for sectionInfo: \(sectionInfo) at index: \(sectionIndex) in NSFetchedResultsController: \(controller)")
                }
                
                state = .Changing(changeBag)
            case let illegalState:
                fatalError("Illegal state: \(illegalState)")
            }
    }
    
    @objc
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        switch state {
        case .Changing(let changeBag):
            state = .Done(changeBag)
        case let illegalState:
            fatalError("Illegal state: \(illegalState)")
        }
    }
}

private struct ChangeBag {
    let deletedSectionIndexes = NSMutableIndexSet()
    let insertedSectionIndexes = NSMutableIndexSet()
    var deletedRowIndexPaths = [NSIndexPath]()
    var insertedRowIndexPaths = [NSIndexPath]()
    var updatedRowIndexPaths = [NSIndexPath]()
    var movedIndexPaths = [NSIndexPath]()
    
    var totalChanges: Int {
        return
            deletedSectionIndexes.count +
                insertedSectionIndexes.count +
                deletedRowIndexPaths.count +
                insertedRowIndexPaths.count +
                updatedRowIndexPaths.count
    }
}

private enum State {
    case AwaitingWillChangeContent
    case Changing(ChangeBag)
    case Done(ChangeBag)
}
