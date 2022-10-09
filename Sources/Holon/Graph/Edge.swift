//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

/// Edge represents a connection between two nodes.
///
/// The edges in the graph have an origin node and a target node associated
/// with it. The edges are oriented for convenience and for most likely use
/// cases. Despite most of the functionality might be using the orientation,
/// it does not prevent one to treat the edges as non-oriented.
///
open class Edge: Object, PersistableEdge {
    
    public var persistableTypeName: String { "Edge" }
    required public convenience init(origin: Node,
                                     target: Node,
                                     record: ForeignRecord,
                                     labels: LabelSet=LabelSet(),
                                     id: OID?=nil) throws {
        self.init(origin: origin,
                  target: target,
                  labels: labels,
                  id: id)
    }

    /// Origin node of the edge - a node from which the edge points from.
    ///
    public let origin: Node
    /// Target node of the edge - a node to which the edge points to.
    ///
    public let target: Node
    
    public required init(origin: Node, target: Node, labels: LabelSet=[], id: OID? = nil) {
        self.origin = origin
        self.target = target
        super.init(id: id, labels: labels)
    }
    
    
    public override var description: String {
        return "Edge(id: \(idDebugString), \(origin.idDebugString) -> \(target.idDebugString), labels: \(labels.sorted()))"
    }
    
    /// Create a copy of the edge with optionally setting a new origin and/or
    /// target.
    ///
    /// The returned copy is not associated with any graph.
    ///
    /// Subclasses should implement this method.
    ///
    open func copy(origin: Node? = nil, target: Node? = nil) -> Self {
        let edge = Self(origin: origin ?? self.origin,
                        target: target ?? self.target,
                        labels: self.labels,
                        id: self.id)
        return edge
    }
}
extension Edge: Hashable {
    // FIXME: Is this 100% OK?
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        lhs.id == rhs.id
        && lhs.labels == rhs.labels
        && lhs.origin == rhs.origin
        && lhs.target == rhs.target
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

