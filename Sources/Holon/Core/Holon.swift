//
//  Holon.swift
//  
//
//  Created by Stefan Urbanek on 26/08/2022.
//


public protocol HolonProtocol: GraphProtocol {
    var holons: [Holon] { get }
    var allHolons: [Holon] { get }
    var ports: [Node] { get }
    var allPorts: [Node] { get }
}

public extension HolonProtocol {
    /// List of all holons, including nested one, that are contained in the
    /// graph.
    ///
    var allHolons: [Holon] {
        nodes.compactMap { $0 as? Holon }
    }

    /// List of all ports, including nested one, that are contained in the
    /// graph.
    ///
    var allPorts: [Node] {
        nodes.filter { $0.isProxy }
    }
}

/// A special node representing a hierarchical entity within the graph.
///
/// The concept of holon is described as follows:
///
/// - holon is a sub-graph defined by nodes that belong to the holon
/// - holons owns all children nodes
/// - holons are organised in a tree structure: a holon has child holons
///   and might have a parent
/// - holons do not share nodes
/// - holon is a regular node in a graph and connections to/from a holon
///   can be formed
/// - when a holon is removed from a graph, all its children nodes are
///   removed as well, including child holons and their nodes
///
public class Holon: Node, HolonProtocol, MutableGraphProtocol {
    public static let HolonLabel = "__holon"

    override public init(id: OID?=nil, labels: LabelSet=LabelSet()) {
        super.init(id: id, labels: labels.union([Holon.HolonLabel]))
    }

    /// List of nodes that belong to the holon directly. The list excludes all
    /// nodes that belong to the children holons.
    ///
    public var nodes: [Node] { graph!.nodes.filter { $0.holon === self } }

    /// Get all links that belong to the holon.
    ///
    /// Links that belong to the holon are those links that are between the
    /// direct children nodes of the holon. Links that are between nodes
    /// of the holon and a child or a parent holon are not included.
    ///
    public var links: [Link] {
        graph!.links.filter {
            $0.graph === self.graph
            && $0.origin.holon === self
            && $0.target.holon === self
        }
    }
    
    /// List of top-level holons – those holons that have no parent.
    ///
    public var holons: [Holon] {
        nodes.compactMap {
            if $0.holon == self {
                return $0 as? Holon
            }
            else {
                return nil
            }
        }
    }
    
    public var ports: [Node] {
        nodes.filter { $0.holon === self }
    }

    /// Add a node to the holon.
    ///
    /// A node is added to the graph and marked as belonging to this holon.
    ///
    /// - Precondition: If node is a port, then its represented node must belong
    /// to the same holon.
    ///
    public func add(_ node: Node) {
        // FIXME: Re-add the preconditions
        //        if let port = node as? Proxy {
////            precondition(port.representedNode.graph === self.graph,
////                         "Trying to add a port with represented node from another graph")
//            // FIXME: Remove this, add this as additional checking
//            precondition(port.subject?.holon === self
//                         || (port.subject is Proxy && port.subject?.holon!.holon === self),
//                         "Proxy's represented node must belong to the same holon or be a port of a a child holon")
//        }
//
        graph!.add(node)
        node.holon = self
    }
    
    /// Remove a node from the holon and from the owning graph.
    ///
    /// See ``Graph/remove(_:)`` for more information.
    ///
    /// - Precondition: Node must belong to the holon.
    ///
    public func remove(_ node: Node) -> [Link] {
        precondition(node.holon === self, "Trying to remove a node of another holon")
        return graph!.remove(node)
    }
    
    public func removeFromParent() {
        // return removed links and nodes
    }
    
    /// Connects two nodes within the holon. Both nodes must belong to the same
    /// holon.
    ///
    public func connect(from origin: Node, to target: Node, labels: LabelSet, id: OID?) -> Link {
        precondition(origin.holon === self, "Trying to connect a node (as origin) that belongs to another holon")
        precondition(target.holon === self, "Trying to connect a node (as target) that belongs to another holon")
        return graph!.connect(from: origin, to: target, labels: labels, id: id)
    }
    
    /// Disconnects a link.
    ///
    /// See: ``Graph/disconnect(link:)``
    ///
    /// - Precondition: At least one of origin or a target must belong to the holon.
    ///
    public func disconnect(link: Link) {
        precondition(link.origin.holon === self || link.target.holon === self,
                     "Trying to disconnect a link that does not belong to the holon, neither crosses its boundary")
        graph!.disconnect(link: link)
    }
}
