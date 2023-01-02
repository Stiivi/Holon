//
//  Holon.swift
//  
//
//  Created by Stefan Urbanek on 18/09/2022.
//

// FIXME: THIS IS TOTALLY BROKEN

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
public class Holon: GraphProtocol {
    public static let ParentHolonSelector = EdgeSelector(HolonLabel.HolonEdge,
                                                         direction: .outgoing)

    // FIXME: THIS IS BAD
    /// The graph where the holon resides.
    public let graph: Graph
    
    /// The node that represents the holon
    public let nodeID: NodeID
    
    /// Create a holon graph wrapper.
    ///
    public init(graph: Graph, nodeID: NodeID) {
        self.graph = graph
        self.nodeID = nodeID
    }
    
    /// Edge between the node and holon that owns the node.
    ///
    public var parentEdge: Edge? {
        return graph.outgoing(nodeID).first { $0.isHolonEdge }
    }
    
    public var parent: Holon? {
        guard let edge = parentEdge else {
            return nil
        }
        return Holon(graph: graph, nodeID: edge.target)
    }
    
    public var nodes: [Node] {
        graph.incoming(nodeID)
            .filter { $0.isHolonEdge }
            .map { graph.node($0.origin)! }
    }
    
    /// Get all edges that belong to the holon.
    ///
    /// Edges that belong to the holon are those edges that are between the
    /// direct children nodes of the holon. Edges that are between nodes
    /// of the holon and a child or a parent holon are not included.
    ///
    public var edges: [Edge] {
        // FIXME: Not implemented
        return []
//        world!.edges.filter {
//            $0.world === self.world
//            && $0.origin.holon == self.id
//            && $0.target.holon == self.id
//        }
    }

    /// List of holons that are direct children of this holon.
    ///
    public var childHolons: [NodeID] {
        // FIXME: This is wrong, remove (or is it?)
        graph.incoming(nodeID)
            .filter { $0.isHolonEdge }
            .map { $0.origin }
    }
    
    public var ports: [Node] {
        nodes.filter { $0.isProxy }
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
        precondition(node.holon == nil)
        if graph.contains(node: node) {
            graph.add(node)
        }
        graph.connect(node: node, holon: node)
    }
    
    /// Remove a node from the holon and from the owning graph.
    ///
    /// See ``Graph/remove(_:)`` for more information.
    ///
    /// - Precondition: Node must belong to the holon.
    ///
    public func remove(_ node: Node) -> [Edge] {
        precondition(node.holon == self.nodeID,
                     "Trying to remove a node of another holon")

        return graph.remove(node: node.id)
    }
    

}
