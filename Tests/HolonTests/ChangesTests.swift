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

    func testRemoveNodeWithLinksChange() throws {
        let graph = Graph()
        let node = Node()
        let change: GraphChange = .removeNode(node)
        
        graph.add(node)
        let link = graph.connect(from: node, to: node)

        let revert = graph.applyChange(change)
        
        XCTAssertTrue(graph.nodes.isEmpty)
        XCTAssertTrue(graph.links.isEmpty)
        XCTAssertEqual(revert, [.addNode(node), .addLink(link)])
    }

    func testAddLinkChange() throws {
        let graph = Graph()
        let node = Node()
        graph.add(node)
        let link = Link(origin: node, target: node)
        let change: GraphChange = .addLink(link)
        
        let revert = graph.applyChange(change)
        
        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertEqual(graph.links.count, 1)
        XCTAssertEqual(revert, [.removeLink(link)])
    }

    func testRemoveLinkChange() throws {
        let graph = Graph()
        let node = Node()
        graph.add(node)
        let link = Link(origin: node, target: node)
        graph.add(link)
        
        let change: GraphChange = .removeLink(link)
        
        let revert = graph.applyChange(change)
        
        XCTAssertEqual(graph.nodes.count, 1)
        XCTAssertEqual(graph.links.count, 0)
        XCTAssertEqual(revert, [.addLink(link)])
    }
}
