//
//  Graph+algorighms.swift
//  
//
//  Created by Stefan Urbanek on 09/09/2022.
//

/// An error raised when a cycle is detected in the graph.
///
public struct GraphCycleError: Error {

    /// List of edges that are part of a cycle
    ///
    public let edges: [EdgeID]

//    /// List of nodes that are part of a cycle
//    ///
//    public var nodes: [NodeID] {
//        let chain = [edges.first!.origin] + edges.map { $0.target }
//        return chain
//    }

    /// Create an error object from a list of edges.
    ///
    init(edges: [EdgeID]) {
        guard !edges.isEmpty else {
            fatalError("Cycle error must contain at least one edge")
        }
        self.edges = edges
    }
}

extension GraphProtocol {
    /// Sort nodes topologically.
    ///
    /// - Parameters:
    ///  - nodes: list of nodes to be sorted
    ///  - follow: a function that returns a list of edges related to the node
    ///
    /// Example use:
    ///
    /// Sort all nodes in a graph through incoming edge `parameter`.
    ///
    /// ``` swift
    /// let graph: Graph
    /// let sorted = graph.topologicalSort(graph.nodes) { node in
    ///     node.incoming.filter { edge in
    ///         edge.contains("parameter"
    ///     }
    /// }
    /// ```
    ///
    /// - Throws: ``GraphCycleError`` when a cycle is detected in the graph.
    ///
    /// - Note: The function ``follow`` is expected to return edges where
    ///   the origin, the target or both are the node that is passed as
    ///   an argument. Behaviour is undefined if it is not the case.
    ///
    public func topologicalSort(_ toSort: [NodeID], follow: (Node) -> [Edge]) throws -> [NodeID] {
        // FIXME: Returned [Edge] from `follow` is not safe - might have made-up edges
        
        var sorted: [NodeID] = []
        let nodes: [Node] = toSort.compactMap { self.node($0) }

        // S ← Set of all nodes with no incoming edge
        var sources: [NodeID] = nodes.filter { follow($0).isEmpty }
                                    .map { $0.id }

        // TODO: WARNING: `follow` can return unrelated edges!
        // TODO: We are calling 'follow' twice here
        var edges: [Edge] = nodes.flatMap { follow($0) }
        
        //
        //while S is not empty do
        var node: NodeID
        
        while !sources.isEmpty {
            //    remove a node n from S
            node = sources.removeFirst()
            //    add n to L
            sorted.append(node)
            
            let outgoing: [Edge] = edges.filter { $0.origin == node }
            
            for edge in outgoing {
                edges.removeAll { $0 === edge }

                // We assume that the graph is not corrupted (that is why forced unrwap)
                let m: NodeID = edge.target
                
                if edges.allSatisfy({$0.target != m}) {
                    sources.append(m)
                }
            }

            //    for each node m with an edge e from n to m do
            //        remove edge e from the graph
            //        if m has no other incoming edges then
            //            insert m into S

        }
        if !edges.isEmpty {
            throw GraphCycleError(edges: edges.map {$0.id} )
        }

        return sorted
    }
}
