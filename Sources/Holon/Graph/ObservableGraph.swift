//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 05/11/2022.
//

class ObservableGraph: MutableGraphProtocol {
    let graph: Graph

    public var observer: GraphObserver?

    var nodes: [Node] { graph.nodes }
    var edges: [Edge] { graph.edges }
    
    init(graph: Graph) {
        self.graph = graph
    }
    
    /// Called when graph is about to be changed.
    @inlinable
    func willChange(_ change: GraphChange) {
        observer?.graphWillChange(graph: graph, change: change)
    }
    
    @inlinable
    func add(_ node: Node) {
        let change = GraphChange.addNode(node)
        willChange(change)
        graph.add(node)
    }
    
    @inlinable
    func remove(_ node: Node) -> [Edge] {
        let change = GraphChange.removeNode(node)
        willChange(change)
        return graph.remove(node)
    }
    
    @inlinable
    func remove(_ edge: Edge) {
        let change = GraphChange.removeEdge(edge)
        willChange(change)
        graph.remove(edge)
    }

    @inlinable
    func add(_ edge: Edge) {
        let change = GraphChange.addEdge(edge)
        willChange(change)
        return graph.add(edge)
    }
}
