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

public enum ConstraintCheckResult: Equatable {
    case success
    case failure(nodes: [NodeID], edges: [EdgeID])
    
    /// List of nodes that violated the constraint
    public var nodes: [NodeID]{
        switch self {
        case .success:
            return []
        case .failure(let nodes, _):
            return nodes
        }
    }
    
    /// List of edges that violated the constraint
    public var edges: [EdgeID]{
        switch self {
        case .success:
            return []
        case .failure(_, let edges):
            return edges
        }
    }
}

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
    func check(_ graph: GraphProtocol) -> ConstraintCheckResult
}

public protocol ObjectConstraintRequirement: EdgeConstraintRequirement, NodeConstraintRequirement {
    func check(graph: GraphProtocol, objects: [Object]) -> [ObjectID]
}

extension ObjectConstraintRequirement {
    public func check(graph: GraphProtocol, edges: [Edge]) -> [EdgeID] {
        return check(graph: graph, objects: edges)
    }
    public func check(graph: GraphProtocol, nodes: [Node]) -> [NodeID] {
        return check(graph: graph, objects: nodes)
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
    public func check(graph: GraphProtocol, objects: [Object]) -> [ObjectID] {
        /// We reject whatever comes in
        return objects.map { $0.id }
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
    public func check(graph: GraphProtocol, objects: [Object]) -> [ObjectID] {
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
    public func check(graph: GraphProtocol, objects: [Object]) -> [ObjectID] {
        var seen: [Value:[ObjectID]] = [:]
        
        for object in objects {
            guard let value = extract(object) else {
                continue
            }
            seen[value, default: []].append(object.id)
        }
        
        let duplicates = seen.filter {
            $0.value.count > 1
        }.flatMap {
            $0.value
        }
        return duplicates
    }
}
