import XCTest
@testable import Holon

final class HolonTests: XCTestCase {
    let graph = Graph()
    
    func testGetHolons() throws {
        let holon = Node(role: .holon)
        graph.add(holon)
        
        XCTAssertEqual(graph.topLevelHolons.count, 1)
        XCTAssertEqual(graph.allHolons.count, 1)
        
        if let first = graph.topLevelHolons.first {
            XCTAssertIdentical(first, holon)
        }
        else {
            XCTFail("Graph is expected to return the holon added to it")
        }
    }
    
    func testGetChildren() throws {
        let outer = Node(role: .holon)
        let inner = Node(role: .holon)
        
        graph.add(outer)
        outer.add(inner)
        
        XCTAssertEqual(graph.allHolons.count, 2)
        
        XCTAssertEqual(graph.topLevelHolons.count, 1)
        if let first = graph.topLevelHolons.first {
            XCTAssertIdentical(first, outer)
        }
        else {
            XCTFail("Graph is expected to own only the outer holon")
        }
        
        XCTAssertEqual(outer.allHolons.count, 1)
        XCTAssertEqual(outer.childHolons.count, 1)
        if let first = outer.childHolons.first {
            XCTAssertIdentical(first, inner)
        }
        else {
            XCTFail("Outer should own only the inner holon")
        }
        
        XCTAssertEqual(inner.childHolons.count, 0)
    }
    
    func testRemoveHolon() throws {
        let outer = Node(role: .holon)
        let inner = Node(role: .holon)
        let outerNode = Node()
        let innerNode = Node()
        
        graph.add(outer)
        outer.add(inner)
        outer.add(outerNode)
        inner.add(innerNode)
        
        let removed = graph.removeHolon(outer)
        
        XCTAssertEqual(removed.links.count, 3)
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
        // Graph:
        //
        // outer(h) -h-> inner(h) -h-> inner
        //          -h-> outer
        //
        
        let outer = Node(role: .holon)
        let inner = Node(role: .holon)
        let outerNode = Node()
        let innerNode = Node()

        graph.add(outer)
        outer.add(inner)
        outer.add(outerNode)
        inner.add(innerNode)

        XCTAssertIdentical(inner.holon, outer)
        XCTAssertIdentical(innerNode.holon, inner)
        XCTAssertIdentical(outerNode.holon, outer)

        let (removed, created) = graph.dissolveHolon(outer)
        XCTAssertEqual(removed.count, 0)
        XCTAssertEqual(created.count, 0)

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
        let outer = Node(role: .holon)
        let inner = Node(role: .holon)
        let node = Node()
        
        graph.add(outer)
        outer.add(inner)
        inner.add(node)
        
        XCTAssertFalse(outer.contains(node: node))
        XCTAssertTrue(inner.contains(node: node))
    }
}

final class HolonConstraintsTests: XCTestCase, ConstraintTestProtocol {
    var graph: Graph!
    var checker: ConstraintChecker!
    var strictChecker: ConstraintChecker!
    
    override func setUp() {
        graph = Graph()
        checker = ConstraintChecker(constraints: HolonConstraint.All)
        strictChecker = ConstraintChecker(constraints: StrictHolonConstraint.All)
    }
    
    func testSanity() throws {
        let holon = Node(role:.holon)
        let node = Node()
        graph.add(holon)
        graph.add(node)
        graph.connect(node: node, holon: holon)

        assertNoViolation()
    }
    func testSingleParentHolon() throws {
        let holon = Node(role:.holon)
        let node = Node()
        graph.add(holon)
        graph.add(node)
        graph.connect(from: node, to: holon, labels: [HolonLabel.HolonLink])
        graph.connect(from: node, to: holon, labels: [HolonLabel.HolonLink])

        assertConstraintViolation("single_parent_holon")
    }

}
