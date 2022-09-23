//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 13/06/2022.
//

/*

 Potential merge:
 
 - class Constraint(name:, match:, requirement)
 - match is a graph object Predicate which matches either nodes or edges
 - requirement is ConstraintRequirement
 
 */

/// Protocol for objects that define a graph constraint.
///
/// For concrete constraints see: ``EdgeConstraint`` and ``NodeConstraint``.
///
public protocol Constraint {
    /// Identifier of the constraint.
    ///
    /// - Important: It is highly recommended that the constraint names are
    /// unique within an application, to communicate issues to the user clearly.
    ///
    var name: String { get }
    // TODO: Rename to non-conflicting attribute, like "message"
    /// Human-readable description of the constraint. The recommended content
    /// can be:
    ///
    /// - What an edge or a node must be?
    /// - What an edge or a node must have?
    /// - What an edge endpoint - origin or target - must point to?
    ///
    var description: String? { get }

    /// A function that checks whether the graph satisfies the constraint.
    /// Returns a list of nodes and edges that violate the constraint.
    ///
    func check(_ graph: Graph) -> (nodes: [Node], edges: [Edge])
}

public protocol ObjectConstraintRequirement: EdgeConstraintRequirement, NodeConstraintRequirement {
    func check(objects: [Object]) -> [Object]
}

extension ObjectConstraintRequirement {
    public func check(_ edges: [Edge]) -> [Edge] {
        return check(objects: edges).map { $0 as! Edge }
    }
    public func check(_ nodes: [Node]) -> [Node] {
        return check(objects: nodes).map { $0 as! Node }
    }
}

/// A constraint requirement that is used to specify object (edges or nodes)
/// that are prohibited. If the constraint requirement is used, then it
/// matches all objects defined by constraint predicate and rejects them all.
///
public class RejectAll: ObjectConstraintRequirement {
    /// Creates an object constraint requirement that rejects all objects.
    ///
    public init() {
    }
   
    /// Returns all objects it is provided – meaning, that all of them are
    /// violating the constraint.
    ///
    public func check(objects: [Object]) -> [Object] {
        /// We reject whatever comes in
        return objects
    }
}

/// A constraint requirement that is used to specify object (edges or nodes)
/// that are required. If the constraint requirement is used, then it
/// matches all objects defined by constraint predicate and accepts them all.
///
public class AcceptAll: ObjectConstraintRequirement {
    /// Creates an object constraint requirement that accepts all objects.
    ///
    public init() {
    }
   
    /// Returns an empty list, meaning that none of the objects are violating
    /// the constraint.
    ///
    public func check(objects: [Object]) -> [Object] {
        // We accept everything, therefore we do not return any violations.
        return []
    }
}

/// A constraint requirement that a specified property of the objects must
/// be unique within the checked group of checked objects.
///
public class UniqueProperty<Value>: ObjectConstraintRequirement
        where Value: Hashable {
    
    /// A function that extracts the value to be checked for uniqueness from
    /// a graph object (edge or a node)
    public var extract: (Object) -> Value?
    
    /// Creates a unique property constraint requirement with a function
    /// that extracts a property from a graph object.
    ///
    public init(_ extract: @escaping (Object) -> Value?) {
        self.extract = extract
    }
    
    /// Checks the objects for the requirement. The function extracts the
    /// value from each of the objects and returns a list of those objects
    /// that have duplicate values.
    /// 
    public func check(objects: [Object]) -> [Object] {
        var seen: [Value:Array<Object>] = [:]
        
        for object in objects {
            guard let value = extract(object) else {
                continue
            }
            
            if seen[value] == nil {
                seen[value] = [object]
            }
            else {
                seen[value]!.append(object)
            }
        }
        
        let duplicates = seen.filter {
            $0.value.count > 1
        }.flatMap {
            $0.value
        }
        return duplicates
    }
}
