//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 10/12/2022.
//

import XCTest
@testable import HolonKit


final class TransactionTests: XCTestCase {
    let graph: Graph = Graph()
    var ctrl: TransactionController!
    
    override func setUp() {
        ctrl = TransactionController(graph)
    }
    
    func testAddNode() throws {
        let trans = TransactionalGraph(graph)
        
        let node = Node(id: 10)
        
        XCTAssertFalse(graph.contains(node: node.id))
        XCTAssertFalse(trans.contains(node: node.id))
        
        trans.add(node)
        
        XCTAssertFalse(graph.contains(node: node.id))
        XCTAssertTrue(trans.contains(node: node.id))
        
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertEqual(trans.nodes.count, 1)
        
        ctrl.commit(trans)
        XCTAssertTrue(graph.contains(node: node.id))
        
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
        XCTAssertTrue(graph.contains(node: node.id))
        XCTAssertTrue(trans.contains(node: node.id))
        
        trans.remove(node: node.id)
        
        XCTAssertTrue(graph.contains(node: node.id))
        XCTAssertFalse(trans.contains(node: node.id))
        
        ctrl.commit(trans)
        
        XCTAssertEqual(graph.nodes.count, 0)
        XCTAssertFalse(graph.contains(node: node.id))
    }
    
    func testAddEdge() throws {
        let trans = TransactionalGraph(graph)
        
        let a = Node(id: 10)
        let b = Node(id: 20)
        let edge = Edge(origin: a.id, target: b.id, id: 30)
        
        XCTAssertFalse(graph.contains(edge: edge.id))
        XCTAssertFalse(trans.contains(edge: edge.id))

        graph.add(a)
        graph.add(b)
        trans.add(edge)
        
        XCTAssertFalse(graph.contains(edge: edge.id))
        XCTAssertTrue(trans.contains(edge: edge.id))

        XCTAssertTrue(graph.edges.isEmpty)
        XCTAssertEqual(trans.edges.count, 1)

        ctrl.commit(trans)
        XCTAssertTrue(graph.contains(edge: edge.id))

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
        let edge = Edge(origin: a.id, target: b.id, id: 30)
        
        XCTAssertFalse(graph.contains(edge: edge.id))
        XCTAssertFalse(trans.contains(edge: edge.id))

        graph.add(a)
        graph.add(b)
        graph.add(edge)
        
        XCTAssertTrue(graph.contains(edge: edge.id))
        XCTAssertTrue(trans.contains(edge: edge.id))

        trans.remove(edge: edge.id)

        XCTAssertTrue(graph.contains(edge: edge.id))
        XCTAssertFalse(trans.contains(edge: edge.id))

        ctrl.commit(trans)
        XCTAssertFalse(graph.contains(edge: edge.id))
    }

    func testRemoveEdgesWithNode() throws {
        let trans = TransactionalGraph(graph)
        
        let a = Node(id: 10)
        let b = Node(id: 20)
        let edge = Edge(origin: a.id, target: b.id, id: 30)
        
        XCTAssertFalse(graph.contains(edge: edge.id))
        XCTAssertFalse(trans.contains(edge: edge.id))

        graph.add(a)
        graph.add(b)
        graph.add(edge)
        
        XCTAssertTrue(graph.contains(edge: edge.id))
        XCTAssertTrue(trans.contains(edge: edge.id))

        trans.remove(node: a.id)

        XCTAssertTrue(graph.contains(edge: edge.id))
        XCTAssertFalse(trans.contains(edge: edge.id))

        ctrl.commit(trans)
        XCTAssertFalse(graph.contains(edge: edge.id))

    }
}
