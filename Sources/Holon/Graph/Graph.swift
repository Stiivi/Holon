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
/// The graph is composed of nodes (vertices) and links (edges between
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
/// ## Lifetime and Ownership of Nodes and Links
///
/// When a node is created, it belongs to the creator until the node
/// is added to the graph. When a node is added to the graph using
/// ``Graph/add(_:)-3j4hi`` then the graph becomes owner of the node until the
/// node is removed from the graph with ``Graph/remove(_:)``.
///
/// Link, when created externally, is owned by the creator. When a link is added
/// to the graph using ``Graph/add(_:)-af7w`` or a new link is created by
/// ``Graph/connect(from:to:labels:id:)`` then graph becomes owner of the
/// link until the link is removed from the graph either with
/// ``Graph/disconnect(link:)`` or as a by-product of ``Graph/remove(_:)``.
///
public class Graph: MutableGraphProtocol {
    // Potential generic parameters:
    // class Graph<N,L> where N:Identifiable, L:Hashable, Identifiable
    // typealias Node: N
    // typealias Label: L
    // typealias OID: N.ID
    //
    // MARK: - Instance variables
    
    /// List of nodes in the graph.
    public private(set) var nodes: [Node]
    
    /// List of links in the graph.
    public private(set) var links: [Link]
    
    /// Publisher of graph changes before they are applied. The associated
    /// graph object and the graph are in their original state.
    ///
//    public var graphWillChange = PassthroughSubject<GraphChange, Never>()
    
    /// Publisher of graph changes after they are applied. The associated graph
    /// object and the graph are in their changed state.
    ///
//    public var graphDidChange = PassthroughSubject<GraphChange, Never>()

    // MARK: - Initialisation
    
    /// Create an empty graph.
    ///
    /// - Parameters:
    ///
    ///     - nodes: List of nodes of the new graph. The nodes must not be
    ///       associated with any other graph
    ///     - nodes: List of links of the new graph. The links must not be
    ///       associated with any other graph and must be valid.
    ///
    /// - Precondition: Provided nodes and links must not belong to any graph.
    /// - Precondition: Endpoints of the links must be in the list of provided nodes
    ///
    public init(nodes: [Node] = [], links: [Link] = []) {
        guard nodes.allSatisfy({ $0.graph == nil }) else {
            preconditionFailure("Nodes must not be associated with any graph")
        }
        self.nodes = nodes

        guard links.allSatisfy({ $0.graph == nil }) else {
            preconditionFailure("Links must not be associated with any graph")
        }

        guard links.allSatisfy({ nodes.contains($0.origin) && nodes.contains($0.target) }) else {
            preconditionFailure("Links endpoints must be in the provided list of nodes")
        }

        self.links = links
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
        return nodes.contains { $0 === node }
    }

    /// Check whether the graph contains a link and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the link.
    ///
    /// - Note: Link comparison is based on its identity.
    ///
    public func contains(link: Link) -> Bool {
        return links.contains { $0 === link }
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
    ///
    public func add(_ node: Node) {
        precondition(node.graph == nil, "Trying to associate already associated node: \(node)")
        
        node.graph = self

        let change = GraphChange.addNode(node)
        willChange(change)
        
        // Associate the node
        nodes.append(node)
        
        didChange(change)
    }
    
    /// Removes node from the graph and removes all incoming and outgoing links
    /// for that node.
    ///
    /// - Returns: List of links that were disconnected and list of nodes that
    ///            were removed in addition to the node requested. (The
    ///            requested node is not included in the returned list)
    ///
    /// - Note: The caller becomes owner of the returned nodes and links.
    ///
    /// - Precondition: Node must belong to the graph.
    ///
    /// - Important: If using the Holon or Indirection pattern, removing a node
    ///   might break graph integrity. This is a low-level node removal. To
    ///   remove holon node see ``removeHolon(_:)`` or ``dissolveHolon(_:)``.
    ///
    @discardableResult
    public func remove(_ node: Node) -> [Link] {
        precondition(node.graph === self, "Trying to remove a node that does not belong to the graph")
        // FIXME: This is getting complicated
        // FIXME: IMPORTANT: When removing a port represented object, graph becomes inconsistent because the pseudo-link remains

        var disconnected: [Link] = []
        
        let change = GraphChange.removeNode(node)
        willChange(change)

        // First we remove all the connections
        for link in links {
            if link.origin === node || link.target === node {
                disconnected.append(link)
                rawDisconnect(link)
            }
        }

        nodes.removeAll { $0 === node}
        node.graph = nil

        didChange(change)
        return disconnected
    }
    
    
    ///
    /// The link name does not have to be unique and there might be multiple
    /// links with the same name between two nodes.
    ///
    /// - Parameters:
    ///
    ///     - origin: The node from which the link originates.
    ///     - target: The node to which the link points.
    ///     - attributes: Attributes of the link.
    ///     - id: Unique link identifier. Link with given identifier must not
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
    /// - Returns: Newly created link
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
                        id: OID?=nil) -> Link {
        precondition(origin.graph === self, "Connecting from an origin from a different graph")
        precondition(target.graph === self, "Connecting to a target from a different graph")
        
        let link = Link(origin: origin, target: target, labels: labels, id: id)
        
        let change = GraphChange.connect(link)
        willChange(change)

        link.graph = self
        links.append(link)
        didChange(change)
        
        return link
    }
    

    /// Adds a custom-created link to the graph.
    ///
    /// This method can be also used to associate previously associated link
    /// with the graph. Typical use-case would be an undo command.
    /// 
    /// - Note: A link object belongs to one graph only. It can not be shared
    /// once added to a graph.
    ///
    /// - Parameters:
    ///
    ///     - link: Link to be added to the graph.
    ///
    public func add(_ link: Link) {
        precondition(link.graph == nil,
                     "Trying to associate already associated link: \(link)")
        
        let change = GraphChange.connect(link)
        willChange(change)
        
        // Register the object
        link.graph = self
        links.append(link)
        
        didChange(change)
    }

    /// Removes a specific link from the graph. This method is shared for
    /// consistency between remove(node:) and disconnect(link:).
    ///
    /// - Parameters:
    ///
    ///     - link: Link to be removed.
    ///
    func rawDisconnect(_ link: Link) {
        links.removeAll { $0 === link }
        link.graph = nil
    }
    
    
    /// Removes a specific link from the graph. Link must exist in the graph.
    ///
    /// - Parameters:
    ///
    ///     - link: Link to be removed.
    ///
    public func disconnect(link: Link) {
        precondition(link.graph === self,
                     "Trying to disconnect an unassociated link or a link from a different graph")

        let change = GraphChange.disconnect(link)
        willChange(change)
        rawDisconnect(link)
        didChange(change)
    }
    
    // MARK: - Advanced Query
    
    /// Get a list of outgoing links from a node.
    ///
    /// - Parameters:
    ///     - origin: Node from which the links originate - node is origin
    ///     node of the link.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    /// - Note: If you want to get both outgoing and incoming links of a node
    ///   then use ``neighbours(_:)``. Using ``outgoing(_:)`` + ``incoming(_:)`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    public func outgoing(_ origin: Node) -> [Link] {
        precondition(origin.graph === self,
                     "Trying to get outgoing links from a node that is not associated with the graph.")

        let result: [Link]
        
        result = self.links.filter {
            $0.origin === origin
        }

        return result
    }
    
    
    /// Get a list of links incoming to a node.
    ///
    /// - Parameters:
    ///     - target: Node to which the links are incoming – node is a target
    ///       node of the link.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    /// - Note: If you want to get both outgoing and incoming links of a node
    ///   then use ``neighbours(_:)``. Using ``outgoing(_:)`` + ``incoming(_:)`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    public func incoming(_ target: Node) -> [Link] {
        precondition(target.graph === self,
                     "Trying to get incoming links from a node that is not associated with the graph.")

        let result: [Link]
        
        result = self.links.filter {
            $0.target === target
        }

        return result
    }
    
    
    /// Get a list of links that are related to the neighbours of the node. That
    /// is, list of links where the node is either an origin or a target.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    public func neighbours(_ node: Node) -> [Link] {
        precondition(node.graph === self,
                     "Trying to get neighbor links from a node that is not associated with the graph.")

        let result: [Link]
        
        result = self.links.filter {
            $0.target === node || $0.origin === node
        }

        return result
    }

    
    /// Determines whether the node has no outgoing links. That is, if there
    /// are no links which have the node as origin.
    ///
    /// - Returns: `true` if there are no outgoing links from the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isSink(_ node: Node) -> Bool {
        precondition(node.graph === self, "Node is not associated with this graph.")
        return links.contains { $0.origin === node }
    }
    
    /// Determines whether the node has no incoming links. That is, if there
    /// are no links which have the node as target.
    ///
    /// - Returns: `true` if there are no incoming links to the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isSource(_ node: Node) -> Bool {
        precondition(node.graph === self, "Node is not associated with this graph.")
        return links.contains { $0.target === node }
    }
    
    /// Determines whether the `node` is an orphan, that is whether the node has
    /// no incoming neither outgoing links.
    ///
    /// - Returns: `true` if there are no links referring to the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isOrphan(_ node: Node) -> Bool {
        precondition(node.graph === self, "Node is not associated with this graph.")
        return links.contains { $0.origin === node || $0.target === node }
    }


    /// Called when graph is about to be changed.
    func willChange(_ change: GraphChange) {
//        graphWillChange.send(change)
    }
    
    /// Called when graph has changed.
    func didChange(_ change: GraphChange) {
//        graphDidChange.send(change)
    }


    public var description: String {
        "Graph(nodes: \(nodes.count), links: \(links.count))"
    }
    
    /// Create a copy of the graph
    public func copy() -> Graph {
        // FIXME: IMPORTANT: This needs attention/thinking. What about identities?
        
        let graph = Graph()
        var map: [ObjectIdentifier:Node] = [:]
        for node in nodes {
            let copy = node.copy()
            map[ObjectIdentifier(node)] = copy
            graph.add(copy)
        }
        for link in links {
            let originID = ObjectIdentifier(link.origin)
            let targetID = ObjectIdentifier(link.target)
            graph.connect(from: map[originID]!,
                          to: map[targetID]!,
                          labels: link.labels,
                          id: link.id)
        }
        return graph
    }
    
}

extension Graph: Equatable {
    public static func ==(lhs: Graph, rhs: Graph) -> Bool {
        return lhs.nodes == rhs.nodes
                    && lhs.links == rhs.links
    }
}
