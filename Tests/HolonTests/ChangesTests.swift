//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/08/2022.
//

import XCTest
@testable import Holon

final class ChangesTests: XCTestCase {
    func testAddNodeChange() throws {
        let graph = Graph()
        let node = Node()
        let change: GraphChange = .addNode(node)

        let revert = graph.applyChange(change)
        
        guard let first = graph.nodes.first else {
            XCTFail("One node is expected")
            return
        }
        XCTAssertIdentical(first, node)
        XCTAssertEqual(revert[0], .removeNode(node))
    }

    func testRemoveNodeChange() throws {
        let graph = Graph()
        let node = Node()
        let change: GraphChange = .removeNode(node)

        graph.add(node)
        let revert = graph.applyChange(change)
        
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertEqual(revert[0], .addNode(node))
    }

    func testRemoveNodeWithEdgesChange() throws {
        let graph = Graph()
        let node = Node()
        let change: GraphChange = .removeNode(node)
        
        graph.add(node)
        let edge = graph.connect(from: node, to: node)

        let revert = graph.applyChange(change)
        
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertTrue(graph.edges.isEmpty)
        XCTAssertEqual(revert, [.addNode(node), .addEdge(edge)])
    }

    func testAddEdgeChange() throws {
        let graph = Graph()
        let node = Node()
        graph.add(node)
        let edge = Edge(origin: node, target: node)
        let change: GraphChange = .addEdge(edge)
        
        let revert = graph.applyChange(change)
        
        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertEqual(graph.edges.count, 1)
        XCTAssertEqual(revert, [.removeEdge(edge)])
    }

    func testRemoveEdgeChange() throws {
        let graph = Graph()
        let node = Node()
        graph.add(node)
        let edge = Edge(origin: node, target: node)
        graph.add(edge)
        
        let change: GraphChange = .removeEdge(edge)
        
        let revert = graph.applyChange(change)
        
        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertEqual(graph.edges.count, 0)
        XCTAssertEqual(revert, [.addEdge(edge)])
    }
}
