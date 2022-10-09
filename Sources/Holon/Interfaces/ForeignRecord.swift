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

public protocol ForeignRecord {
    var allKeys: [String] { get }
    
    func boolValue(for key: String) throws -> Bool
    func intValue(for key: String) throws -> Int
    func doubleValue(for key: String) throws -> Double
    func stringValue(for key: String) throws -> String

    func boolValueIfPresent(for key: String) throws -> Bool?
    func intValueIfPresent(for key: String) throws -> Int?
    func doubleValueIfPresent(for key: String) throws -> Double?
    func stringValueIfPresent(for key: String) throws -> String?
}

extension ForeignRecord {
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

}
