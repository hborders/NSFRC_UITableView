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
                [self.insertedRowIndexPaths addObject:newIndexPath];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeDelete:
            if (indexPath && !newIndexPath) {
                [self.deletedRowIndexPaths addObject:indexPath];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeMove:
            if (indexPath && newIndexPath) {
                // Instead of moving a row around the table, adding and deleting avoids errors that occur when trying to move a row from a deleted section
                [self.deletedRowIndexPaths addObject:indexPath];
                [self.insertedRowIndexPaths addObject:newIndexPath];
            } else {
                abortWithUnexpected();
            }
            break;
    case NSFetchedResultsChangeUpdate:
            if (indexPath && !newIndexPath) {
                [self.updatedRowIndexPaths addObject:indexPath];
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
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // nothing to do, wait for clearAfterApplyingToTableView:
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
}

@end
