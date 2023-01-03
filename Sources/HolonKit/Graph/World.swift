//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 17/11/2022.
//

// Development notes: World is like a Scene in a game engine or like a Document
// in a multi-document application.
//
/// World. Prototype.
///
/// Requirements:
///
/// - World is mutable
/// - World is observable (as a whole)
///
open class World: MutableGraphProtocol {
    /// Underlying graph storage
    public let graph: Graph
    
    /// Generator of IDs for objects.
    public let identityGenerator: IdentityGenerator
    
    /// Object observing graph changes.
    ///
    public var observer: WorldObserver?
    
    /// Each change increments the generation number
//    let generation: UInt64 = 0
    
    public init(graph: Graph? = nil, identityGenerator: IdentityGenerator? = nil) {
        if let graph = graph {
            guard graph.nodes.allSatisfy({ $0.world == nil }) else {
                preconditionFailure("Nodes must not be associated with any graph")
            }
            guard graph.edges.allSatisfy({ $0.world == nil }) else {
                preconditionFailure("Nodes must not be associated with any graph")
            }
        }
        self.graph = graph ?? Graph()
        
        self.identityGenerator = identityGenerator ?? SequentialIDGenerator()
    }
    
    // MARK: - Graph Protocol
    
    public var nodes: [Node] { graph.nodes }
    public var edges: [Edge] { graph.edges }
   
    // MARK: - Mutation
    
    /// - Precondition: Node must not belong to any world.
    ///
    public func add(_ node: Node) {
        precondition(node.world == nil, "Trying to associate already associated node: \(node)")
        // Register the object
        let change = GraphChange.addNode(node)
        willChange(change)

        // Claim ownership
        node.world = self
        graph.add(node)
        assert(node.world != nil)
    }
    /// Adds an edge to the world.
    ///
    /// - Precondition: Edge must not be associated with any graph.
    /// - Precondition: Origin and target must belong to the same world
    ///
    public func add(_ edge: Edge) {
        precondition(edge.world == nil,
                     "Trying to associate already associated edge: \(edge)")
 
        let change = GraphChange.addEdge(edge)
        willChange(change)

        // Claim ownership
        edge.world = self
        graph.add(edge)
    }
    
    
    /// Removes node from the graph and removes all incoming and outgoing edges
    /// for that node.
    ///
    /// - Returns: List of edges that were disconnected and list of nodes that
    ///            were removed in addition to the node requested. (The
    ///            requested node is not included in the returned list)
    ///
    /// - Precondition: Node must belong to the graph.
    ///
    @discardableResult
    public func remove(node oid: ObjectID) -> [Edge] {
        guard let node = graph.node(oid) else {
            preconditionFailure("World has no node with ID: \(oid)")
        }
        precondition(node.world === self, "Trying to remove a node that does not belong to the graph")
        // FIXME: This is not providing information about removed edges in the change
        let change = GraphChange.removeNode(node)
        willChange(change)
        // Release ownership
        node.world = nil
        return graph.remove(node: oid)
    }
    
    
    /// Adds an edge to the graph.
    ///
    /// - Note: An edge object belongs to one world only. It can not be shared
    /// once added to a graph of the world.
    ///
    /// - Parameters:
    ///
    ///     - edge: Edge to be added to the graph.
    ///
    /// - Precondition: Edge must belong to the graph.
    ///
    public func remove(edge oid: ObjectID) {
        guard let edge = graph.edge(oid) else {
            preconditionFailure("World has no edge with ID: \(oid)")
        }
        precondition(edge.world === self,
                     "Trying to disconnect an unassociated edge or an edge from a different graph")

        let change = GraphChange.removeEdge(edge)
        willChange(change)

        // Release ownership
        edge.world = nil
        return graph.remove(edge: oid)
    }
    
    // MARK: - Neighbourhood query with precondition checking
    
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
    public func incoming(_ oid: ObjectID) -> [Edge] {
        guard let target = graph.node(oid) else {
            preconditionFailure("World has no node with ID: \(oid)")
        }

        precondition(target.world != nil,
                     "Trying to get incoming edges from an unassociated node.")
        precondition(target.world === self,
                     "Trying to get incoming edges from a node that is associated with another graph.")

        return graph.incoming(oid)
    }
    
    
    /// Get a list of edges that are related to the neighbours of the node. That
    /// is, list of edges where the node is either an origin or a target.
    ///
    /// - Returns: List of edges.
    ///
    /// - Complexity: O(n). All edges are traversed.
    ///
    public func neighbours(_ oid: ObjectID) -> [Edge] {
        guard let node = graph.node(oid) else {
            preconditionFailure("World has no node with ID: \(oid)")
        }
        precondition(node.world != nil,
                     "Trying to get neighbour edges from an unassociated node.")
        precondition(node.world === self,
                     "Trying to get neighbour edges from a node that is associated with another graph.")

        return graph.neighbours(oid)
    }
    
    // MARK: - Change Observing
    
    /// Called when graph is about to be changed.
    @inlinable
    func willChange(_ change: GraphChange) {
        observer?.graphWillChange(world: self, change: change)
    }
}
