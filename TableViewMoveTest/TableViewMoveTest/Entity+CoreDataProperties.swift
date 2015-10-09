//
//  Entity+CoreDataProperties.swift
//  TableViewMoveTest
//
//  Created by Heath Borders on 10/9/15.
//  Copyright © 2015 Heath Borders. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Entity {

    @NSManaged var order: Double
    @NSManaged var name: String
    @NSManaged var active: Bool

}
