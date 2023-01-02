//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//

import XCTest
@testable import HolonKit

final class NodeIndirectionTests: XCTestCase {
    var graph: Graph = Graph()

    func testIsProxy() throws {
        let regular = Node(labels: ["regular"])
        let proxy = Node(labels: ["proxy"], role: .proxy)
        
        XCTAssertFalse(regular.isProxy)
        XCTAssertTrue(proxy.isProxy)
    }
    
    func testSubjectEdge() throws {
        let target = Node(labels: ["target"])
        let proxy1 = Node(labels: ["proxy1"], role: .proxy)
        let proxy2 = Node(labels: ["proxy2"], role: .proxy)

        graph.add(target)
        graph.add(proxy1)
        graph.add(proxy2)

        graph.add(Edge(origin: proxy1.id, target: target.id))
        let edge2 = graph.connect(proxy: proxy2.id, representing: target.id)

        XCTAssertNil(graph.subjectEdge(target.id))
        XCTAssertNil(graph.subjectEdge(proxy1.id))
        XCTAssertIdentical(graph.subjectEdge(proxy2.id), edge2)

    }
    
    func testRealSubjectPath() throws {
        let target = Node(labels: ["target"])
        let proxy1 = Node(labels: ["proxy1"], role: .proxy)
        let proxy2 = Node(labels: ["proxy2"], role: .proxy)

        graph.add(target)
        graph.add(proxy1)
        graph.add(proxy2)

        let edge2 = graph.connect(proxy: proxy2.id,
                                  representing: target.id)
        let edge1 = graph.connect(proxy: proxy1.id,
                                  representing: proxy2.id,
                                  labels: [IndirectionLabel.IndirectTarget])

        let path1 = graph.realSubjectPath(proxy1)
        XCTAssertEqual(path1.edges.map {$0.id}, [edge1.id, edge2.id])

        let path2 = graph.realSubjectPath(proxy2)
        XCTAssertEqual(path2.edges.map {$0.id}, [edge2.id])
    }
    func testRealSubjectPathInterrupted() throws {
        let target = Node(labels: ["target"])
        let proxy1 = Node(labels: ["proxy1"], role: .proxy)
        let proxy2 = Node(labels: ["proxy2"], role: .proxy)

        graph.add(target)
        graph.add(proxy1)
        graph.add(proxy2)

        let edge2 = graph.connect(proxy: proxy2.id, representing: target.id)
        // Note: This is direct edge, it should not be followed further
        let edge1 = graph.connect(proxy: proxy1.id, representing: proxy2.id)

        let path1 = graph.realSubjectPath(proxy1)
        XCTAssertEqual(path1.edges.map {$0.id}, [edge1.id])

        let path2 = graph.realSubjectPath(proxy2)
        XCTAssertEqual(path2.edges.map {$0.id}, [edge2.id])
    }


}

final class IndirectionRewriterTests: XCTestCase {
    // FIXME: Use graph
    var graph: Graph!
    var rewriter: IndirectionRewriter!
    
    override func setUp() {
        graph = Graph()
        rewriter = IndirectionRewriter()
    }
    
    func testDoNothing() throws {
        let node = Node()
        graph.add(node)
        graph.add(Edge(origin: node.id, target: node.id))
        
        let new = graph.copy()
        rewriter.rewrite(new)
        
        XCTAssertEqual(new.nodeIDs, graph.nodeIDs)
        XCTAssertEqual(new.edgeIDs, graph.edgeIDs)
    }
    
    func testResolveProxy() throws {
        // FROM:
        //     origin --> proxy -s-> target
        // TO:
        //     origin -> target
        //
        
        let origin = Node(labels: ["origin"])
        let proxy = Node(role: .proxy)
        let target = Node(labels: ["target"])
        
        graph.add(origin)
        graph.add(proxy)
        graph.add(target)

        graph.connect(proxy: proxy.id, representing: target.id)
        
        let indirectEdge = graph.connect(from: origin,
                                         to: proxy,
                                         labels: [IndirectionLabel.IndirectTarget],
                                         id: 1)

        let new = graph.copy()
        rewriter.rewrite(new)
        
        let edge = new.edge(indirectEdge.id)!
        XCTAssertEqual(edge.origin, origin.id)
        XCTAssertEqual(edge.target, target.id)

        // There must be no indirect edges left
        XCTAssertFalse(new.edges.contains(where: { $0.isIndirect}))
    }
    
    /// Resolve indirection of two edges between the same proxies
    func testResolveProxyTwoEdges() throws {
        // FROM:
        //     origin -1-> proxy -s-> target
        //     origin -2-> proxy -s-> target
        // TO:
        //     origin -1-> target
        //     origin -2-> target
        //
        
        let origin = Node(labels: ["origin"])
        let proxy = Node(role: .proxy)
        let target = Node(labels: ["target"])
        
        graph.add(origin)
        graph.add(proxy)
        graph.add(target)

        graph.connect(proxy: proxy.id, representing: target.id)
        
        let indirect1 = graph.connect(from: origin,
                                      to: proxy,
                                      labels: [IndirectionLabel.IndirectTarget, "one"],
                                      id: 1)
        let indirect2 = graph.connect(from: origin,
                                      to: proxy,
                                      labels: [IndirectionLabel.IndirectTarget, "two"],
                                      id: 2)

        let new = graph.copy()
        rewriter.rewrite(new)
        
        let edge1 = new.edge(indirect1.id)!
        XCTAssertEqual(edge1.origin, origin.id)
        XCTAssertEqual(edge1.target, target.id)
        XCTAssertEqual(edge1.labels, ["one"])

        let edge2 = new.edge(indirect2.id)!
        XCTAssertEqual(edge2.origin, origin.id)
        XCTAssertEqual(edge2.target, target.id)
        XCTAssertEqual(edge2.labels, ["two"])
    }
    
    func testResolveProxyHop() throws {
        // FROM:
        //     origin --> proxy1 -s-> proxy2 -s-> target
        // TO:
        //     origin -> target
        //
        let origin = Node(labels: ["origin"])
        let target = Node(labels: ["target"])
        let proxy1 = Node(labels: ["proxy1"], role: .proxy)
        let proxy2 = Node(labels: ["proxy2"], role: .proxy)

        graph.add(origin)
        graph.add(target)
        graph.add(proxy1)
        graph.add(proxy2)

        graph.connect(proxy: proxy2.id, representing: target.id)
        graph.connect(proxy: proxy1.id, representing: proxy2.id, labels: [IndirectionLabel.IndirectTarget])

        let indirectEdge = graph.connect(from: origin,
                                         to: proxy1,
                                         labels: [IndirectionLabel.IndirectTarget],
                                         id: 1)

        let new = graph.copy()
        rewriter.rewrite(new)
        
        let edge = new.edge(indirectEdge.id)!
        XCTAssertEqual(edge.origin, origin.id)
        XCTAssertEqual(edge.target, target.id)
        // There must be no indirect edges left that are not subjects
        XCTAssertFalse(new.edges.contains(where: { $0.isIndirect && !$0.isSubject}))
    }
    func testDontResolveProxyHop() throws {
        // FROM:
        //     origin --> proxy1 -s-> proxy2 --> target
        // TO:
        //     origin -> proxy2
        //
        let origin = Node(labels: ["origin"])
        let target = Node(labels: ["target"])
        let proxy1 = Node(labels: ["proxy1"], role: .proxy)
        let proxy2 = Node(labels: ["proxy2"], role: .proxy)

        graph.add(origin)
        graph.add(target)
        graph.add(proxy1)
        graph.add(proxy2)

        graph.connect(proxy: proxy2.id, representing: target.id)
        graph.connect(proxy: proxy1.id, representing: proxy2.id)

        let indirectEdge = graph.connect(from: origin,
                                         to: proxy1,
                                         labels: [IndirectionLabel.IndirectTarget],
                                         id: 1)

        let new = graph.copy()
        rewriter.rewrite(new)
        let edge = new.edge(indirectEdge.id)!
        XCTAssertEqual(edge.origin, origin.id)
        XCTAssertEqual(edge.target, proxy2.id)
        // There must be no indirect edges left
        XCTAssertFalse(new.edges.contains(where: { $0.isIndirect}))
    }
    
    func testRewriteTransform() throws {
        //
        // node(x, uses: "y") <---i- proxy(name: "y") --s--> node(name: "a")
        //
        // Test to get a value from within a holon
        let nodeX = Node(labels: ["x", "usesY"])
        let proxy = Node(labels: ["y"], role: .proxy)
        let nodeA = Node(labels: ["a"])
        
        graph.add(nodeX)
        graph.add(proxy)
        graph.add(nodeA)
        
        graph.connect(proxy: proxy.id, representing: nodeA.id)
        let originalEdge = graph.connect(from: proxy,
                                         to: nodeX,
                                         labels: [IndirectionLabel.IndirectOrigin])

        let new = graph.copy()
        let rewriter = IndirectionRewriter {
            context in
            context.proposed.set(label: "aliasY")
            self.graph.node(context.proposed.origin)!.set(label: "aliasY")
            return nil
        }

        rewriter.rewrite(new)
        
        let incoming = new.edge(originalEdge.id)!
        let newA = new.node(nodeA.id)!
        let newX = new.node(nodeX.id)!

        XCTAssertEqual(incoming.target, newX.id)
        XCTAssertTrue(incoming.contains(label: "aliasY"))

        XCTAssertEqual(incoming.origin, newA.id)
        XCTAssertTrue(newA.contains(label: "aliasY"))
    }
    func testRewriteReplaceProposedEdge() throws {
        let nodeX = Node(labels: ["x"])
        let proxy = Node(labels: ["y"], role: .proxy)
        let nodeA = Node(labels: ["a"])
        
        graph.add(nodeX)
        graph.add(proxy)
        graph.add(nodeA)
        
        graph.connect(proxy: proxy.id, representing: nodeA.id)
        let originalEdge = graph.connect(from: proxy,
                                         to: nodeX,
                                         labels: [IndirectionLabel.IndirectOrigin])

        let rewriter = IndirectionRewriter {
            context in
            return Edge(origin: context.proposed.origin,
                        target: context.proposed.target,
                        labels: ["somethingNew"],
                        id: 1000)
        }
        let new = graph.copy()
        rewriter.rewrite(new)
        XCTAssertNil(new.edge(originalEdge.id))

        let edge = new.edge(1000)!

        XCTAssertEqual(edge.labels, ["somethingNew"])
        XCTAssertEqual(edge.id, 1000)
    }

}

final class IndirectionConstraintsTests: XCTestCase, ConstraintTestProtocol {
    var graph: Graph!
    var checker: ConstraintChecker!
    var strictChecker: ConstraintChecker!
    
    override func setUp() {
        graph = Graph()
        checker = ConstraintChecker(constraints: IndirectionConstraint.All)
    }
    
    func testSanity() throws {
        let origin = Node()
        let originProxy = Node(role:.proxy)
        let targetProxy = Node(role:.proxy)
        let target = Node()
        graph.add(origin)
        graph.add(target)
        graph.add(originProxy)
        graph.add(targetProxy)

        graph.connect(proxy: originProxy.id, representing: origin.id)
        graph.connect(proxy: targetProxy.id, representing: target.id)
        assertNoViolation()
    }
    func testProxySingleSubject() throws {
        let node = Node()
        let other = Node()
        let proxy = Node(role:.proxy)
        graph.add(node)
        graph.add(other)
        graph.add(proxy)

        // No subject here
        assertConstraintViolation("proxy_has_single_subject")

        // Just right
        graph.connect(from: proxy, to: node, labels: [IndirectionLabel.Subject])
        assertNoViolation()

        // Too many subjects here
        graph.connect(from: proxy, to: node, labels: [IndirectionLabel.Subject])
        assertConstraintViolation("proxy_has_single_subject")
    }
    
    func testSubjectEdgeOriginIsProxy() throws {
        let node = Node()
        let other = Node()
        graph.add(node)
        graph.add(other)

        graph.connect(from: node, to: other, labels: [IndirectionLabel.Subject])
        assertConstraintViolation("subject_edge_origin_is_direct_proxy")
    }
    
    func testSubjectIndirectEndpointIsProxy() throws {
        let origin = Node()
        let target = Node()
        let bogus = Node()
        
        graph.add(origin)
        graph.add(target)
        graph.add(bogus)
        
        let originEdge = graph.connect(from: origin,
                                       to: target,
                                       labels: [IndirectionLabel.IndirectOrigin])
        assertConstraintViolation("indirect_origin_is_proxy")

        graph.remove(edge: originEdge.id)
        graph.connect(from: origin,
                        to: target,
                    labels: [IndirectionLabel.IndirectTarget])
        assertConstraintViolation("indirect_target_is_proxy")
    }
    
}
