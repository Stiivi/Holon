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
}
extension Link: Hashable {
    // FIXME: Is this 100% OK?
    public static func == (lhs: Link, rhs: Link) -> Bool {
        lhs.id == rhs.id
        && lhs.labels == rhs.labels
        && lhs.origin == rhs.origin
        && lhs.target == rhs.target
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

