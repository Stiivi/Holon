//
//  Holon.swift
//  
//
//  Created by Stefan Urbanek on 18/09/2022.
//

public class Holon: GraphProtocol {
    // FIXME: THIS IS BAD
    public var edges: [Edge] { [] }
    
    /// The graph where the holon resides.
    public let graph: Graph
    
    /// The node that represents the holon
    public let node: Node
    
    public init(graph: Graph, node: Node) {
        self.graph = graph
        self.node = node
    }
    
    /// Edge between the node and holon that owns the node.
    ///
    public var parentEdge: Edge? {
        return graph.outgoing(node).first { $0.isHolonEdge }
    }
    
    public var parent: Holon? {
        guard let edge = parentEdge else {
            return nil
        }
        return Holon(graph: graph, node: edge.target)
    }
    
    public var nodes: [Node] {
        graph.incoming(node)
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
    /// - Precondition: Node must not be in any other holon.
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
        precondition(node.holon === self, "Trying to remove a node of another holon")
        return graph.remove(node)
    }
    

}
