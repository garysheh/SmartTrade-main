//
//  User+CoreDataProperties.swift
//  
//
//  Created by Frank Leung on 1/6/2024.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userID: Int32
    @NSManaged public var email: String?
    @NSManaged public var password: String?
    @NSManaged public var balance: NSDecimalNumber?
    @NSManaged public var verifyID: UUID?

}
