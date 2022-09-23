//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 09/09/2022.
//

extension GraphProtocol {
    /// Sort nodes topologically.
    ///
    /// - Parameters:
    ///  - nodes: list of nodes to be sorted
    ///  - edgeFilter: a function that specifies which edges are
    ///    relevant for the sorting of the nodes
//    func topologicalSort(_ nodes: [Node], edgeFilter: (Edge) -> Bool) {
//        var sorted: [Node] = []
//
//        var orderEdges = edges.filter {
//            edge in
//            (nodes.contains { $0 === edge.origin || $0 === edge.target}
//            && edgeFilter(edge)
//        }
//        
//        // S ← Set of all nodes with no incoming edge
//        var sources: [Node] = nodes.filter {
//            $0.dependencies.isEmpty
//        }
//
//        // List of edges that connect parameters with other nodes.
//        //
//        let parameterEdges = resolvedGraph!.edges.filter { edge in
//            edge.contains(label: Model.ParameterEdgeLabel)
//        }
//
//        let nonnegativeConstraintEdges = resolvedGraph!.edges.filter {
//            edge in
//            edge.contains(label: Model.OutflowEdgeLabel)
//            && !(edge.origin as! Stock).allowsNegative
//        }
//
//        var edges = parameterEdges + nonnegativeConstraintEdges
//        
//        //
//        //while S is not empty do
//        var node: ExpressionNode
//        
//        while !sources.isEmpty {
//            //    remove a node n from S
//            node = sources.removeFirst()
//            //    add n to L
//            sorted.append(node)
//            
//            let outgoing = edges.filter { $0.origin === node }
//            
//            for edge in outgoing {
//                edges.removeAll { $0 === edge }
//                let m = edge.target as! ExpressionNode
//                if edges.allSatisfy({$0.target !== m}) {
//                    sources.append(m)
//                }
//            }
//
//            //    for each node m with an edge e from n to m do
//            //        remove edge e from the graph
//            //        if m has no other incoming edges then
//            //            insert m into S
//
//        }
//        if !edges.isEmpty {
//            throw ModelCycleError(edges: edges)
//        }
//
//        return sorted
//
//    }
}
