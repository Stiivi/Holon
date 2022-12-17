//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 10/12/2022.
//

import Foundation

// TODO: Rename to "DifferentialGraph"
class TransactionalGraph: MutableGraphProtocol {
    /// Parent of this transactional graph
    let parent: GraphProtocol

    // Graph Difference
    // ----------------
    var addedNodes: [OID:Node] = [:]
    var removedNodes: Set<OID> = Set()
    
    var addedEdges: [OID:Edge] = [:]
    var removedEdges: Set<OID> = Set()
    
    var nodes: [Node] {
        let parents = parent.nodes.filter {
            !removedNodes.contains($0.id)
        }
        
        return parents + addedNodes.values
    }
    var edges: [Edge] {
        let parents = parent.edges.filter {
            !removedEdges.contains($0.id)
        }
        
        return parents + addedEdges.values
    }

    init(_ graph: GraphProtocol) {
        self.parent = graph
    }
    
    
    /// Returns ``true`` if the graph contains given node.
    ///
    /// The transactional graph contains a node if one of the following is true:
    ///
    /// - The node was added to the transactional graph
    /// - The node exists in the parent and was not removed in this
    ///   transactional graph
    ///
    func contains(_ node: Node) -> Bool {
        return addedNodes[node.id] != nil
        || (!removedNodes.contains(node.id) && parent.contains(node))
    }

    func contains(_ edge: Edge) -> Bool {
        return addedEdges[edge.id] != nil
        || (!removedEdges.contains(edge.id) && parent.contains(edge))
    }

    func add(_ node: Node) {
        precondition(!contains(node), "The transactional graph already contains a node with id '\(node.id)'.")

        addedNodes[node.id] = node
    }

    func remove(_ node: Node) -> [Edge] {
        precondition(contains(node), "The transactional graph does not contain a node with id '\(node.id)'.")

        var disconnected: [Edge] = []
        
        // First we remove all the connections
        for edge in edges {
            if edge.origin === node || edge.target === node {
                disconnected.append(edge)
                remove(edge)
            }
        }

        removedNodes.insert(node.id)

        return disconnected
    }
    
    func add(_ edge: Edge) {
        precondition(!contains(edge), "The transactional graph already contains an edge with id '\(edge.id)'.")

        addedEdges[edge.id] = edge
    }
    
    func remove(_ edge: Edge) {
        precondition(contains(edge), "The transactional graph does not contain an edge with id '\(edge.id)'.")

        removedEdges.insert(edge.id)
    }
}

