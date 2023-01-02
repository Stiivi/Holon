//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 23/08/2022.
//

public protocol GraphProtocol {
    /// List of indices of all nodes
    var nodeIDs: [NodeID] { get }

    /// List of indices of all edges
    var edgeIDs: [EdgeID] { get }
    
    /// All nodes of the graph
    var nodes: [Node] { get }
    
    /// All edges of the graph
    var edges: [Edge] { get }

    /// Get a node by ID.
    ///
    func node(_ index: NodeID) -> Node?

    /// Get an edge by ID.
    ///
    func edge(_ index: EdgeID) -> Edge?

    /// Check whether the graph contains a node and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the node.
    ///
    /// - Note: Node comparison is based on its identity. Two nodes with the
    /// same attributes that are equatable are considered distinct nodes in the
    /// graph.
    ///
    ///
    func contains(node: NodeID) -> Bool
    
    /// Check whether the graph contains an edge and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the edge.
    ///
    /// - Note: Edge comparison is based on its identity.
    ///
    func contains(edge: EdgeID) -> Bool

    /// Get a list of outgoing edges from a node.
    ///
    /// - Parameters:
    ///     - origin: Node from which the edges originate - node is origin
    ///     node of the edge.
    ///
    /// - Returns: List of edges.
    ///
    /// - Complexity: O(n). All edges are traversed.
    ///
    /// - Note: If you want to get both outgoing and incoming edges of a node
    ///   then use ``neighbours(_:)-d13k``. Using ``outgoing(_:)`` + ``incoming(_:)-3rfqk`` might
    ///   result in duplicates for edges that are loops to and from the same
    ///   node.
    ///
    func outgoing(_ origin: NodeID) -> [Edge]
    
    /// Get a list of edges incoming to a node.
    ///
    /// - Parameters:
    ///     - target: Node to which the edges are incoming – node is a target
    ///       node of the edge.
    ///
    /// - Returns: List of edges.
    ///
    /// - Complexity: O(n). All edges are traversed.
    ///
    /// - Note: If you want to get both outgoing and incoming edges of a node
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for edges that are loops to and from the same
    ///   node.
    ///

    func incoming(_ target: NodeID) -> [Edge]
    /// Get a list of edges that are related to the neighbours of the node. That
    /// is, list of edges where the node is either an origin or a target.
    ///
    /// - Returns: List of edges.
    ///
    /// - Complexity: O(n). All edges are traversed.
    ///

    func neighbours(_ node: NodeID) -> [Edge]
    
    /// Returns edges that are related to the node and that match the given
    /// edge selector.
    ///
    func neighbours(_ node: NodeID, selector: EdgeSelector) -> [Edge]

}

extension GraphProtocol {
    public var nodeIDs: [NodeID] {
        nodes.map { $0.id }
    }

    public var edgeIDs: [EdgeID] {
        edges.map { $0.id }
    }

    public func contains(node: NodeID) -> Bool {
        return nodeIDs.contains { $0 == node }
    }

    public func contains(edge: EdgeID) -> Bool {
        return edgeIDs.contains { $0 == edge }
    }
    
    /// Get a node by ID.
    ///
    /// If id is `nil` then returns nil.
    ///
    public func node(_ oid: NodeID) -> Node? {
        return nodes.first { $0.id == oid }
    }

    /// Get an edge by ID.
    ///
    /// If id is `nil` then returns nil.
    ///
    public func edge(_ oid: EdgeID) -> Edge? {
        return edges.first { $0.id == oid }
    }

    public func outgoing(_ origin: NodeID) -> [Edge] {
        let result: [Edge]
        
        result = self.edges.filter {
            $0.origin == origin
        }

        return result
    }
    
    public func incoming(_ target: NodeID) -> [Edge] {
        let result: [Edge]
        
        result = self.edges.filter {
            $0.target == target
        }

        return result
    }
    
    public func neighbours(_ node: NodeID) -> [Edge] {
        let result: [Edge]
        
        result = self.edges.filter {
            $0.target == node || $0.origin == node
        }

        return result
    }
    
    public func neighbours(_ node: NodeID, selector: EdgeSelector) -> [Edge] {
        let edges: [Edge]
        switch selector.direction {
        case .incoming: edges = self.incoming(node)
        case .outgoing: edges = self.outgoing(node)
        }
        
        return edges.filter { $0.contains(labels: selector.labels) }
    }

}

public protocol MutableGraphProtocol: GraphProtocol {
    /// Remove all nodes and edges from the graph.
    func removeAll()
    
    /// Add a node to the graph.
    ///
    func add(_ node: Node)

    /// Add an edge to the graph.
    ///
    func add(_ edge: Edge)

    /// Remove a node from the graph and return a list of edges that were
    /// removed together with the node.
    ///
    func remove(node: NodeID) -> [Edge]
    
    /// Remove an edge from the graph.
    ///
    func remove(edge: EdgeID)
}

extension MutableGraphProtocol {
    public func removeAll() {
        for edge in edgeIDs {
            remove(edge: edge)
        }
        for node in nodeIDs {
            remove(node: node)
        }
    }

}
