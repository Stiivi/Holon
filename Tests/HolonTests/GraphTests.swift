//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

import XCTest
@testable import Holon

final class GraphTests: XCTestCase {
    func testCopyGraph() throws {
        let graph = Graph()
        let node = Node(id: 111, labels: ["first"])
        let another = Node(id: 222, labels: ["second"])
        graph.add(node)
        graph.add(another)
        graph.connect(from: node, to: another, labels: ["link"], id: 333)
        
        let copy = graph.copy()
        
        XCTAssertEqual(copy.nodes, graph.nodes)
        XCTAssertEqual(copy.links, graph.links)
        XCTAssertEqual(copy, graph)
        XCTAssertNotEqual(copy, Graph())
    }
}
