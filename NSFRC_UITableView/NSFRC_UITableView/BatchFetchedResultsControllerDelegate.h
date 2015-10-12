//
//  BatchFetchedResultsControllerDelegate.h
//  NSFRC_UITableView
//
//  Created by Heath Borders on 10/9/15.
//  Copyright © 2015 Heath Borders. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface BatchFetchedResultsControllerDelegate : NSObject<NSFetchedResultsControllerDelegate>

- (void)clearAfterApplyingToTableView:(UITableView *)tableView;

@end
