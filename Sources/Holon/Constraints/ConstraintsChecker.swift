//
//  ConstaintChecker.swift
//  
//
//  Created by Stefan Urbanek on 16/06/2022.
//

public struct ConstraintViolation: CustomStringConvertible, CustomDebugStringConvertible {
    // TODO: Use constraint reference instead of just a name
    public let constraint: Constraint
    
    public let nodes: [Node]
    public let links: [Link]

    public var name: String { constraint.name }

    public var description: String {
        if let desc = constraint.description {
            return "\(name): \(desc)"
        }
        else {
            return "\(name) (no detailed violation description)"
        }
    }
    public var debugDescription: String {
        "ConstraintViolation(\(name), \(nodes), \(links)"
    }
}

/// An object that check constraints on a graph.
///
public class ConstraintChecker {
    // TODO: This is a separate class to make thinking about the problem more explicit
    // TODO: Yes this class might have been just a function
    // TODO: Maybe convert to: extension Array where Element == Constraint

    let constraints: [Constraint]
    
    public init(constraints: [Constraint]) {
        self.constraints = constraints
    }
    
    public func check(graph: Graph) -> [ConstraintViolation] {
        var violations: [ConstraintViolation] = []
        
        for constraint in constraints {
            // Get the violators
            let (nodes, links) = constraint.check(graph)
            
            if nodes.isEmpty && links.isEmpty {
                continue
            }
            let violation = ConstraintViolation(constraint: constraint,
                                                nodes: nodes,
                                                links: links)
            violations.append(violation)

        }

        return violations
    }
}
