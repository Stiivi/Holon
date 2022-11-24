//
//  ConstaintChecker.swift
//  
//
//  Created by Stefan Urbanek on 16/06/2022.
//

/// Structure that contains information about a violated constraint. The
/// structure is returned by ``ConstraintChecker/check(graph:)``
///
/// The structure contains a list of nodes and edges that violated the
/// constraint.
///
///
public struct ConstraintViolation: CustomStringConvertible, CustomDebugStringConvertible {
    // TODO: Use constraint reference instead of just a name
    
    /// Constraint that was violated and produced this violation.
    public let constraint: Constraint
    
    /// List of nodes that the constraint evaluated as being offensive.
    ///
    public let nodes: [Node]
    
    /// List of edges that the constraint evaluated as being offensive.
    ///
    public let edges: [Edge]

    /// Name of the violated constraint. Just a convenience reference to
    /// ``Constraint/name``.
    public var name: String { constraint.name }

    /// Human-readable description of the violation.
    ///
    public var description: String {
        if let desc = constraint.description {
            return "\(name): \(desc)"
        }
        else {
            return "\(name) (no detailed violation description)"
        }
    }
    
    public var debugDescription: String {
        "ConstraintViolation(\(name), \(nodes), \(edges)"
    }
}

/// An object that check constraints on a graph.
///
/// ```swift
/// // Given:
/// let graph = Graph()
/// let constraints: [Constraint]
///
/// // Create the checker
/// let checker = ConstraintChecker(constraints)
///
/// let violations = checker.check(graph: graph)
///
/// // Process the violations ...
/// ```
///
/// - ToDo: Yes, this class might have been just a function. It is a separate
///   class for the time being, to make thinking about the problem more
///   explicit. It helps the author for now.
///
public class ConstraintChecker {
    // TODO: This is a separate class to make thinking about the problem more explicit
    // TODO: Yes this class might have been just a function
    // TODO: Maybe convert to: extension Array where Element == Constraint

    /// List of constraints to be checked.
    ///
    let constraints: [Constraint]
    
    /// Create a constraints checker with a list of constraints.
    ///
    /// - SeeAlso: ``Constraint``
    /// 
    public init(constraints: [Constraint]) {
        self.constraints = constraints
    }
    
    /// Check a graph for constraints and returns a list of constraint
    /// violations.
    ///
    public func check(graph: GraphProtocol) -> [ConstraintViolation] {
        var violations: [ConstraintViolation] = []
        
        for constraint in constraints {
            // Get the violators
            let (nodes, edges) = constraint.check(graph)
            
            if nodes.isEmpty && edges.isEmpty {
                continue
            }
            let violation = ConstraintViolation(constraint: constraint,
                                                nodes: nodes,
                                                edges: edges)
            violations.append(violation)

        }

        return violations
    }
}
