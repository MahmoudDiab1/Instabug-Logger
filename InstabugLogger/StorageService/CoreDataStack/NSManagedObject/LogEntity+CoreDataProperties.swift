//
//  LogEntity+CoreDataProperties.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//
//

import Foundation
import CoreData


extension LogEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LogEntity> {
        return NSFetchRequest<LogEntity>(entityName: "LogEntity")
    }

    @NSManaged public var message: String
    @NSManaged public var timeStamp: Date
    @NSManaged public var level: String

}

extension LogEntity : Identifiable {

}
