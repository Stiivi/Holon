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
public final class Edge: Object {
    // FIXME: Add PersistableEdge
    
    /// Origin node of the edge - a node from which the edge points from.
    ///
    public let origin: ObjectID
    /// Target node of the edge - a node to which the edge points to.
    ///
    public let target: ObjectID
    
    public required init(origin: ObjectID,
                         target: ObjectID,
                         labels: LabelSet=[],
                         id: OID? = nil,
                         components: any Component...) {
        self.origin = origin
        self.target = target
        super.init(id: id, labels: labels, components: components)
    }
    
    
    public override var description: String {
        return "Edge(id: \(idDebugString), \(origin) -> \(target), labels: \(labels.sorted()))"
    }
}
