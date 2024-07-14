//
//  Position+CoreDataProperties.swift
//  
//
//  Created by Frank Leung on 1/6/2024.
//
//

import Foundation
import CoreData


extension Position {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Position> {
        return NSFetchRequest<Position>(entityName: "Position")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var userID: Int32
    @NSManaged public var shares: Int16
    @NSManaged public var totalPrice: NSDecimalNumber?

}
