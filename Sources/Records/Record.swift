// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 13/07/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftUI
import CoreData
import CoreDataExtensions

public final class Record: NSManagedObject, IdentifiedManagedObject {
    public enum EntryType: Int {
        case array
        case string
        case integer
        case double
        case bool
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var id: String
    @NSManaged public var entries: NSSet?
    @NSManaged public var parent: RecordEntry?
    @NSManaged public var protoclients: NSSet?
    @NSManaged public var prototype: Record?

    public override func awakeFromInsert() {
        id = UUID().uuidString
    }
}

public extension Record {
    func has(key: String) -> Bool {
        guard let stats = entries as? Set<RecordEntry> else { return false}
        return stats.contains(where: { $0.key == key })
    }
    
    func entry(forKey key: String) -> RecordEntry? {
        if let stats = entries as? Set<RecordEntry>, let stat = stats.first(where: { $0.key == key }) {
            return stat
        }

        return prototype?.entry(forKey: key)
    }
    
    func stat(forKey key: String) -> Any? {
        guard let stat = entry(forKey: key) else { return nil }
        guard let type = EntryType(rawValue: Int(stat.type)) else { return nil }
        switch type {
            case .integer: return Int(stat.integer)
            case .string: return stat.string
            case .array: return stat.children as? Set<Record>
            case .double: return stat.double
            case .bool: return stat.integer != 0
        }
    }
    
    func string(forKey key: String) -> String? {
        return stat(forKey: key) as? String
    }

    func integer(forKey key: String) -> Int? {
        return stat(forKey: key) as? Int
    }

    func double(forKey key: String) -> Double? {
        return stat(forKey: key) as? Double
    }

    func bool(forKey key: String) -> Bool? {
        return stat(forKey: key) as? Bool
    }
    
    func guaranteedEntry(forKey key: String) -> RecordEntry {
        if let stats = entries as? Set<RecordEntry>, let stat = stats.first(where: { $0.key == key }) {
            return stat
        } else {
            let stat = RecordEntry(context: managedObjectContext!)
            stat.key = key
            stat.record = self
            return stat
        }
    }
    
    func set(stat: Any, forKey key: String) {
        switch stat {
            case is String: set(stat as! String, forKey: key)
            case is Int: set(stat as! Int, forKey: key)
            case is Double: set(stat as! Double, forKey: key)
            case is Bool: set(stat as! Bool, forKey: key)
            default:
                print("Can't store \(stat) (\(type(of: stat)))")
                break
        }
    }
    
    func set(_ string: String, forKey key: String) {
        let entry = guaranteedEntry(forKey: key)
        let type = Int16(EntryType.string.rawValue)
        if (entry.type != type) || (entry.string != string) {
            objectWillChange.send()
            entry.string = string
            entry.type = type
        }
    }

    func set(_ integer: Int, forKey key: String) {
        let entry = guaranteedEntry(forKey: key)
        let type = Int16(EntryType.integer.rawValue)
        let newValue = Int64(integer)
        if (entry.type != type) || (entry.integer != newValue) {
            objectWillChange.send()
            entry.integer = newValue
            entry.type = type
        }
    }

    func set(_ double: Double, forKey key: String) {
        let entry = guaranteedEntry(forKey: key)
        let type = Int16(EntryType.double.rawValue)
        if (entry.type != type) || (entry.double != double) {
            objectWillChange.send()
            entry.double = double
            entry.type = type
        }
    }

    func set(_ bool: Bool, forKey key: String) {
        let entry = guaranteedEntry(forKey: key)
        let type = Int16(EntryType.bool.rawValue)
        let newValue = Int64(bool ? 1 : 0)
        if (entry.type != type) || (entry.integer != newValue) {
            objectWillChange.send()
            entry.integer = newValue
            entry.type = type
        }
    }

    func append(_ record: Record, forKey key: String) {
        let entry = guaranteedEntry(forKey: key)
        objectWillChange.send()
        record.parent = entry
        entry.type = Int16(EntryType.array.rawValue)
    }
    
    func stringBinding(forKey key: String) -> Binding<String> {
        return Binding<String>(
            get: { self.string(forKey: key) ?? "" },
            set: { newValue in self.set(newValue, forKey: key) }
            )
    }

    func integerBinding(forKey key: String) -> Binding<Int> {
        return Binding<Int>(
            get: { self.integer(forKey: key) ?? 0 },
            set: { newValue in self.set(newValue, forKey: key) }
            )
    }

    func doubleBinding(forKey key: String) -> Binding<Double> {
        return Binding<Double>(
            get: { self.double(forKey: key) ?? 0 },
            set: { newValue in self.set(newValue, forKey: key) }
            )
    }

    func save() throws {
        try managedObjectContext?.save()
    }
}
