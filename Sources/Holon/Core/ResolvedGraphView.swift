//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 29/08/2022.
//

import Foundation

/// View of a graph with links resolved.
///
public class ResolvedGraphView: GraphProtocol {
    public let graph: Graph
    public var nodes: [Node] { graph.nodes.filter { !($0 is Port) } }
    public var links: [Link] { graph.links.map { $0.resolved() } }
    
    /// Creates a view for a graph where all of the indirect links will be
    /// resolved to direct links. Link ID of the resolved link is the same as
    /// the link ID of the indirect link.
    /// 
    init(_ graph: Graph) {
        self.graph = graph
    }
}
