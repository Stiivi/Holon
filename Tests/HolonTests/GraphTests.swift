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

        let link = graph.connect(from: a, to: b)

        XCTAssertEqual(graph.links.count, 1)
        XCTAssertIdentical(link.graph, graph)
        XCTAssertIdentical(link.origin, a)
        XCTAssertIdentical(link.target, b)
        if let first = graph.links.first {
            XCTAssertIdentical(first, link)
        }
        else {
            XCTFail("No link in graph")
        }
    }
    
    func testRemoveConnection() throws {
        let graph = Graph()
        let a = Node()
        graph.add(a)
        let b = Node()
        graph.add(b)
        
        var link = graph.connect(from: a, to: b)
        
        XCTAssertEqual(graph.links.count, 1)
        graph.disconnect(link: link)
        XCTAssertEqual(graph.links.count, 0)
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

        let link1 = graph.connect(from: a, to: b, labels: ["child", "one"])
        let link2 = graph.connect(from: a, to: c, labels: ["child", "two"])

        XCTAssertEqual(graph.outgoing(a).count, 2)
        XCTAssertEqual(graph.outgoing(b).count, 0)
        XCTAssertEqual(graph.outgoing(c).count, 0)

        XCTAssertEqual(graph.incoming(a).count, 0)
        XCTAssertEqual(graph.incoming(b).count, 1)
        XCTAssertEqual(graph.incoming(c).count, 1)

        let links = graph.outgoing(a)
        XCTAssertEqual(Set([link1, link2]), Set(links))
    }

    func testRemoveLinkWithNodeRemoval() throws {
        let graph = Graph()
        let a = Node()
        let b = Node()
        graph.add(a)
        graph.add(b)

        let link = graph.connect(from: a, to: b)

        let removed = graph.remove(a)
        XCTAssertEqual(graph.links.count, 0)
        XCTAssertEqual(removed.count, 1)
        if let first = removed.first {
            XCTAssertIdentical(link, first)
        }
        else {
            XCTFail("There should be exactly one removed link")
        }
    }

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
