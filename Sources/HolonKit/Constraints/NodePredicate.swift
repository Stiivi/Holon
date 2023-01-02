//
//  NodePredicate.swift
//  
//
//  Created by Stefan Urbanek on 17/06/2022.
//

/// Protocol for a predicate that matches a node.
///
/// Objects conforming to this protocol are expected to implement the method `match()`
///
public protocol NodePredicate: Predicate {
    /// Tests a node whether it matches the predicate.
    ///
    /// - Returns: `true` if the node matches.
    ///
    func match(graph: GraphProtocol, node: Node) -> Bool
}

// TODO: Reason: see generics rant in Predicate.swift
extension NodePredicate {
    // TODO: This is a HACK that assumes I know what I am doing when using this.
    public func match(graph: GraphProtocol, object: Object) -> Bool {
        guard let node = object as? Node else {
            return false
        }
        return match(graph: graph, node: node)
    }
}


/// Predicate that matches any node.
///
public class AnyNodePredicate: NodePredicate {
    public init() {}
    
    /// Matches any node – always returns `true`.
    ///
    public func match(graph: GraphProtocol, node: Node) -> Bool {
        return true
    }
}
