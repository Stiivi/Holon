//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

/// Link represents a graph edge - conection between two nodes.
///
/// The links in the graph have an origin node and a target node associated
/// with it. The links are oriented for convenience and for most likely use
/// cases. Despite most of the functionality might be using the orientation,
/// it does not prevent one to treat the links as non-oriented.
///
public class Link: Object {
    
//    /// Special link type
//    ///
//    enum InternalKind {
//        case `default`
//        /// Origin is a holon's child, target is a holon
//        /// Arity: One-to-Many
//        case holon
//        /// Origin is a port, target is port's represented node.
//        /// Arity: Many-to-One
//        case representedNode
//        case indirectOrigin
//        case indirectTarget
//        case indirectEndpoints
//    }
//    let internalKind: InternalKind = .`default`
    
    /// Origin node of the link - a node from which the link points from.
    ///
    public let origin: Node
    /// Target node of the link - a node to which the link points to.
    ///
    public let target: Node
    
    init(origin: Node, target: Node, labels: LabelSet=[], id: OID? = nil) {
        self.origin = origin
        self.target = target
        super.init(id: id, labels: labels)
    }
    
    
    public override var description: String {
        return "Link(id: \(idDebugString), \(origin.idDebugString) -> \(target.idDebugString), labels: \(labels.sorted()))"
    }
    
    public static func == (lhs: Link, rhs: Link) -> Bool {
        (lhs as Object == rhs as Object)
        && lhs.origin == rhs.origin && lhs.target == rhs.target
    }
}

