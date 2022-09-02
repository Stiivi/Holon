//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 15/06/2022.
//

import XCTest
@testable import Holon

final class PredicateTests: XCTestCase {
    func testLabelPredicate() throws {
        let node0 = Node()
        let node1 = Node(labels:["parsley"])
        let node2 = Node(labels:["parsley", "sage"])
        let node3 = Node(labels:["parsley", "sage", "rosemary"])
        let node4 = Node(labels:["rosemary", "thyme"])

        let allPredicate = LabelPredicate(all: "parsley", "sage")
        let nonePredicate = LabelPredicate(none: "rosemary", "thyme")
        let anyPredicate = LabelPredicate(any: "sage", "thyme")

        XCTAssertFalse(allPredicate.match(node0))
        XCTAssertFalse(allPredicate.match(node1))
        XCTAssertTrue(allPredicate.match(node2))
        XCTAssertTrue(allPredicate.match(node3))
        XCTAssertFalse(allPredicate.match(node4))

        XCTAssertTrue(nonePredicate.match(node0))
        XCTAssertTrue(nonePredicate.match(node1))
        XCTAssertTrue(nonePredicate.match(node2))
        XCTAssertFalse(nonePredicate.match(node3))
        XCTAssertFalse(nonePredicate.match(node4))

        XCTAssertFalse(anyPredicate.match(node0))
        XCTAssertFalse(anyPredicate.match(node1))
        XCTAssertTrue(anyPredicate.match(node2))
        XCTAssertTrue(anyPredicate.match(node3))
        XCTAssertTrue(anyPredicate.match(node4))
    }
    
    func testNegationPredicate() throws {
        let node = Node(labels: ["parsley"])
        let notParsley = NegationPredicate(LabelPredicate(all: "parsley"))
        let notSage = NegationPredicate(LabelPredicate(all: "sage"))

        XCTAssertFalse(notParsley.match(node))
        XCTAssertTrue(notSage.match(node))
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

        XCTAssertFalse(parsleyAndSageP.match(node1))
        XCTAssertTrue(parsleyAndSageP.match(node2))
        XCTAssertTrue(parsleyAndSageP.match(node3))
        XCTAssertFalse(parsleyAndSageP.match(node4))

        XCTAssertTrue(parsleyOrSageP.match(node1))
        XCTAssertTrue(parsleyOrSageP.match(node2))
        XCTAssertTrue(parsleyOrSageP.match(node3))
        XCTAssertFalse(parsleyOrSageP.match(node4))
    }
}

final class LinkPredicateTests: XCTestCase {
    let graph = Graph()

    func testLinkObjectPredicate() throws {
        let node1 = Node(labels: ["this"])
        let node2 = Node(labels: ["that"])
        graph.add(node1)
        graph.add(node2)

        let link12 = graph.connect(from: node1, to: node2, labels: ["in"])
        let link21 = graph.connect(from: node2, to: node1, labels: ["out"])

        let p1 = LinkObjectPredicate(origin: LabelPredicate(all: "this"))
        XCTAssertTrue(p1.match(link12))
        XCTAssertFalse(p1.match(link21))

        let p2 = LinkObjectPredicate(target: LabelPredicate(all: "this"))
        XCTAssertFalse(p2.match(link12))
        XCTAssertTrue(p2.match(link21))

        let p3 = LinkObjectPredicate(link: LabelPredicate(all: "in"))
        XCTAssertTrue(p3.match(link12))
        XCTAssertFalse(p3.match(link21))

        let p4 = LinkObjectPredicate(link: LabelPredicate(all: "out"))
        XCTAssertFalse(p4.match(link12))
        XCTAssertTrue(p4.match(link21))

        let link12empty = graph.connect(from: node1, to: node2, labels: [])
        let link21empty = graph.connect(from: node2, to: node1, labels: [])

        let p5 = LinkObjectPredicate(
            origin: LabelPredicate(all: "this"),
            target: LabelPredicate(all: "that"))

        XCTAssertTrue(p5.match(link12))
        XCTAssertTrue(p5.match(link12empty))
        XCTAssertFalse(p5.match(link21))
        XCTAssertFalse(p5.match(link21empty))

        let p6 = LinkObjectPredicate(
            origin: LabelPredicate(all: "this"),
            target: LabelPredicate(all: "that"),
            link: LabelPredicate(all: "in"))

        XCTAssertTrue(p6.match(link12))
        XCTAssertFalse(p6.match(link12empty))
        XCTAssertFalse(p6.match(link21))
        XCTAssertFalse(p6.match(link21empty))

    }
}
