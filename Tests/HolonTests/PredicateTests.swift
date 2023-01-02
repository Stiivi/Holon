//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 15/06/2022.
//

import XCTest
@testable import HolonKit

final class PredicateTests: XCTestCase {
    let graph = Graph()
    
    func testLabelPredicate() throws {
        let node0 = Node()
        let node1 = Node(labels:["parsley"])
        let node2 = Node(labels:["parsley", "sage"])
        let node3 = Node(labels:["parsley", "sage", "rosemary"])
        let node4 = Node(labels:["rosemary", "thyme"])

        let allPredicate = LabelPredicate(all: "parsley", "sage")
        let nonePredicate = LabelPredicate(none: "rosemary", "thyme")
        let anyPredicate = LabelPredicate(any: "sage", "thyme")

        XCTAssertFalse(allPredicate.match(graph: graph, node: node0))
        XCTAssertFalse(allPredicate.match(graph: graph, node: node1))
        XCTAssertTrue(allPredicate.match(graph: graph, node: node2))
        XCTAssertTrue(allPredicate.match(graph: graph, node: node3))
        XCTAssertFalse(allPredicate.match(graph: graph, node: node4))

        XCTAssertTrue(nonePredicate.match(graph: graph, node: node0))
        XCTAssertTrue(nonePredicate.match(graph: graph, node: node1))
        XCTAssertTrue(nonePredicate.match(graph: graph, node: node2))
        XCTAssertFalse(nonePredicate.match(graph: graph, node: node3))
        XCTAssertFalse(nonePredicate.match(graph: graph, node: node4))

        XCTAssertFalse(anyPredicate.match(graph: graph, node: node0))
        XCTAssertFalse(anyPredicate.match(graph: graph, node: node1))
        XCTAssertTrue(anyPredicate.match(graph: graph, node: node2))
        XCTAssertTrue(anyPredicate.match(graph: graph, node: node3))
        XCTAssertTrue(anyPredicate.match(graph: graph, node: node4))
    }
    
    func testNegationPredicate() throws {
        let node = Node(labels: ["parsley"])
        let notParsley = NegationPredicate(LabelPredicate(all: "parsley"))
        let notSage = NegationPredicate(LabelPredicate(all: "sage"))

        XCTAssertFalse(notParsley.match(graph: graph, object: node))
        XCTAssertTrue(notSage.match(graph: graph, object: node))
    }
    
    func testCompoundPredicate() throws {
        let node1 = Node(labels: ["parsley"])
        let node2 = Node(labels: ["parsley", "sage"])
        let node3 = Node(labels: ["parsley", "sage", "rosemary"])
        let node4 = Node(labels: ["thyme"])

        let parsleyAndSageP = LabelPredicate(all: "parsley")
                                .and(LabelPredicate(all: "sage"))
        let parsleyOrSageP = LabelPredicate(all: "parsley")
                                .or(LabelPredicate(all: "sage"))

        XCTAssertFalse(parsleyAndSageP.match(graph: graph, object: node1))
        XCTAssertTrue(parsleyAndSageP.match(graph: graph, object: node2))
        XCTAssertTrue(parsleyAndSageP.match(graph: graph, object: node3))
        XCTAssertFalse(parsleyAndSageP.match(graph: graph, object: node4))

        XCTAssertTrue(parsleyOrSageP.match(graph: graph, object: node1))
        XCTAssertTrue(parsleyOrSageP.match(graph: graph, object: node2))
        XCTAssertTrue(parsleyOrSageP.match(graph: graph, object: node3))
        XCTAssertFalse(parsleyOrSageP.match(graph: graph, object: node4))
    }
}

final class EdgePredicateTests: XCTestCase {
    let graph = Graph()

    func testEdgeObjectPredicate() throws {
        let node1 = Node(labels: ["this"])
        let node2 = Node(labels: ["that"])
        graph.add(node1)
        graph.add(node2)

        let edge12 = graph.connect(from: node1, to: node2, labels: ["in"])
        let edge21 = graph.connect(from: node2, to: node1, labels: ["out"])

        let p1 = EdgeObjectPredicate(origin: LabelPredicate(all: "this"))
        XCTAssertTrue(p1.match(graph: graph, edge: edge12))
        XCTAssertFalse(p1.match(graph: graph, edge: edge21))

        let p2 = EdgeObjectPredicate(target: LabelPredicate(all: "this"))
        XCTAssertFalse(p2.match(graph: graph, edge: edge12))
        XCTAssertTrue(p2.match(graph: graph, edge: edge21))

        let p3 = EdgeObjectPredicate(edge: LabelPredicate(all: "in"))
        XCTAssertTrue(p3.match(graph: graph, edge: edge12))
        XCTAssertFalse(p3.match(graph: graph, edge: edge21))

        let p4 = EdgeObjectPredicate(edge: LabelPredicate(all: "out"))
        XCTAssertFalse(p4.match(graph: graph, edge: edge12))
        XCTAssertTrue(p4.match(graph: graph, edge: edge21))

        let edge12empty = graph.connect(from: node1, to: node2, labels: [])
        let edge21empty = graph.connect(from: node2, to: node1, labels: [])

        let p5 = EdgeObjectPredicate(
            origin: LabelPredicate(all: "this"),
            target: LabelPredicate(all: "that"))

        XCTAssertTrue(p5.match(graph: graph, edge: edge12))
        XCTAssertTrue(p5.match(graph: graph, edge: edge12empty))
        XCTAssertFalse(p5.match(graph: graph, edge: edge21))
        XCTAssertFalse(p5.match(graph: graph, edge: edge21empty))

        let p6 = EdgeObjectPredicate(
            origin: LabelPredicate(all: "this"),
            target: LabelPredicate(all: "that"),
            edge: LabelPredicate(all: "in"))

        XCTAssertTrue(p6.match(graph: graph, edge: edge12))
        XCTAssertFalse(p6.match(graph: graph, edge: edge12empty))
        XCTAssertFalse(p6.match(graph: graph, edge: edge21))
        XCTAssertFalse(p6.match(graph: graph, edge: edge21empty))

    }
}
