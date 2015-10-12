//
//  BatchFetchedResultsControllerDelegate.m
//  NSFRC_UITableView
//
//  Created by Heath Borders on 10/9/15.
//  Copyright © 2015 Heath Borders. All rights reserved.
//

#import "BatchFetchedResultsControllerDelegate.h"

@interface Change()

- (void)applyToTableView:(UITableView *)tableView;

@end

@interface BatchFetchedResultsControllerDelegate()

@property (nonatomic) NSMutableArray *changes;

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
                [self.changes addObject:[[Change alloc] initWithIndexPath:indexPath
                                                               changeType:type
                                                             newIndexPath:newIndexPath]];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeDelete:
            if (indexPath && !newIndexPath) {
                [self.changes addObject:[[Change alloc] initWithIndexPath:indexPath
                                                               changeType:type
                                                             newIndexPath:newIndexPath]];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeMove:
            if (indexPath && newIndexPath) {
                // Instead of moving a row around the table, adding and deleting avoids errors that occur when trying to move a row from a deleted section
                [self.changes addObject:[[Change alloc] initWithIndexPath:indexPath
                                                               changeType:NSFetchedResultsChangeDelete
                                                             newIndexPath:newIndexPath]];
                [self.changes addObject:[[Change alloc] initWithIndexPath:indexPath
                                                               changeType:NSFetchedResultsChangeInsert
                                                             newIndexPath:newIndexPath]];
            } else {
                abortWithUnexpected();
            }
            break;
        case NSFetchedResultsChangeUpdate:
            if (indexPath && !newIndexPath) {
                [self.changes addObject:[[Change alloc] initWithIndexPath:indexPath
                                                               changeType:type
                                                             newIndexPath:newIndexPath]];
            } else {
                abortWithUnexpected();
            }
            break;
    }
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.changes = [NSMutableArray new];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // nothing to do.
}

#pragma mark - Public API

- (void)clearAfterApplyingToTableView:(UITableView *)tableView {
    [tableView beginUpdates];
    
    for (Change *change in self.changes) {
        [change applyToTableView:tableView];
    }
    
    [tableView endUpdates];
    
    self.changes = nil;
}

@end

@implementation Change

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath
                       changeType:(NSFetchedResultsChangeType)changeType
                     newIndexPath:(NSIndexPath *)theNewIndexPath {
    self = [super init];
    if (self) {
        self.indexPath = indexPath;
        self.changeType = changeType;
        self.theNewIndexPath = theNewIndexPath;
    }
    return self;
}

- (void)applyToTableView:(UITableView *)tableView {
    switch (self.changeType) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[
                                                self.theNewIndexPath,
                                                ]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[
                                                self.indexPath,
                                                ]
                             withRowAnimation:UITableViewRowAnimationLeft];
            break;
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:self.indexPath
                              toIndexPath:self.theNewIndexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[
                                                self.indexPath,
                                                ]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

@end
