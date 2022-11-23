//
//  Holon.swift
//
//
//  Created by Stefan Urbanek on 2021/10/5.
//

// NOTE: Repurposed from the TarotKit. Changes to design should be kept in sync.

// -------------------------------------------------------------------------
// IMPORTANT: This is the core structure of this framework. Be very considerate
//            when adding new functionality. If functionality can be achieved
//            by using existing functionality, then add it to an extension
//            (file Holon+Convenience or similar). Optimisation is not
//            a reason to add functionality here at this moment.
// -------------------------------------------------------------------------

/// Graph is a mutable structure representing a directed labelled multi-graph.
/// The graph is composed of nodes (vertices) and edges (connections between
/// vertices).
///
/// The main functionality of the graph structure is to mutate the graph:
/// ``Graph/add(_:)-3j4hi``, ``Graph/connect(from:to:labels:id:)``.
///
/// # Example
///
/// ```swift
/// let graph = Graph()
///
/// let parent = Node()
/// graph.add(parent)
///
/// let leftChild = Node()
/// graph.add(leftChild)
/// graph.connect(from: parent, to: leftChild, labels: ["left"])
///
/// let rightChild = Node()
/// graph.add(rightChild)
/// graph.connect(from: parent, to: leftChild, labels: ["right"])
/// ```
///
/// ## Lifetime and Ownership of Nodes and Edges
///
/// When a node is created, it belongs to the creator until the node
/// is added to the graph. When a node is added to the graph using
/// ``Graph/add(_:)-3j4hi`` then the graph becomes owner of the node until the
/// node is removed from the graph with ``Graph/remove(_:)``.
///
/// Edge, when created externally, is owned by the creator. When an edge is added
/// to the graph using ``Graph/add(_:)-af7w`` or a new edge is created by
/// ``Graph/connect(from:to:labels:id:)`` then graph becomes owner of the
/// edge until the edge is removed from the graph either with
/// ``Graph/disconnect(edge:)`` or as a by-product of ``Graph/remove(_:)``.
///
/// ## Observing Changes
///
/// Changes to the graph and its objects can be observed using
/// ``GraphObserver``.
///
public class Graph: MutableGraphProtocol {
    // Potential generic parameters:
    // class Graph<N,L> where N:Identifiable, L:Hashable, Identifiable
    // typealias Node: N
    // typealias Label: L
    // typealias OID: N.ID
    //
    // MARK: - Instance variables
    
    var _nodes: [OID:Node] = [:]
    var _edges: [OID:Edge] = [:]
    /// List of nodes in the graph.
    public var nodes: [Node] { Array(_nodes.values) }
    
    /// List of edges in the graph.
    public var edges: [Edge] { Array(_edges.values) }
    
    // MARK: - Initialisation
    
    /// Create an empty graph.
    ///
    /// - Parameters:
    ///
    ///     - nodes: List of nodes of the new graph.
    ///     - nodes: List of edges of the new graph.
    ///
    /// - Precondition: Endpoints of the edges must be in the list of provided nodes
    ///
    public init(nodes: [Node] = [], edges: [Edge] = []) {
        // TODO: Make sure all nodes and edges belong to the same world
        for node in nodes {
            assert(_nodes[node.id] == nil)
            _nodes[node.id] = node
        }

        guard edges.allSatisfy({ nodes.contains($0.origin) && nodes.contains($0.target) }) else {
            preconditionFailure("Edge endpoints must be in the provided list of nodes")
        }

        for edge in edges {
            assert(_edges[edge.id] == nil)
            _edges[edge.id] = edge
        }
    }
    
    // MARK: - Query
    
    /// Check whether the graph contains a node and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the node.
    ///
    /// - Note: Node comparison is based on its identity. Two nodes with the
    /// same attributes that are equatable are considered distinct nodes in the
    /// graph.
    ///
    ///
    public func contains(node: Node) -> Bool {
        return _nodes[node.id] != nil
    }
    
    /// Check whether the graph contains an edge and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the edge.
    ///
    /// - Note: Edge comparison is based on its identity.
    ///
    public func contains(edge: Edge) -> Bool {
        return _edges[edge.id] != nil
    }

    /// Get a node by ID.
    ///
    /// If id is `nil` then returns nil.
    ///
    public func node(_ id: Object.ID) -> Node? {
        return _nodes[id]
    }

    /// Get an edge by ID.
    ///
    /// If id is `nil` then returns nil.
    ///
    public func edge(_ id: Object.ID) -> Edge? {
        return _edges[id]
    }


    // MARK: - Mutation
    
    /// Adds a node to the graph. This method is used to add a newly created
    /// node or to re-associate a node that has been removed. Node ID must be
    /// valid.
    ///
    /// - Note: A node belongs to one graph only. It can not be shared once
    /// added to a graph.
    ///
    /// - Parameters:
    ///
    ///     - node: Node to be added to the graph.
    ///
    /// - Precondition: Graph must not have a node with the same ID.
    ///
    public func add(_ node: Node) {
        precondition(_nodes[node.id] == nil, "The graph already contains a node with id '\(node.id)'.")

        // Associate the node
        _nodes[node.id] = node
    }
    
    /// Removes node from the graph and removes all incoming and outgoing edges
    /// for that node.
    ///
    /// - Returns: List of edges that were disconnected and list of nodes that
    ///            were removed in addition to the node requested. (The
    ///            requested node is not included in the returned list)
    ///
    /// - Important: If using the Holon or Indirection pattern, removing a node
    ///   might break graph integrity. This is a low-level node removal. To
    ///   remove holon node see ``removeHolon(_:)`` or ``dissolveHolon(_:)``.
    ///
    @discardableResult
    public func remove(_ node: Node) -> [Edge] {
        var disconnected: [Edge] = []
        
        // First we remove all the connections
        for edge in edges {
            if edge.origin === node || edge.target === node {
                disconnected.append(edge)
                _edges[edge.id] = nil
            }
        }

        _nodes[node.id] = nil
        node.world = nil

        return disconnected
    }
    
    
    ///
    /// The edge name does not have to be unique and there might be multiple
    /// edges with the same name between two nodes.
    ///
    /// - Parameters:
    ///
    ///     - origin: The node from which the edge originates.
    ///     - target: The node to which the edge points.
    ///     - attributes: Attributes of the edge.
    ///     - id: Unique edge identifier. Edge with given identifier must not
    ///     exist. If not provided, new one is assigned.
    ///     - follow: flag whether ports are being followed
    ///
    /// ## Rules for connection:
    ///
    /// If the ports are note being followed:
    ///
    /// - A node can be connected to any node (including holons and ports)
    ///   within the same holon
    /// - A node (including holons and ports) can be connected to the holon
    ///   which owns the node
    ///
    /// If the ports are being followed, then in addition to the rules above,
    /// the following connections are allowed:
    ///
    /// - A node to a port of a child holon
    /// - A port of a child holon to a port of a child holon
    ///
    ///
    /// - Returns: Newly created edge
    ///
    /// - Precondition: Origin and target must be from the same graph and
    /// the connection must follow the rules mentioned above. It is up
    /// to the caller to take care of the connection rules to prevent fatal
    /// errors.
    ///
    @discardableResult
    public func connect(from origin: Node,
                        to target: Node,
                        labels: LabelSet=[],
                        id: OID?=nil) -> Edge {
        let edge = Edge(origin: origin, target: target, labels: labels, id: id)
        
        add(edge)
        
        return edge
    }
    

    /// Adds a custom-created edge to the graph.
    ///
    /// - Parameters:
    ///
    ///     - edge: Edge to be added to the graph.
    ///
    /// - Precondition: Graph must not have an edge with the same ID.
    ///
    public func add(_ edge: Edge) {
        precondition(_edges[edge.id] == nil, "The graph already contains an edge with id '\(edge.id)'.")

        _edges[edge.id] = edge
    }

    /// Removes a specific edge from the graph. Edge must exist in the graph.
    ///
    /// - Parameters:
    ///
    ///     - edge: Edge to be removed.
    ///
    public func remove(_ edge: Edge) {
        _edges[edge.id] = nil
    }
    
    public var description: String {
        "Graph(nodes: \(nodes.count), edges: \(edges.count))"
    }
    
    /// Create a copy of the graph
    ///
    public func copy() -> Graph {
        // FIXME: Remove this
        let graph = Graph()
        for node in nodes {
            graph.add(node)
        }
        // We can use IDs because they are guaranteed to be unique within a
        // graph
        for edge in edges {
            graph.add(edge)
        }
        return graph
    }
    
}

extension Graph: Equatable {
    public static func ==(lhs: Graph, rhs: Graph) -> Bool {
        return lhs._nodes == rhs._nodes
                    && lhs._edges == rhs._edges
    }
}
