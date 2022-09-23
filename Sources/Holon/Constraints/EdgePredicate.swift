//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 17/06/2022.
//

/// Protocol for a predicate that matches an edge.
///
/// Objects conforming to this protocol are expected to implement the method
/// `match(from:, to:, labels:)`.
///
public protocol EdgePredicate: Predicate {
    /// Tests an edge whether it matches the predicate.
    ///
    /// - Returns: `true` if the edge matches.
    ///
    /// Default implementation calls `match(from:,to:,labels:)`
    ///
    func match(_ edge: Edge) -> Bool
}

// TODO: Reason: see generics rant in Predicate.swift
extension EdgePredicate {
    // TODO: This is a HACK that assumes I know what I am doing when using this.
    public func match(_ object: Object) -> Bool {
        guard let edge = object as? Edge else {
            return false
        }
        return match(edge)
    }
}

/// Predicate that tests the edge object itself together with its objects -
/// origin and target.
///
public class EdgeObjectPredicate: EdgePredicate {
    // FIXME: Merge with EdgeLabelsPredicate!!!
    // TODO: Use CompoundPredicate
    // FIXME: I do not like this class
    
    let originPredicate: NodePredicate?
    let targetPredicate: NodePredicate?
    let edgePredicate: EdgePredicate?
    
    public init(origin: NodePredicate? = nil, target: NodePredicate? = nil, edge: EdgePredicate? = nil) {
        guard !(origin == nil && target == nil && edge == nil) else {
            preconditionFailure("At least one of the parameters must be set: origin, target or edge")
        }
        
        self.originPredicate = origin
        self.targetPredicate = target
        self.edgePredicate = edge
    }
    
    public func match(_ edge: Edge) -> Bool {
        if let predicate = originPredicate, !predicate.match(edge.origin) {
            return false
        }
        if let predicate = targetPredicate, !predicate.match(edge.target) {
            return false
        }
        if let predicate = edgePredicate, !predicate.match(edge) {
            return false
        }
        return true
    }
}
