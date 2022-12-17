//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 10/12/2022.
//

import XCTest
@testable import Holon


final class TransactionTests: XCTestCase {
    let graph: Graph = Graph()
    var ctrl: TransactionController!
    
    override func setUp() {
        ctrl = TransactionController(graph)
    }
    
    func testAddNode() throws {
        let trans = TransactionalGraph(graph)
        
        let node = Node(id: 10)
        
        XCTAssertFalse(graph.contains(node))
        XCTAssertFalse(trans.contains(node))
        
        trans.add(node)
        
        XCTAssertFalse(graph.contains(node))
        XCTAssertTrue(trans.contains(node))
        
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertEqual(trans.nodes.count, 1)
        
        ctrl.commit(trans)
        XCTAssertTrue(graph.contains(node))
        
        XCTAssertEqual(graph.nodes.count, 1)
        guard let first = graph.nodes.first else {
            XCTFail("Node expected")
            return
        }
        XCTAssertIdentical(first, node)
        
    }
    
    func testRemoveNode() throws {
        let trans = TransactionalGraph(graph)
        
        let node = Node(id: 10)
        
        graph.add(node)
        
        // Sanity check
        XCTAssertTrue(graph.contains(node))
        XCTAssertTrue(trans.contains(node))
        
        trans.remove(node)
        
        XCTAssertTrue(graph.contains(node))
        XCTAssertFalse(trans.contains(node))
        
        ctrl.commit(trans)
        
        XCTAssertEqual(graph.nodes.count, 0)
        XCTAssertFalse(graph.contains(node))
    }
    
    func testAddEdge() throws {
        let trans = TransactionalGraph(graph)
        
        let a = Node(id: 10)
        let b = Node(id: 20)
        let edge = Edge(origin: a, target: b, id: 30)
        
        XCTAssertFalse(graph.contains(edge))
        XCTAssertFalse(trans.contains(edge))

        graph.add(a)
        graph.add(b)
        trans.add(edge)
        
        XCTAssertFalse(graph.contains(edge))
        XCTAssertTrue(trans.contains(edge))

        XCTAssertTrue(graph.edges.isEmpty)
        XCTAssertEqual(trans.edges.count, 1)

        ctrl.commit(trans)
        XCTAssertTrue(graph.contains(edge))

        XCTAssertEqual(graph.edges.count, 1)
        guard let first = graph.edges.first else {
            XCTFail("Node expected")
            return
        }
        XCTAssertIdentical(first, edge)

    }

    
    func testRemoveEdge() throws {
        let trans = TransactionalGraph(graph)
        
        let a = Node(id: 10)
        let b = Node(id: 20)
        let edge = Edge(origin: a, target: b, id: 30)
        
        XCTAssertFalse(graph.contains(edge))
        XCTAssertFalse(trans.contains(edge))

        graph.add(a)
        graph.add(b)
        graph.add(edge)
        
        XCTAssertTrue(graph.contains(edge))
        XCTAssertTrue(trans.contains(edge))

        trans.remove(edge)

        XCTAssertTrue(graph.contains(edge))
        XCTAssertFalse(trans.contains(edge))

        ctrl.commit(trans)
        XCTAssertFalse(graph.contains(edge))
    }

    func testRemoveEdgesWithNode() throws {
        let trans = TransactionalGraph(graph)
        
        let a = Node(id: 10)
        let b = Node(id: 20)
        let edge = Edge(origin: a, target: b, id: 30)
        
        XCTAssertFalse(graph.contains(edge))
        XCTAssertFalse(trans.contains(edge))

        graph.add(a)
        graph.add(b)
        graph.add(edge)
        
        XCTAssertTrue(graph.contains(edge))
        XCTAssertTrue(trans.contains(edge))

        trans.remove(a)

        XCTAssertTrue(graph.contains(edge))
        XCTAssertFalse(trans.contains(edge))

        ctrl.commit(trans)
        XCTAssertFalse(graph.contains(edge))

    }
}
