// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 21/07/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import CoreData

public final class RecordEntry: NSManagedObject {
    @NSManaged public var double: Double
    @NSManaged public var integer: Int64
    @NSManaged public var key: String?
    @NSManaged public var string: String?
    @NSManaged public var type: Int16
    @NSManaged public var children: NSSet?
    @NSManaged public var record: Record?
}


extension RecordEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordEntry> {
        return NSFetchRequest<RecordEntry>(entityName: "RecordEntry")
    }


}

// MARK: Generated accessors for children
extension RecordEntry {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Record)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Record)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension RecordEntry : Identifiable {

}
