// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 10/08/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public extension Record {
    func asDictionary(includeID: Bool) -> [String:Any] {
        var record: [String:Any] = [:]

        if includeID {
            record["id"] = id
        }
        
        if let prototype = prototype {
            record["type"] = prototype.id
        }
        
        if let entries = entries as? Set<RecordEntry> {
            for entry in entries {
                if let key = entry.key {
                    let value = stat(forKey: key)
                    if let array = value as? Set<Record> {
                        let values = array.map { $0.asDictionary(includeID: includeID) }
                        record[key] = values
                    } else {
                        record[key] = value
                    }
                }
            }
        }
        
        return record
    }
    
    func setFromDictionary(_ record: [String:Any]) {
        let context = managedObjectContext!
        var prototypes: [Record:String] = [:]
        setFromDictionary(record, prototypes: &prototypes)
        
        for (record, id) in prototypes {
            if let instance = Record.withID(id, in: context) {
                record.prototype = instance
            } else {
                print("Missing prototype \(id)")
            }
        }
    }
    
    func setFromDictionary(_ record: [String:Any], prototypes: inout [Record:String]) {

        entries = []
        
        for (key, value) in record {
            switch key {
                case "id":
                    break
                    
                case "type":
                    if let id = value as? String {
                        prototypes[self] = id
                    }
                default:
                    if let list = value as? [[String:Any]] {
                        for subRecord in list {
                            let item = Record(context: managedObjectContext!)
                            item.setFromDictionary(subRecord)
                            append(item, forKey: key)
                        }
                    } else {
                        set(stat: value, forKey: key)
                    }
            }
        }
    }
}
