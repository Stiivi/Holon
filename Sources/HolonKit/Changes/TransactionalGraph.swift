//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 10/12/2022.
//

// TODO: Cosmetic: Distinguish between ID and Node/Edge in variable names

// TODO: Rename to "DifferentialGraph"
/// Transactional graph is an object representing aggregate of changes to a
/// graph.
///
class TransactionalGraph: MutableGraphProtocol {
    /// Parent of this transactional graph
    let parent: GraphProtocol

    // Graph Difference
    // ----------------
    var _addedNodes: [NodeID:Node] = [:]
    
    /// List of nodes that were added to the graph in this transaction.
    ///
    var addedNodes: [NodeID] { Array(_addedNodes.keys) }
    
    /// Set of nodes that were removed from the graph in this transaction.
    ///
    var removedNodes: Set<NodeID> = Set()
    
    var _addedEdges: [EdgeID:Edge] = [:]

    /// List of edges that were added to the graph in this transaction.
    ///
    var addedEdges: [EdgeID] { Array(_addedEdges.keys) }

    /// Set of edges that were removed from the graph in this transaction.
    ///
    var removedEdges: Set<EdgeID> = Set()
    
    /// List of edges of the transactional graph.
    ///
    /// The list of nodes contains all the changes that are about to apply
    /// to the graph.
    ///
    var nodes: [Node] {
        let parents = parent.nodes.filter {
            !removedNodes.contains($0.id)
        }
        
        return parents + _addedNodes.values
    }
    
    /// List of edges of the transactional graph.
    ///
    /// The list of edges contains all the changes that are about to apply
    /// to the graph.
    ///
    var edges: [Edge] {
        let parents = parent.edges.filter {
            !removedEdges.contains($0.id)
        }
        
        return parents + _addedEdges.values
    }

    /// Create a new transactional graph with a parent graph to which we are
    /// trying to apply changes.
    ///
    init(_ parent: GraphProtocol) {
        self.parent = parent
    }
    
    
    /// Returns ``true`` if the graph contains given node.
    ///
    /// The transactional graph contains a node if one of the following is true:
    ///
    /// - The node was added to the transactional graph
    /// - The node exists in the parent and was not removed in this
    ///   transactional graph
    ///
    func contains(node nodeID: NodeID) -> Bool {
        return _addedNodes[nodeID] != nil
        || (!removedNodes.contains(nodeID) && parent.contains(node: nodeID))
    }

    /// Returns ``true`` if the graph contains given edge.
    ///
    /// The transactional graph contains an edge if one of the following is true:
    ///
    /// - The edge was added to the transactional graph
    /// - The edge exists in the parent and was not removed in this
    ///   transactional graph
    ///
    func contains(edge edgeID: EdgeID) -> Bool {
        return _addedEdges[edgeID] != nil
        || (!removedEdges.contains(edgeID) && parent.contains(edge: edgeID))
    }

    /// Add a node to the graph.
    ///
    /// - Precondition: The node must not exist in the graph.
    ///
    func add(_ node: Node) {
        precondition(!contains(node: node.id),
                     "The transactional graph already contains a node with id '\(node.id)'.")

        _addedNodes[node.id] = node
    }

    /// Remove a node from the graph.
    ///
    /// - Precondition: The node must not exist in the graph.
    ///
    @discardableResult
    func remove(node nodeID: NodeID) -> [Edge] {
        precondition(contains(node: nodeID),
                     "The transactional graph does not contain a node with id '\(nodeID)'.")

        var disconnected: [Edge] = []
        
        // First we remove all the connections
        for edge in edges {
            if edge.origin == nodeID || edge.target == nodeID {
                disconnected.append(edge)
                remove(edge: edge.id)
            }
        }

        removedNodes.insert(nodeID)

        return disconnected
    }
    
    /// Add an edge to the graph.
    ///
    /// - Precondition: The edge must not exist in the graph.
    ///
    func add(_ edge: Edge) {
        precondition(!contains(edge: edge.id),
                     "The transactional graph already contains an edge with id '\(edge.id)'.")

        _addedEdges[edge.id] = edge
    }
    
    /// Remove an edge from the graph.
    ///
    /// - Precondition: The edge must exist in the graph.
    ///
    func remove(edge edgeID: EdgeID) {
        precondition(contains(edge: edgeID),
                     "The transactional graph does not contain an edge with id '\(edgeID)'.")

        removedEdges.insert(edgeID)
    }
}

