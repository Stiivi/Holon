//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 15/06/2022.
//

import XCTest
@testable import Holon

final class ConstraintsTests: XCTestCase {
    func testUniqueNeighbourhoodConstraint() throws {
        let graph = Graph()
        let source = Node(labels:["source"])
        let target1 = Node(labels:["target1"])
        let target2 = Node(labels:["target2"])
        
        let constraint: NodeConstraint = NodeConstraint(
            name: "single_outflow",
            match: LabelPredicate(all: "source"),
            requirement: UniqueNeighbourRequirement(EdgeSelector("flow", direction: .outgoing), required: false)
        )

        let constraintRequired: NodeConstraint = NodeConstraint(
            name: "single_outflow",
            match: LabelPredicate(all: "source"),
            requirement: UniqueNeighbourRequirement(EdgeSelector("flow", direction: .outgoing), required: true)
        )

        graph.add(source)
        graph.add(target1)
        graph.add(target2)
        
        let flow1 = graph.connect(from: source, to: target1)
        let flow2 = graph.connect(from: source, to: target2)

        let violations = constraint.check(graph)
        /// Non-required constraint is satisfied, the required constraint is not
        XCTAssertTrue(violations.edges.isEmpty)
        XCTAssertTrue(violations.nodes.isEmpty)
        XCTAssertEqual(constraintRequired.check(graph).nodes, [source])

        
        /// Both constraints are satisfied
        flow1.set(label: "flow")
        let violations2 = constraint.check(graph)
        XCTAssertTrue(violations2.edges.isEmpty)
        XCTAssertTrue(violations2.nodes.isEmpty)
        let violations3 = constraintRequired.check(graph)
        XCTAssertTrue(violations3.nodes.isEmpty)
        XCTAssertTrue(violations3.edges.isEmpty)

        /// Both constraints are not satisfied.
        flow2.set(label: "flow")
        ///
        XCTAssertEqual(constraint.check(graph).nodes, [source])
        XCTAssertEqual(constraintRequired.check(graph).nodes, [source])
    }
    
    func testEdgeConstraint() throws {
        let graph = Graph()
        let node1 = Node(labels: ["this"])
        let node2 = Node(labels: ["that"])
        graph.add(node1)
        graph.add(node2)

        graph.connect(from: node1, to: node2, labels: ["good"])
        let edgeBad = graph.connect(from: node1, to: node2, labels: ["bad"])

        let c1 = EdgeConstraint(
            name: "test_constraint",
            match: EdgeObjectPredicate(
                origin: LabelPredicate(all: "this"),
                target: LabelPredicate(all: "that"),
                edge: LabelPredicate(all: "bad")
            ),
            requirement: RejectAll()
        )
        
        let violations1 = c1.check(graph)
        
        XCTAssertEqual(violations1.edges, [edgeBad])
        
        let c2 = EdgeConstraint(
            name: "test_constraint",
            match: EdgeObjectPredicate(
                origin: LabelPredicate(all: "this"),
                target: LabelPredicate(all: "that"),
                edge: LabelPredicate(all: "bad")
            ),
            requirement: AcceptAll()
        )
        
        let violations2 = c2.check(graph)
        
        XCTAssertEqual(violations2.edges, [])
        XCTAssertEqual(violations2.nodes, [])
    }
}

final class EdgeRequirementsTests: XCTestCase {
    let graph = Graph()

    func testRejectAll() throws {
        let graph = Graph()
        let node = Node()
        graph.add(node)
        let edge1 = graph.connect(from: node, to: node, labels: ["one"])
        let edge2 = graph.connect(from: node, to: node, labels: ["two"])
        
        let requirement = RejectAll()
        let violations = requirement.check(graph: graph, edges: [edge1, edge2])
        XCTAssertEqual(violations.count, 2)
        XCTAssertEqual(violations, [edge1, edge2])
        
    }
}

final class TestUniqueProperty: XCTestCase {
    let graph = Graph()

    func testEmpty() throws {
        let req = UniqueProperty<OID> { $0.id }
        let violations = req.check(graph: graph, objects: [])
        XCTAssertTrue(violations.isEmpty)
    }

    func testNoDupes() throws {
        let req = UniqueProperty<OID> { $0.id }
        let objects = [
            Node(id: 10),
            Node(id: 20),
            Node(id: 30),
        ]
        
        let violations = req.check(graph: graph, objects: objects)
        XCTAssertTrue(violations.isEmpty)
    }

    func testHasDupes() throws {
        let req = UniqueProperty<OID> { $0.id }
        let n1 = Node(id: 10)
        let n1d = Node(id: 10)
        let n2 = Node(id: 20)
        let n3 = Node(id: 30)
        let n3d = Node(id: 30)
        let objects = [n1, n1d, n2, n3, n3d]

        // FIXME: Once we fix protocol remove the map
        let violations = req.check(graph: graph, objects: objects).map { $0 as! Node }
        XCTAssertEqual(violations.count, 4)
        
        XCTAssertTrue(violations.contains(n1))
        XCTAssertTrue(violations.contains(n1d))
        XCTAssertTrue(violations.contains(n3))
        XCTAssertTrue(violations.contains(n3d))
    }
}

final class TestEdgeLabelsRequirement: XCTestCase {
    let graph = Graph()
    
    func testOrigin() throws {
        let origin = Node(labels: ["origin"])
        let target = Node(labels: ["target"])
        graph.add(origin)
        graph.add(target)
        let validEdge = graph.connect(from: origin, to: target)
        let invalidEdge = graph.connect(from: target, to: origin)

        let requirement = EdgeLabelsRequirement(
            origin: LabelPredicate(all: "origin"),
            target: nil,
            edge: nil
        )
        
        let invalid = requirement.check(graph: graph, edges: graph.edges)
        
        XCTAssertEqual(invalid.count, 1)
        XCTAssertTrue(invalid.contains(invalidEdge))
        XCTAssertFalse(invalid.contains(validEdge))
    }
}
