//
//  BatchFetchedResultsControllerDelegate.m
//  NSFRC_UITableView
//
//  Created by Heath Borders on 10/9/15.
//  Copyright © 2015 Heath Borders. All rights reserved.
//

#import "BatchFetchedResultsControllerDelegate.h"

@interface BatchFetchedResultsControllerDelegate()

@property (nonatomic) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic) NSMutableArray *updatedRowIndexPaths;

// When building against iOS9, if an entity moves and needs an update,
// we get an update change and then a move change. However, UITableView
// crashes when we do this:
// Without BatchFetchedResultsController (simply mapping change types to their UITableView equivalents)
// *** Assertion failure in -[_UITableViewUpdateSupport _setupAnimationsForExistingVisibleCells], /SourceCache/UIKit_Sim/UIKit-3347.44.2/UITableViewSupport.m:883
// CoreData: error: Serious application error.  An exception was caught from the delegate of NSFetchedResultsController during a call to -controllerDidChangeContent:.  Attempt to create two animations for cell with userInfo (null)

// With BatchFetchedResultsController:
// *** Assertion failure in -[UITableView _endCellAnimationsWithContext:], /SourceCache/UIKit_Sim/UIKit-3347.44.2/UITableView.m:1222
// CoreData: error: Serious application error.  An exception was caught from the delegate of NSFetchedResultsController during a call to -controllerDidChangeContent:.  attempt to delete and reload the same index path (<NSIndexPath: 0xc000000000000016> {length = 2, path = 0 - 0}) with userInfo (null)
@property (nonatomic) NSIndexPath *maybePreMoveUpdateIndexPath;

@end

@implementation BatchFetchedResultsControllerDelegate

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    void (^abortWithUnexpected)(void) = ^{
        NSLog(@"Unexpected (type, indexPath, newIndexPath): (%@, %@, %@) for object %@ in NSFetchedResultsController: %@",
              @(type),
              indexPath,
              newIndexPath,
              anObject,
              controller);
        abort();
    };
    switch (type) {
        case NSFetchedResultsChangeInsert:
            if (!indexPath && newIndexPath) {
                [self handleMaybeExistingMaybePreMoveUpdate];
                [self.insertedRowIndexPaths addObject:newIndexPath];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeDelete:
            if (indexPath && !newIndexPath) {
                [self handleMaybeExistingMaybePreMoveUpdate];
                [self.deletedRowIndexPaths addObject:indexPath];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeMove:
            if (indexPath && newIndexPath) {
                if ([indexPath isEqual:self.maybePreMoveUpdateIndexPath]) {
                    // Since we need to delete and reinsert the row to
                    // properly move it, we don't need to update it.
                    self.maybePreMoveUpdateIndexPath = nil;
                } else {
                    [self handleMaybeExistingMaybePreMoveUpdate];
                }
                // Instead of moving a row around the table, adding and deleting avoids errors that occur when trying to move a row from a deleted section
                [self.deletedRowIndexPaths addObject:indexPath];
                [self.insertedRowIndexPaths addObject:newIndexPath];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeUpdate:
            if (indexPath && !newIndexPath) {
                self.maybePreMoveUpdateIndexPath = indexPath;
            } else {
                abortWithUnexpected();
            }
            break;
    }
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.deletedRowIndexPaths = [NSMutableArray new];
    self.insertedRowIndexPaths = [NSMutableArray new];
    self.updatedRowIndexPaths = [NSMutableArray new];
    self.maybePreMoveUpdateIndexPath = nil;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // there are no more updates, so it wasn't a pre-move update. :)
    [self handleMaybeExistingMaybePreMoveUpdate];
}

#pragma mark - Public API

- (void)clearAfterApplyingToTableView:(UITableView *)tableView {
    [tableView beginUpdates];
    
    [tableView deleteRowsAtIndexPaths:self.deletedRowIndexPaths
                     withRowAnimation:UITableViewRowAnimationLeft];
    [tableView insertRowsAtIndexPaths:self.insertedRowIndexPaths
                     withRowAnimation:UITableViewRowAnimationFade];
    [tableView reloadRowsAtIndexPaths:self.updatedRowIndexPaths
                     withRowAnimation:UITableViewRowAnimationNone];
    
    [tableView endUpdates];
    
    self.deletedRowIndexPaths = nil;
    self.insertedRowIndexPaths = nil;
    self.updatedRowIndexPaths = nil;
    self.maybePreMoveUpdateIndexPath = nil;
}

#pragma mark - Private API

- (void)handleMaybeExistingMaybePreMoveUpdate {
    if (self.maybePreMoveUpdateIndexPath) {
        // there are no more updates, so it wasn't a pre-move update. :)
        [self.updatedRowIndexPaths addObject:self.maybePreMoveUpdateIndexPath];
        self.maybePreMoveUpdateIndexPath = nil;
    }
}

@end
