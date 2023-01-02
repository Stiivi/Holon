//
//  ForeignRecord.swift
//  
//
//  Created by Stefan Urbanek on 06/10/2022.
//

//struct UntypedRecord {
//    var dict: [AttributeKey:AttributeValue]
//
//    public init(_ dict: [AttributeKey:AttributeValue] = [:]) {
//        self.dict = dict
//    }
//
//    public func stringValue(for key:AttributeKey) throws -> String {
//
//    }
//}

public enum ForeignRecordError: Error {
    case unknownKey(String)
    case typeMismatch(String, String)
}


/// A collection of key-value pairs that store data used for exchange with
/// external environment such as database.
///
public struct ForeignRecord {
    let dict: [String:any ValueProtocol]
    
    public init(_ dictionary: [String:any ValueProtocol]) {
        self.dict = dictionary
    }

    public init(pairs: KeyValuePairs<String,any ValueProtocol>) {
        // FIXME: This method does not work from another package
        
        // I was getting:
        //
        //     Initializer 'init(_:uniquingKeysWith:)' requires the types
        //     'KeyValuePairs<String, any ValueProtocol>.Element'
        //     (aka '(key: String, value: any ValueProtocol)')
        //      and '(String, any ValueProtocol)' be equivalent
        //
        // So I made it this way:
        
        var dict: [String: any ValueProtocol] = [:]
        
        for (key, value) in pairs {
            dict[key] = value
        }
        self.dict = dict
    }

    public var allKeys: [String] {
        return Array(dict.keys)
    }
    
    public func boolValue(for key: String) throws -> Bool {
        guard let value = try boolValueIfPresent(for: key) else {
            throw ForeignRecordError.unknownKey(key)
        }
        return value
    }
    public func intValue(for key: String) throws -> Int {
        guard let value = try intValueIfPresent(for: key) else {
            throw ForeignRecordError.unknownKey(key)
        }
        return value
    }
    public func doubleValue(for key: String) throws -> Double {
        guard let value = try doubleValueIfPresent(for: key) else {
            throw ForeignRecordError.unknownKey(key)
        }
        return value
    }
    public func stringValue(for key: String) throws -> String {
        guard let value = try stringValueIfPresent(for: key) else {
            throw ForeignRecordError.unknownKey(key)
        }
        return value
    }

    public func boolValueIfPresent(for key: String) throws -> Bool? {
        guard let existingValue = dict[key] else {
            return nil
        }
        guard let value = existingValue as? Bool else {
            throw ForeignRecordError.typeMismatch("bool",
                                                  String(describing: type(of: existingValue)))
        }
        return value
    }
    
    public func intValueIfPresent(for key: String) throws -> Int? {
        guard let existingValue = dict[key] else {
            return nil
        }
        guard let value = existingValue as? Int else {
            throw ForeignRecordError.typeMismatch("int",
                                                  String(describing: type(of: existingValue)))
        }
        return value
    }
    
    public func doubleValueIfPresent(for key: String) throws -> Double? {
        guard let existingValue = dict[key] else {
            return nil
        }
        guard let value = existingValue as? Double else {
            throw ForeignRecordError.typeMismatch("double",
                                                  String(describing: type(of: existingValue)))
        }
        return value
    }
    
    public func stringValueIfPresent(for key: String) throws -> String? {
        guard let existingValue = dict[key] else {
            return nil
        }
        guard let value = existingValue as? String else {
            throw ForeignRecordError.typeMismatch("string",
                                                  String(describing: type(of: existingValue)))
        }
        return value
    }
}
