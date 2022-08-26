import XCTest
@testable import Holon

final class HolonTests: XCTestCase {
    let graph = Graph()

    func testGetHolons() throws {
        let holon = Holon()
        graph.add(holon)
        
        XCTAssertEqual(graph.holons.count, 1)
        XCTAssertEqual(graph.allHolons.count, 1)

        if let first = graph.holons.first {
            XCTAssertIdentical(first, holon)
        }
        else {
            XCTFail("Graph is expected to return the holon added to it")
        }
    }
    
    func testGetChildren() throws {
        let outer = Holon()
        let inner = Holon()
        
        graph.add(outer)
        outer.add(inner)

        XCTAssertEqual(graph.allHolons.count, 2)
        
        XCTAssertEqual(graph.holons.count, 1)
        if let first = graph.holons.first {
            XCTAssertIdentical(first, outer)
        }
        else {
            XCTFail("Graph is expected to own only the outer holon")
        }

        XCTAssertEqual(outer.allHolons.count, 1)
        XCTAssertEqual(outer.holons.count, 1)
        if let first = outer.holons.first {
            XCTAssertIdentical(first, inner)
        }
        else {
            XCTFail("Outer should own only the inner holon")
        }

        XCTAssertEqual(inner.holons.count, 0)
    }
    
    func testRemoveHolon() throws {
        let outer = Holon()
        let inner = Holon()
        let outerNode = Node()
        let innerNode = Node()

        graph.add(outer)
        outer.add(inner)
        outer.add(outerNode)
        inner.add(innerNode)
        
        let removed = graph.remove(outer)
        
        XCTAssertEqual(removed.links.count, 0)
        XCTAssertEqual(removed.nodes.count, 3)

        XCTAssertNil(outer.graph)
        XCTAssertNil(outer.holon)
        XCTAssertNil(inner.graph)
        XCTAssertNil(inner.holon)
        XCTAssertNil(outerNode.graph)
        XCTAssertNil(outerNode.holon)
        XCTAssertNil(innerNode.graph)
        XCTAssertNil(innerNode.holon)
    }
    
    func testDissolveHolon() throws {
        let outer = Holon()
        let inner = Holon()
        let outerNode = Node()
        let innerNode = Node()

        graph.add(outer)
        outer.add(inner)
        outer.add(outerNode)
        inner.add(innerNode)
        
        XCTAssertIdentical(inner.holon, outer)
        XCTAssertIdentical(innerNode.holon, inner)
        XCTAssertIdentical(outerNode.holon, outer)

        let removed = graph.dissolve(outer)
        XCTAssertEqual(removed.links.count, 0)
        XCTAssertEqual(removed.nodes.count, 0)

        XCTAssertNil(outer.graph)
        XCTAssertNil(outer.holon)

        XCTAssertIdentical(outerNode.graph, graph)
        XCTAssertNil(outer.holon)

        XCTAssertIdentical(inner.graph, graph)
        XCTAssertNil(inner.holon)

        XCTAssertIdentical(innerNode.graph, graph)
        XCTAssertIdentical(innerNode.holon, inner)
    }

    func testOwnership() throws {
        let outer = Holon()
        let inner = Holon()
        let node = Node()

        graph.add(outer)
        outer.add(inner)
        inner.add(node)

        XCTAssertFalse(outer.contains(node: node))
        XCTAssertTrue(inner.contains(node: node))
    }

//    func testPorts() throws {
//        let outer = Graph()
//        let inner = Graph()
//        outer.add(inner)
//
//        let a = Node()
//        outer.add(a)
//        let b = Node()
//        inner.add(b)
//
//        let port = Port(b)
//        inner.add(port)
//
//
//        let link = outer.connect(from: a, to: port)
//
//        XCTAssertIdentical(link.origin, a)
//        XCTAssertIdentical(link.target, b)
//
//
//    }
}
