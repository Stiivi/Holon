//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

import XCTest
@testable import Holon


final class GraphTests: XCTestCase {
    func testAdd() throws {
        let graph = Graph()
        let a = Node()
        graph.add(a)
        XCTAssertTrue(graph.contains(node: a))

        let b = Node()
        graph.add(b)
        XCTAssertTrue(graph.contains(node: b))
    }
    
    func testConnect() throws {

        let graph = Graph()
        let a = Node()
        graph.add(a)
        let b = Node()
        graph.add(b)

        let edge = graph.connect(from: a, to: b)

        XCTAssertEqual(graph.edges.count, 1)
        XCTAssertIdentical(edge.origin, a)
        XCTAssertIdentical(edge.target, b)
        if let first = graph.edges.first {
            XCTAssertIdentical(first, edge)
        }
        else {
            XCTFail("No edge in graph")
        }
    }
    
    func testRemoveConnection() throws {
        let graph = Graph()
        let a = Node()
        graph.add(a)
        let b = Node()
        graph.add(b)
        
        let edge = graph.connect(from: a, to: b)
        
        XCTAssertEqual(graph.edges.count, 1)
        graph.remove(edge)
        XCTAssertEqual(graph.edges.count, 0)
    }

    func testRemoveNode() throws {
        let graph = Graph()
        let a = Node()
        graph.add(a)
        graph.remove(a)

        XCTAssertEqual(graph.nodes.count, 0)
    }

    func testOutgoingIncoming() throws {
        let graph = Graph()
        let a = Node()
        let b = Node()
        let c = Node()
        
        graph.add(a)
        graph.add(b)
        graph.add(c)

        let edge1 = graph.connect(from: a, to: b, labels: ["child", "one"])
        let edge2 = graph.connect(from: a, to: c, labels: ["child", "two"])

        XCTAssertEqual(graph.outgoing(a).count, 2)
        XCTAssertEqual(graph.outgoing(b).count, 0)
        XCTAssertEqual(graph.outgoing(c).count, 0)

        XCTAssertEqual(graph.incoming(a).count, 0)
        XCTAssertEqual(graph.incoming(b).count, 1)
        XCTAssertEqual(graph.incoming(c).count, 1)

        let edges = graph.outgoing(a)
        XCTAssertEqual(Set([edge1, edge2]), Set(edges))
    }

    func testRemoveEdgeWithNodeRemoval() throws {
        let graph = Graph()
        let a = Node()
        let b = Node()
        graph.add(a)
        graph.add(b)

        let edge = graph.connect(from: a, to: b)

        let removed = graph.remove(a)
        XCTAssertEqual(graph.edges.count, 0)
        XCTAssertEqual(removed.count, 1)
        if let first = removed.first {
            XCTAssertIdentical(edge, first)
        }
        else {
            XCTFail("There should be exactly one removed edge")
        }
    }

    func testCopyGraph() throws {
        let graph = Graph()
        let node = Node(id: 111, labels: ["first"])
        let another = Node(id: 222, labels: ["second"])
        graph.add(node)
        graph.add(another)
        graph.connect(from: node, to: another, labels: ["edge"], id: 333)
        
        let copy = graph.copy()
        
        XCTAssertEqual(Set(copy.nodes), Set(graph.nodes))
        XCTAssertEqual(Set(copy.edges), Set(graph.edges))
        XCTAssertEqual(copy, graph)
        XCTAssertNotEqual(copy, Graph())
    }
    
//    func testSort() throws {
//        let graph = Graph()
//        let node1 = Node(id: 1)
//        let node2 = Node(id: 2)
//        let node3 = Node(id: 3)
//        let node4 = Node(id: 4)
//        graph.add(node1)
//        graph.add(node2)
//        graph.add(node3)
//        graph.add(node4)
//
//        // Order: (4 -x-> ) 2 ---> 3 ---> 1
//        
//        graph.connect(from: node2, to: node3, labels: ["follow"])
//        graph.connect(from: node3, to: node1, labels: ["follow"])
//        graph.connect(from: node4, to: node1, labels: ["irrelevant"])
//
//        let sortAny = graph.topologicalSort(graph.nodes) {
//            _ in true
//        }
//        
//        let sortFollow = graph.topologicalSort(graph.nodes) {
//            edge in edge.contains("follow")
//        }
//
//    }
}

final class PathTests: XCTestCase {
    let graph: Graph = Graph()
    
    func testPathIsValid() {
        let node1 = Node()
        let node2 = Node()
        let node3 = Node()
        
        graph.add(node1)
        graph.add(node2)
        graph.add(node3)

        let edge1 = graph.connect(from: node1, to: node2)
        let edge2 = graph.connect(from: node2, to: node3)
        let edge3 = graph.connect(from: node3, to: node3)
        let edge4 = graph.connect(from: node3, to: node3)

        XCTAssertTrue(Path.isValid([]))
        XCTAssertTrue(Path.isValid([edge1]))
        
        XCTAssertTrue(Path.isValid([edge1, edge2, edge3, edge4]))
        XCTAssertTrue(Path.isValid([edge4, edge4, edge4, edge4]))
        
        XCTAssertFalse(Path.isValid([edge1, edge3]))
        XCTAssertFalse(Path.isValid([edge4, edge4, edge1]))
    }
}
