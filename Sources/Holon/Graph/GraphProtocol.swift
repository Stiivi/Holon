//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 23/08/2022.
//

public protocol GraphProtocol {
    var nodes: [Node] { get }
    var edges: [Edge] { get }
    /// Check whether the graph contains a node and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the node.
    ///
    /// - Note: Node comparison is based on its identity. Two nodes with the
    /// same attributes that are equatable are considered distinct nodes in the
    /// graph.
    ///
    ///
    func contains(_ node: Node) -> Bool
    
    /// Check whether the graph contains an edge and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the edge.
    ///
    /// - Note: Edge comparison is based on its identity.
    ///
    func contains(_ edge: Edge) -> Bool

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
    func outgoing(_ origin: Node) -> [Edge]
    
    /// Get a node by ID.
    ///
    func node(_ id: Object.ID) -> Node?

    /// Get an edge by ID.
    ///
    func edge(_ id: Object.ID) -> Edge?

    
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

    func incoming(_ target: Node) -> [Edge]
    /// Get a list of edges that are related to the neighbours of the node. That
    /// is, list of edges where the node is either an origin or a target.
    ///
    /// - Returns: List of edges.
    ///
    /// - Complexity: O(n). All edges are traversed.
    ///

    func neighbours(_ node: Node) -> [Edge]
    
    /// Returns edges that are related to the node and that match the given
    /// edge selector.
    ///
    func neighbours(_ node: Node, selector: EdgeSelector) -> [Edge]

}

extension GraphProtocol {
    public func contains(_ node: Node) -> Bool {
        return nodes.contains { $0 === node }
    }

    public func contains(_ edge: Edge) -> Bool {
        return edges.contains { $0 === edge }
    }
    
    /// Get a node by ID.
    ///
    /// If id is `nil` then returns nil.
    ///
    public func node(_ id: Object.ID) -> Node? {
        return nodes.first { $0.id == id }
    }

    /// Get an edge by ID.
    ///
    /// If id is `nil` then returns nil.
    ///
    public func edge(_ id: Object.ID) -> Edge? {
        return edges.first { $0.id == id }
    }

    public func outgoing(_ origin: Node) -> [Edge] {
        let result: [Edge]
        
        result = self.edges.filter {
            $0.origin === origin
        }

        return result
    }
    public func incoming(_ target: Node) -> [Edge] {
        let result: [Edge]
        
        result = self.edges.filter {
            $0.target === target
        }

        return result
    }
    public func neighbours(_ node: Node) -> [Edge] {
        let result: [Edge]
        
        result = self.edges.filter {
            $0.target === node || $0.origin === node
        }

        return result
    }
    public func neighbours(_ node: Node, selector: EdgeSelector) -> [Edge] {
        // TODO: Find a better name
        let edges: [Edge]
        switch selector.direction {
        case .incoming: edges = self.incoming(node)
        case .outgoing: edges = self.outgoing(node)
        }
        
        return edges.filter { $0.contains(label: selector.label) }
    }

}

public protocol MutableGraphProtocol: GraphProtocol {
    func removeAll()
    func add(_ node: Node)
    func add(_ edge: Edge)
    func remove(_ node: Node) -> [Edge]
    func remove(_ edge: Edge)
    func connect(from origin: Node, to target: Node, labels: LabelSet, id: OID?) -> Edge
}

extension MutableGraphProtocol {
    public func connect(from origin: Node, to target: Node, labels: LabelSet, id: OID?) -> Edge {
        let edge = Edge(origin: origin, target: target, labels: labels, id: id)
        add(edge)
        return edge
    }
    
    public func removeAll() {
        for edge in edges {
            remove(edge)
        }
        for node in nodes {
            remove(node)
        }
    }

}
