//
//  Transaction+CoreDataProperties.swift
//  
//
//  Created by Frank Leung on 1/6/2024.
//
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var transactionID: UUID?
    @NSManaged public var useID: Int32
    @NSManaged public var symbol: String?
    @NSManaged public var shares: Int16
    @NSManaged public var perPrice: NSDecimalNumber?
    @NSManaged public var totalPrice: NSDecimalNumber?
    @NSManaged public var time: Date?

}
