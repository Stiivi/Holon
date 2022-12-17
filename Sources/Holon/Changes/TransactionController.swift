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
        for id in trans.removedEdges {
            // TODO: We are removing edges that were implicitly removed with removed nodes
            guard let edge = graph.edge(id) else {
                fatalError("Graph does not contain edge with ID: \(id)")
            }
            graph.remove(edge)
        }
        for id in trans.removedNodes {
            guard let node = graph.node(id) else {
                fatalError("Graph does not contain node with ID: \(id)")
            }
            graph.remove(node)
        }
        for node in trans.addedNodes.values {
            graph.add(node)
        }
        for edge in trans.addedEdges.values {
            graph.add(edge)
        }
    }
    
}
