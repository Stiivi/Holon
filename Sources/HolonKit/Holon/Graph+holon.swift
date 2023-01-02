//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

extension Graph {
    /// List of top-level holons – those holons that have no parent.
    ///
    public var topLevelHolons: [Node] { nodes.filter { $0.holon == nil } }

    public var allHolons: [Node] { nodes.filter { $0.isHolon } }

    /// Connects a node to its parent holon.
    ///
    /// Creates a properly annotated edge between a node and holon that will
    /// own the node. Edge created this way can be used to manage holon
    /// related constraints.
    ///
    /// See also: ``Graph/connect(from:to:labels:id:)``
    ///
    /// - Precondition: `holon` must be a a holon node.
    /// - Precondition: `holon` must not already contain an edge to another holon.
    ///
    /// - Note: Preconditions are met if the graph conforms to the
    /// ``HolonConstraint``.
    ///
    @discardableResult
    public func connect(node: Node,
                        holon: Node,
                        labels: LabelSet = [],
                        id: OID? = nil) -> Edge {
        precondition(holon.isHolon)
        precondition(node.holon == nil,
                     "A node already belongs to a holon")
        
        // TODO: Check for cycles
        
        let edge = Edge(origin: node.id,
                        target: holon.id,
                        labels: labels.union([HolonLabel.HolonEdge]),
                        id: id)
        add(edge)
        return edge
    }
    
    /// Remove a holon from the graph and remove all its children.
    ///
    @discardableResult
    public func removeHolon(_ holonNode: NodeID) -> (edges: [Edge], nodes: [Node]) {
        let holon = Holon(graph: self, nodeID: holonNode)
//        precondition(holon.isHolon)

        var removedEdges: [Edge] = []
        var removedNodes: [Node] = []
        
        // Re-wire the parent of holon's children.
        for child in holon.nodes {
            if child.isHolon {
                let removed = removeHolon(child.id)
                removedEdges += removed.edges
                removedNodes.append(child)
                removedNodes += removed.nodes
            }
            else {
                removedEdges += remove(node: child.id)
                removedNodes.append(child)
            }
        }
        
        removedEdges += remove(node: holonNode)
        
        return (edges: removedEdges, nodes: removedNodes)
        
    }
    
    /// Remove a holon node from the graph and make all its children to belong
    /// to the removed node's parent holon. If the removed node has no parent,
    /// then the children will become top-level nodes in the holon hierarchy.
    ///
    /// - Returns: A tuple with a list of removed edges belonging to the removed
    ///   holon, and a list of edges created to the holon's parent.
    ///
    @discardableResult
    public func dissolveHolon(_ holon: Node) -> (removed: [Edge], created: [Edge]) {
        fatalError("Not implemented")
        precondition(holon.isHolon)
        var created: [Edge] = []
        
        let parent = holon.holon
        
        // Re-wire the parent of holon's children.
//        for child in holon.nodes {
//            let edge = child.holonEdge!
//            remove(edge: edge.id)
//            if let parent = parent {
//                let edge = connect(node: child,
//                                   holon: parent,
//                                   labels: edge.labels,
//                                   id: edge.id)
//                created.append(edge)
//            }
//        }
//
//        let removed = remove(node: holon.id)
//
//        return (removed: removed, created: created)
        return (removed: [], created: [])
    }
}
