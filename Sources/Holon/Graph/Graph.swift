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

/// Holon is a mutable structure representing a directed labelled multi-graph.
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
    
    /// Object observing graph changes.
    ///
    public var observer: GraphObserver?

    // MARK: - Initialisation
    
    /// Create an empty graph.
    ///
    /// - Parameters:
    ///
    ///     - nodes: List of nodes of the new graph. The nodes must not be
    ///       associated with any other graph
    ///     - nodes: List of edges of the new graph. The edges must not be
    ///       associated with any other graph and must be valid.
    ///
    /// - Precondition: Provided nodes and edges must not belong to any graph.
    /// - Precondition: Endpoints of the edges must be in the list of provided nodes
    ///
    public init(nodes: [Node] = [], edges: [Edge] = []) {
        guard nodes.allSatisfy({ $0.graph == nil }) else {
            preconditionFailure("Nodes must not be associated with any graph")
        }
        for node in nodes {
            assert(_nodes[node.id] == nil)
            _nodes[node.id] = node
        }

        guard edges.allSatisfy({ $0.graph == nil }) else {
            preconditionFailure("Edges must not be associated with any graph")
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
        return node.graph === self && _nodes[node.id] != nil
    }
    
    /// Check whether the graph contains an edge and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the edge.
    ///
    /// - Note: Edge comparison is based on its identity.
    ///
    public func contains(edge: Edge) -> Bool {
        return edge.graph === self && _edges[edge.id] != nil
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
    /// For internal use only.
    ///
    /// - Note: A node belongs to one graph only. It can not be shared once
    /// added to a graph.
    ///
    /// - Parameters:
    ///
    ///     - node: Node to be added to the graph.
    ///
    /// - Precondition: Node must not belong to any graph.
    /// - Precondition: Graph must not have a node with the same ID.
    ///
    public func add(_ node: Node) {
        precondition(node.graph == nil, "Trying to associate already associated node: \(node)")
        precondition(_nodes[node.id] == nil, "The graph already contains a node with id '\(node.id)'.")

        node.graph = self

        let change = GraphChange.addNode(node)
        willChange(change)
        
        // Associate the node
        _nodes[node.id] = node
        
        didChange(change)
    }
    
    /// Removes node from the graph and removes all incoming and outgoing edges
    /// for that node.
    ///
    /// - Returns: List of edges that were disconnected and list of nodes that
    ///            were removed in addition to the node requested. (The
    ///            requested node is not included in the returned list)
    ///
    /// - Note: The caller becomes owner of the returned nodes and edges.
    ///
    /// - Precondition: Node must belong to the graph.
    ///
    /// - Important: If using the Holon or Indirection pattern, removing a node
    ///   might break graph integrity. This is a low-level node removal. To
    ///   remove holon node see ``removeHolon(_:)`` or ``dissolveHolon(_:)``.
    ///
    @discardableResult
    public func remove(_ node: Node) -> [Edge] {
        precondition(node.graph === self, "Trying to remove a node that does not belong to the graph")

        var disconnected: [Edge] = []
        
        let change = GraphChange.removeNode(node)
        willChange(change)

        // First we remove all the connections
        for edge in edges {
            if edge.origin === node || edge.target === node {
                disconnected.append(edge)
                rawDisconnect(edge)
            }
        }

        _nodes[node.id] = nil
        node.graph = nil

        didChange(change)
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
        precondition(origin.graph === self, "Connecting from an origin from a different graph")
        precondition(target.graph === self, "Connecting to a target from a different graph")
        
        let edge = Edge(origin: origin, target: target, labels: labels, id: id)
        
        let change = GraphChange.addEdge(edge)
        willChange(change)

        edge.graph = self
        _edges[edge.id] = edge
        didChange(change)
        
        return edge
    }
    

    /// Adds a custom-created edge to the graph.
    ///
    /// This method can be also used to associate previously associated edge
    /// with the graph. Typical use-case would be an undo command.
    /// 
    /// - Note: An edge object belongs to one graph only. It can not be shared
    /// once added to a graph.
    ///
    /// - Parameters:
    ///
    ///     - edge: Edge to be added to the graph.
    ///
    /// - Precondition: Edge must not be associated with any graph.
    /// - Precondition: Graph must not have an edge with the same ID.
    ///
    public func add(_ edge: Edge) {
        precondition(edge.graph == nil,
                     "Trying to associate already associated edge: \(edge)")
        precondition(_edges[edge.id] == nil, "The graph already contains an edge with id '\(edge.id)'.")
        precondition(contains(node: edge.origin), "Origin of an edge does not belong to the graph")
        precondition(contains(node: edge.target), "Target of an edge does not belong to the graph")

        let change = GraphChange.addEdge(edge)
        willChange(change)
        
        // Register the object
        edge.graph = self
        _edges[edge.id] = edge
        
        didChange(change)
    }

    /// Removes a specific edge from the graph. This method is shared for
    /// consistency between remove(node:) and disconnect(edge:).
    ///
    /// - Parameters:
    ///
    ///     - edge: Edge to be removed.
    ///
    func rawDisconnect(_ edge: Edge) {
        // NOTE: Here we know that the edge's graph is us, we do not have to
        //       check it. Since IDs are unique, we can just use the ID to remove
        //       the node.
        //
        _edges[edge.id] = nil
        edge.graph = nil
    }
    
    
    /// Removes a specific edge from the graph. Edge must exist in the graph.
    ///
    /// - Parameters:
    ///
    ///     - edge: Edge to be removed.
    ///
    public func remove(_ edge: Edge) {
        precondition(edge.graph === self,
                     "Trying to disconnect an unassociated edge or an edge from a different graph")

        let change = GraphChange.removeEdge(edge)
        willChange(change)
        rawDisconnect(edge)
        didChange(change)
    }
   
    public func removeAll() {
        for edge in edges {
            edge.graph = nil
        }
        _edges.removeAll()
        for node in nodes {
            node.graph = nil
        }
        _nodes.removeAll()
    }
    
    // MARK: - Advanced Query
    
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
    ///   then use ``neighbours(_:)``. Using ``outgoing(_:)`` + ``incoming(_:)`` might
    ///   result in duplicates for edges that are loops to and from the same
    ///   node.
    ///
    public func outgoing(_ origin: Node) -> [Edge] {
        precondition(origin.graph === self,
                     "Trying to get outgoing edges from a node that is not associated with the graph.")

        let result: [Edge]
        
        result = self.edges.filter {
            $0.origin === origin
        }

        return result
    }
    
    
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
    ///   then use ``neighbours(_:)``. Using ``outgoing(_:)`` + ``incoming(_:)`` might
    ///   result in duplicates for edges that are loops to and from the same
    ///   node.
    ///
    public func incoming(_ target: Node) -> [Edge] {
        precondition(target.graph === self,
                     "Trying to get incoming edges from a node that is not associated with the graph.")

        let result: [Edge]
        
        result = self.edges.filter {
            $0.target === target
        }

        return result
    }
    
    
    /// Get a list of edges that are related to the neighbours of the node. That
    /// is, list of edges where the node is either an origin or a target.
    ///
    /// - Returns: List of edges.
    ///
    /// - Complexity: O(n). All edges are traversed.
    ///
    public func neighbours(_ node: Node) -> [Edge] {
        precondition(node.graph === self,
                     "Trying to get neighbour edges from a node that is not associated with the graph.")

        let result: [Edge]
        
        result = self.edges.filter {
            $0.target === node || $0.origin === node
        }

        return result
    }

    
    /// Determines whether the node has no outgoing edges. That is, if there
    /// are no edges which have the node as origin.
    ///
    /// - Returns: `true` if there are no outgoing edges from the node.
    /// - Complexity: O(n). All edges are traversed.
    ///
    public func isSink(_ node: Node) -> Bool {
        precondition(node.graph === self, "Node is not associated with this graph.")
        return edges.contains { $0.origin === node }
    }
    
    /// Determines whether the node has no incoming edges. That is, if there
    /// are no edges which have the node as target.
    ///
    /// - Returns: `true` if there are no incoming edges to the node.
    /// - Complexity: O(n). All edges are traversed.
    ///
    public func isSource(_ node: Node) -> Bool {
        precondition(node.graph === self, "Node is not associated with this graph.")
        return edges.contains { $0.target === node }
    }
    
    /// Determines whether the `node` is an orphan, that is whether the node has
    /// no incoming neither outgoing edges.
    ///
    /// - Returns: `true` if there are no edges referring to the node.
    /// - Complexity: O(n). All edges are traversed.
    ///
    public func isOrphan(_ node: Node) -> Bool {
        precondition(node.graph === self, "Node is not associated with this graph.")
        return edges.contains { $0.origin === node || $0.target === node }
    }


    /// Called when graph is about to be changed.
    func willChange(_ change: GraphChange) {
        observer?.graphWillChange(graph: self, change: change)
    }
    
    /// Called when graph has changed.
    func didChange(_ change: GraphChange) {
//        observer?.graphDidChange(graph: self, change: change)
    }


    public var description: String {
        "Graph(nodes: \(nodes.count), edges: \(edges.count))"
    }
    
    /// Create a copy of the graph
    public func copy() -> Graph {
        let graph = Graph()
        for node in nodes {
            graph.add(node.copy())
        }
        // We can use IDs because they are guaranteed to be unique within a
        // graph
        for edge in edges {
            let copy = edge.copy(origin: graph.node(edge.origin.id)!,
                                 target: graph.node(edge.target.id)!)
            graph.add(copy)
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
