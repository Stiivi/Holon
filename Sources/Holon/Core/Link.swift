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
    
    public var isIndirect: Bool {
        return origin is Port || target is Port
    }
    
    public var finalOrigin: Node {
        if let port = origin as? Port {
            return port.finalNode
        }
        else {
            return origin
        }
    }
    
    public var finalTarget: Node {
        if let port = target as? Port {
            return port.finalNode
        }
        else {
            return target
        }
    }

    init(origin: Node, target: Node, labels: LabelSet=[], id: OID? = nil) {
        self.origin = origin
        self.target = target
        super.init(id: id, labels: labels)
    }

    
    /// Create an unassociated link object where the origin and target are final
    /// origin and final target of this link.
    ///
    /// Newly created link can not be associated with the same graph as the
    /// original link, because the IDs within a graph must be unique.
    ///
    /// Resolved link and the original link share the same identity because
    /// logically they represent the same link.
    ///
    /// - Note: Resolved link can not be used in the same graph
    ///
    public func resolved() -> Link {
        let link = Link(origin: finalOrigin,
                        target: finalTarget,
                        labels: labels,
                        id: id)
        return link
    }
    
    public override var description: String {
        let idString = id.map { String($0) } ?? "nil"
        let originIdString = origin.id.map { String($0) } ?? "nil"
        let targetIdString = target.id.map { String($0) } ?? "nil"

        return "Link(id: \(idString), \(originIdString) -> \(targetIdString), labels: \(labels.sorted()))"
    }
}
