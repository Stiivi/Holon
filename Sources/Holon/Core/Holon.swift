//
//  Holon.swift
//  
//
//  Created by Stefan Urbanek on 26/08/2022.
//


/// Protocol for a Holon - a hierarchical structure.
///
public protocol HolonProtocol: GraphProtocol {
    /// List of child holons that belong to the receiver.
    ///
    var childHolons: [Node] { get }

    /// List of all holons that belong to the receiver, including holons
    /// of the children.
    ///
    var allHolons: [Node] { get }

    /// List of direct ports of the holon.
    ///
    var ports: [Node] { get }

    /// List of all ports of the holon.
    ///
    var allPorts: [Node] { get }
}

public extension HolonProtocol {
    /// List of all holons, including nested one, that are contained in the
    /// graph.
    ///
    var allHolons: [Node] {
        nodes.filter { $0.isHolon }
    }

    /// List of all ports, including nested one, that are contained in the
    /// graph.
    ///
    var allPorts: [Node] {
        nodes.filter { $0.isProxy }
    }
}

extension Node {
    /// Flag whether the node is a holon.
    var isHolon: Bool { contains(label: Node.HolonLabel) }
    
    /// Link between the node and holon that owns the node.
    ///
    public var holonLink: Link? {
        if graph == nil {
            return nil
        }
        else {
            return outgoing.first { $0.isHolonLink }
        }
    }
    
    /// Holon the node is associated with.
    ///
    public var holon: Node? {
        if graph == nil {
            return nil
        }
        else {
            return holonLink?.target
        }
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
extension Node: HolonProtocol, MutableGraphProtocol {
    public static let HolonLabel = "%holon"

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
    
    /// List of holons that are direct children of this holon.
    ///
    public var childHolons: [Node] {
        // TODO: Rename to child holons
        incoming.filter { $0.isHolonLink }
            .map { $0.origin }
    }
    
    public var ports: [Node] {
        childHolons.filter { $0.isProxy }
    }

    /// Add an unassociated node to the holon.
    ///
    /// Node is associated with the the graph and then connected with the holon.
    ///
    /// - Precondition: Node must not be associated with a graph.
    ///
    /// - Note: Reason why this method does not allow adding nodes already
    ///   associated with a graph is, that they might be connected to other
    ///   nodes and we can not guarantee that making them part of the holon
    ///   would not violate any restrictions that might be imposed on the nodes.
    ///   Therefore it is safe, and as a side-effect faster, to allow only
    ///   unassociated nodes to be added to the holon.
    ///
    public func add(_ node: Node) {
        precondition(graph != nil, "Trying to add a node to an unassociated holon")
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
        graph!.connect(node: node, holon: self)
    }
    
    /// Remove a node from the holon and from the owning graph.
    ///
    /// See ``Graph/remove(_:)`` for more information.
    ///
    /// - Precondition: Node must belong to the holon.
    ///
    public func remove(_ node: Node) -> [Link] {
        precondition(graph != nil, "Trying to remove a node from an unassociated holon")
        precondition(node.holon === self, "Trying to remove a node of another holon")
        return graph!.remove(node)
    }
    
    /// Connects two nodes within the holon. Both nodes must belong to the same
    /// holon.
    ///
    /// This is a safe way of connecting two nodes within a holon.
    ///
    /// - Precondition: Both origin and target holon must be the same as the
    ///   receiver holon.
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
