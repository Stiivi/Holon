//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/08/2022.
//

import XCTest
@testable import Holon

struct Thing: Component, KeyedAttributes {
    var name: String {
        willSet {
//            self.graph?.willChange(.setAttribute(self, "name", name))
        }
        
    }
    
    init(name: String) {
        self.name = name
    }
    
    var attributeKeys: [AttributeKey] {
        ["name"]
    }
    
    func attribute(forKey key: String) -> (any AttributeValue)? {
        switch key {
        case "name": return name
        default: return nil
        }
    }
    
    mutating func setAttribute(value: any AttributeValue, forKey key: AttributeKey) {
        switch key {
        case "name": self.name = value.stringValue()!
        default: fatalError("Unknown attribute: \(key) in \(type(of:self))")
        }
    }
}

final class ChangesTests: XCTestCase {
    let graph = Graph()
    
    func testAddNodeChange() throws {
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
        let node = Node()
        let change: GraphChange = .removeNode(node)

        graph.add(node)
        let revert = graph.applyChange(change)
        
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertEqual(revert[0], .addNode(node))
    }

    func testRemoveNodeWithEdgesChange() throws {
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
    
    func testSetLabelChange() throws {
        let node = Node(labels: ["one"])
        graph.add(node)
        
        let change: GraphChange = .setLabel(node, "two")
        
        let revert = graph.applyChange(change)
        
        XCTAssertEqual(node.labels, Set(["one", "two"]))
        XCTAssertEqual(revert, [.unsetLabel(node, "two")])

        let revert2 = graph.applyChange(revert[0])
        XCTAssertEqual(node.labels, Set(["one"]))
        XCTAssertEqual(revert2, [.setLabel(node, "two")])

    }
    func testSetAttributeChange() throws {
        throw XCTSkip("Wrong test: Setting attributes should now be done through world")
//        let node = Thing(name: "Alice")
//        graph.add(node)
//        
//        let change: GraphChange = .setAttribute(node, "name", "Bob")
//        
//        let revert = graph.applyChange(change)
//        
//        XCTAssertEqual(node.name, "Bob")
//        XCTAssertEqual(revert, [.setAttribute(node, "name", "Alice")])
//
//        let revert2 = graph.applyChange(revert[0])
//        XCTAssertEqual(node.name, "Alice")
//        XCTAssertEqual(revert2, [.setAttribute(node, "name", "Bob")])
//
    }

}
