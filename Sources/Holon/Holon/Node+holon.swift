//
//  Holon.swift
//  
//
//  Created by Stefan Urbanek on 26/08/2022.
//


extension Node {
    /// Flag whether the node is a holon.
    public var isHolon: Bool { contains(label: HolonLabel.Holon) }
    
    /// Edge between the node and holon that owns the node.
    ///
    public var holonEdge: Edge? {
        if graph == nil {
            return nil
        }
        else {
            return outgoing.first { $0.isHolonEdge }
        }
    }
    
    /// Holon the node is associated with.
    ///
    public var holon: Node? {
        if graph == nil {
            return nil
        }
        else {
            return holonEdge?.target
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
    public static let ParentHolonSelector = EdgeSelector(HolonLabel.HolonEdge,
                                                         direction: .outgoing)

    /// List of nodes that belong to the holon directly. The list excludes all
    /// nodes that belong to the children holons.
    ///
    public var nodes: [Node] { graph!.nodes.filter { $0.holon === self } }

    /// Get all edges that belong to the holon.
    ///
    /// Edges that belong to the holon are those edges that are between the
    /// direct children nodes of the holon. Edges that are between nodes
    /// of the holon and a child or a parent holon are not included.
    ///
    public var edges: [Edge] {
        graph!.edges.filter {
            $0.graph === self.graph
            && $0.origin.holon === self
            && $0.target.holon === self
        }
    }
    
    /// List of holons that are direct children of this holon.
    ///
    public var childHolons: [Node] {
        // FIXME: This is wrong, remove
        // TODO: Rename to child holons
        incoming.filter { $0.isHolonEdge }
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
    public func remove(_ node: Node) -> [Edge] {
        precondition(graph != nil, "Trying to remove a node from an unassociated holon")
        precondition(node.holon === self, "Trying to remove a node of another holon")
        return graph!.remove(node)
    }
    
    /// Adds an edge to the holon. Both endpoints of the edge must belong to the
    /// same holon.
    ///
    /// This is a safe way of connecting two nodes within a holon.
    ///
    /// - Precondition: Both origin and target holon must be the same as the
    ///   receiver holon.
    ///
    public func add(_ edge: Edge) {
        precondition(edge.origin.holon === self, "Trying to connect a node (as origin) that belongs to another holon")
        precondition(edge.target.holon === self, "Trying to connect a node (as target) that belongs to another holon")
        return graph!.add(edge)
    }
    
    /// Disconnects an edge.
    ///
    /// See: ``Graph/disconnect(edge:)``
    ///
    /// - Precondition: At least one of origin or a target must belong to the holon.
    ///
    public func remove(_ edge: Edge) {
        precondition(edge.origin.holon === self || edge.target.holon === self,
                     "Trying to disconnect an edge that does not belong to the holon, neither crosses its boundary")
        graph!.remove(edge)
    }
}
