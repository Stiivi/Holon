//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 10/12/2022.
//

class TransactionController {
    let graph: MutableGraphProtocol
    init(_ graph: MutableGraphProtocol) {
        self.graph = graph
    }
    
    func commit(_ trans: TransactionalGraph) {
        // TODO: Lock the graph
        for edgeID in trans.removedEdges {
            graph.remove(edge: edgeID)
        }
        for nodeID in trans.removedNodes {
            graph.remove(node: nodeID)
        }
        for node in trans._addedNodes.values {
            graph.add(node)
        }
        for edge in trans._addedEdges.values {
            graph.add(edge)
        }
    }
    
}
