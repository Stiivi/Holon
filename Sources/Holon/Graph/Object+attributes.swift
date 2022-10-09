//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 17/07/2022.
//
//  Ported from Tarot.


/// Type for object attribute key.
public typealias AttributeKey = String

/// Type for object attribute values.
public typealias AttributeValue = ValueProtocol

/// Type for a dictionary of graph object attributes.
public typealias AttributeDictionary = [AttributeKey:AttributeValue]

/// A protocol for objects that provide their attributes by keys.
///
public protocol KeyedValues {
    /// List of attributes that the object provides.
    ///
    var attributeKeys: [AttributeKey] { get }
    
    /// Returns a dictionary of attributes.
    ///
    func dictionary(withKeys: [AttributeKey]) -> AttributeDictionary

    /// Returns an attribute value for given key.
    ///
    func attribute(forKey key: String) -> AttributeValue?
///    subscript(key: AttributeKey) -> AttributeValue? { get }
}

extension KeyedValues {
    public func dictionary(withKeys: [AttributeKey]) -> AttributeDictionary {
        let tuples = attributeKeys.compactMap { key in
            self.attribute(forKey: key).map { (key, $0) }
        }

        return AttributeDictionary(uniqueKeysWithValues: tuples)
    }
}

/// Protocol for objects where attributes can be modified by using the attribute
/// names.
///
/// This protocol is provided for inspectors and import/export functionality.
///
public protocol MutableKeyedValues {
    func setAttribute(value: AttributeValue, forKey key: AttributeKey)
    func setAttributes(_ dict: AttributeDictionary)
}

extension MutableKeyedValues {
    public func setAttributes(_ dict: AttributeDictionary) {
        for (key, value) in dict {
            self.setAttribute(value: value, forKey: key)
        }
    }

}

