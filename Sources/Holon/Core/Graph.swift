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
/// ``Graph/add(_:)``, ``Graph/connect(from:to:attributes:)-372gc``.
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
/// graph.connect(from: parent, to: leftChild, at: "left")
///
/// let rightChild = Node()
/// graph.add(rightChild)
/// graph.connect(from: parent, to: leftChild, at: "right")
/// ```
///
/// ## Lifetime and Ownership of Nodes and Links
///
/// When a node is created, it belongs to the creator until the node
/// is added to the graph. When a node is added to the graph using
/// ``Graph/add(_:)-3j4hi`` then the graph becomes owner of the node until the
/// node is removed from the graph with ``Graph/remove(_:strategy:)``.
///
/// Link, when created externally, is owned by the creator. When a link is added
/// to the graph using ``Graph/add(_:)-af7w`` or a new link is created by
/// ``Graph/connect(from:to:labels:id:)`` then graph becomes owner of the
/// link until the link is removed from the graph either with
/// ``Graph/disconnect(link:)`` or as a by-product of ``Graph/remove(_:strategy:)``.
///
public class Graph: HolonProtocol, MutableGraphProtocol {
    // TODO: Rename to GraphWorld?
    
    // MARK: - Instance variables
    
    /// List of nodes in the graph.
    public private(set) var nodes: [Node]
    
    /// List of links in the graph.
    public private(set) var links: [Link]
    
    /// List of top-level holons – those holons that have no parent.
    ///
    public var holons: [Holon] {
        nodes.compactMap {
            if $0.holon == nil {
                return $0 as? Holon
            }
            else {
                return nil
            }
        }
    }

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
    ///   - idGenerator: Generator of unique IDs. Default is ``SequenceIDGenerator``.
    ///
    public init() {
        self.nodes = []
        self.links = []
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
    /// - Precondition: Node must not belong to any graph
    public func add(_ node: Node) {
        self.add(node, into: nil)
    }
    public func add(_ node: Node, into holon: Holon?=nil) {
        precondition(node.holon == nil, "Trying to associate already associated node: \(node)")

        // FIXME: Check holon node for cycles

        node.holon = holon
        node.graph = self

        let change = GraphChange.addNode(node)
        willChange(change)
        
        // Associate the node
        nodes.append(node)
        
        didChange(change)
    }
    
    /// Strategy how the holons are removed from the graph.
    ///
    public enum HolonRemovalStrategy {
        /// Remove the holon, its children and related links.
        ///
        case remove
        
        /// Remove the holon node only and make the holon's children to belong
        /// to the parent holon of the holon removed.
        ///
        case dissolve
    }
    
    /// Removes node from the graph and removes all incoming and outgoing links
    /// for that node.
    ///
    /// If the node to be removed is a holon, all holon's nodes are removed too.
    /// A holon owns its nodes.
    ///
    /// - Returns: List of links that were disconnected and list of nodes that
    ///            were removed in addition to the node requested. (The
    ///            requested node is not included in the returned list)
    ///
    /// - Note: The caller becomes owner of the returned nodes and links.
    ///
    /// - Precondition: Node must belong to the graph.
    ///
    @discardableResult
    public func remove(_ node: Node, strategy: HolonRemovalStrategy) -> (links: [Link], nodes: [Node]) {
        precondition(node.graph === self, "Trying to remove a node that does not belong to the graph")

        var removedLinks: [Link] = []
        var removedNodes: [Node] = []
        
        // Remove the holon according to the strategy requested.
        //
        if let holon = node as? Holon {
            switch strategy {
            case .remove:
                for child in holon.nodes {
                    let removed = remove(child, strategy: .remove)
                    removedLinks += removed.links
                    removedNodes.append(child)
                    removedNodes += removed.nodes
                }
            case .dissolve:
                // Re-wire the children to belong to the parent of the removed
                // holon.
                for child in holon.nodes {
                    child.holon = node.holon
                }
            }
        }
        
        let change = GraphChange.removeNode(node)
        willChange(change)
        
        // First we remove all the connections
        for link in links {
            if link.origin === node || link.target === node {
                removedLinks.append(link)
                rawDisconnect(link)
            }
        }

        nodes.removeAll { $0 === node}
        node.holon = nil
        node.graph = nil

        didChange(change)
        return (links: removedLinks, nodes: removedNodes)
    }
    
    /// Removes node from the graph and removes all incoming and outgoing links
    /// for that node.
    ///
    /// If the node to be removed is a holon, all holon's nodes are removed too.
    /// A holon owns its nodes.
    ///
    /// - Returns: List of links that have been disconnected.
    ///
    /// - Precondition: Node must belong to the graph.
    ///
    /// This method calls ``Graph/remove(_:strategy:)`` with strategy
    /// being ``Graph/HolonRemovalStrategy/remove``.
    ///
    @discardableResult
    public func remove(_ node: Node) -> (links: [Link], nodes: [Node]) {
        return remove(node, strategy: .remove)
    }

    /// Removes the node representing the holon from the graph. All nodes
    /// that were direct children of this holon will become children of the
    /// removed holon's parent. The children are "dissolved" in the parent holon.
    ///
    /// Only the holon node and its connections are removed from the graph.
    ///
    /// This method calls ``Graph/remove(_:strategy:)`` with strategy
    /// being ``Graph/HolonRemovalStrategy/dissolve``.
    ///
    @discardableResult
    public func dissolve(_ holon: Holon) -> (links: [Link], nodes: [Node]) {
        return remove(holon, strategy: .dissolve)

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
    ///
    /// - Returns: Newly created link
    ///
    /// - Precondition: Origin and target must be from the same holon
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
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    public func outgoing(_ origin: Node) -> [Link] {
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
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    public func incoming(_ target: Node) -> [Link] {
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
        let result: [Link]
        
        result = self.links.filter {
            $0.target === node || $0.origin === node
        }

        return result
    }
    
    /// Returns links that are related to the node and that match the given
    /// link selector.
    ///
    public func neighbours(_ node: Node, selector: LinkSelector) -> [Link] {
        // TODO: Find a better name
        let links: [Link]
        switch selector.direction {
        case .incoming: links = self.incoming(node)
        case .outgoing: links = self.outgoing(node)
        }
        
        return links.filter { $0.contains(label: selector.label) }
    }

    
    /// Determines whether the node has no outgoing links. That is, if there
    /// are no links which have the node as origin.
    ///
    /// - Returns: `true` if there are no outgoing links from the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isSink(_ node: Node) -> Bool {
        guard node.graph === self else {
            fatalError("Node is not associated with this graph.")
        }
        return links.contains { $0.origin === node }
    }
    
    /// Determines whether the node has no incoming links. That is, if there
    /// are no links which have the node as target.
    ///
    /// - Returns: `true` if there are no incoming links to the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isSource(_ node: Node) -> Bool {
        guard node.graph === self else {
            fatalError("Node is not associated with this graph.")
        }
        return links.contains { $0.target === node }
    }
    
    /// Determines whether the `node` is an orphan, that is whether the node has
    /// no incoming neither outgoing links.
    ///
    /// - Returns: `true` if there are no links referring to the node.
    /// - Complexity: O(n). All links are traversed.
    ///
    public func isOrphan(_ node: Node) -> Bool {
        guard node.graph === self else {
            fatalError("Node is not associated with this graph.")
        }
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
}
