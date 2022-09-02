//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//

import XCTest
@testable import Holon

final class NodeIndirectionTests: XCTestCase {
    let graph: Graph = Graph()

    func testIsProxy() throws {
        let regular = Node(labels: ["regular"])
        let proxy = Node(labels: ["proxy"], role: .proxy)
        
        XCTAssertFalse(regular.isProxy)
        XCTAssertTrue(proxy.isProxy)
    }
    
    func testSubjectLink() throws {
        let target = Node(labels: ["target"])
        let proxy1 = Node(labels: ["proxy1"], role: .proxy)
        let proxy2 = Node(labels: ["proxy2"], role: .proxy)

        graph.add(target)
        graph.add(proxy1)
        graph.add(proxy2)

        graph.connect(from: proxy1, to: target)
        let link2 = graph.connect(proxy: proxy2, representing: target)

        XCTAssertNil(target.subjectLink)
        XCTAssertNil(proxy1.subjectLink)
        XCTAssertIdentical(proxy2.subjectLink, link2)

    }
    
    func testRealSubjectPath() throws {
        let target = Node(labels: ["target"])
        let proxy1 = Node(labels: ["proxy1"], role: .proxy)
        let proxy2 = Node(labels: ["proxy2"], role: .proxy)

        graph.add(target)
        graph.add(proxy1)
        graph.add(proxy2)

        let link2 = graph.connect(proxy: proxy2, representing: target)
        let link1 = graph.connect(proxy: proxy1, representing: proxy2, labels: [IndirectionLabel.IndirectTarget])

        let path1 = proxy1.realSubjectPath()
        XCTAssertEqual(path1.links, [link1, link2])

        let path2 = proxy2.realSubjectPath()
        XCTAssertEqual(path2.links, [link2])
    }
    func testRealSubjectPathInterrupted() throws {
        let target = Node(labels: ["target"])
        let proxy1 = Node(labels: ["proxy1"], role: .proxy)
        let proxy2 = Node(labels: ["proxy2"], role: .proxy)

        graph.add(target)
        graph.add(proxy1)
        graph.add(proxy2)

        let link2 = graph.connect(proxy: proxy2, representing: target)
        // Note: This is direct link, it should not be followed further
        let link1 = graph.connect(proxy: proxy1, representing: proxy2)

        let path1 = proxy1.realSubjectPath()
        XCTAssertEqual(path1.links, [link1])

        let path2 = proxy2.realSubjectPath()
        XCTAssertEqual(path2.links, [link2])
    }


}

final class IndirectionRewriterTests: XCTestCase {
    var graph: Graph!
    var rewriter: IndirectionRewriter!
    
    override func setUp() {
        graph = Graph()
        rewriter = IndirectionRewriter(graph)
    }
    
    func testDoNothing() throws {
        let node = Node()
        graph.add(node)
        graph.connect(from: node, to: node)
        
        let new = rewriter.rewrite()
        
        XCTAssertEqual(new.nodes, graph.nodes)
        XCTAssertEqual(new.links, graph.links)
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

        graph.connect(proxy: proxy, representing: target)
        
        let indirectLink = graph.connect(from: origin,
                                         to: proxy,
                                         labels: [IndirectionLabel.IndirectTarget],
                                         id: 1)

        let new = rewriter.rewrite()
        
        let link = new.link(indirectLink.id)!
        XCTAssertEqual(link.origin, origin)
        XCTAssertEqual(link.target, target)

        // There must be no indirect links left
        XCTAssertFalse(new.links.contains(where: { $0.isIndirect}))
    }
    
    /// Resolve indirection of two links between the same proxies
    func testResolveProxyTwoLinks() throws {
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

        graph.connect(proxy: proxy, representing: target)
        
        let indirect1 = graph.connect(from: origin,
                                      to: proxy,
                                      labels: [IndirectionLabel.IndirectTarget, "one"],
                                      id: 1)
        let indirect2 = graph.connect(from: origin,
                                      to: proxy,
                                      labels: [IndirectionLabel.IndirectTarget, "two"],
                                      id: 2)

        let new = rewriter.rewrite()
        
        let link1 = new.link(indirect1.id)!
        XCTAssertEqual(link1.origin, origin)
        XCTAssertEqual(link1.target, target)
        XCTAssertEqual(link1.labels, ["one"])

        let link2 = new.link(indirect2.id)!
        XCTAssertEqual(link2.origin, origin)
        XCTAssertEqual(link2.target, target)
        XCTAssertEqual(link2.labels, ["two"])
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

        graph.connect(proxy: proxy2, representing: target)
        graph.connect(proxy: proxy1, representing: proxy2, labels: [IndirectionLabel.IndirectTarget])

        let indirectLink = graph.connect(from: origin,
                                         to: proxy1,
                                         labels: [IndirectionLabel.IndirectTarget],
                                         id: 1)

        let new = rewriter.rewrite()
        let link = new.link(indirectLink.id)!
        XCTAssertEqual(link.origin, origin)
        XCTAssertEqual(link.target, target)
        // There must be no indirect links left that are not subjects
        XCTAssertFalse(new.links.contains(where: { $0.isIndirect && !$0.isSubject}))
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

        graph.connect(proxy: proxy2, representing: target)
        graph.connect(proxy: proxy1, representing: proxy2)

        let indirectLink = graph.connect(from: origin,
                                         to: proxy1,
                                         labels: [IndirectionLabel.IndirectTarget],
                                         id: 1)

        let new = rewriter.rewrite()
        let link = new.link(indirectLink.id)!
        XCTAssertEqual(link.origin, origin)
        XCTAssertEqual(link.target, proxy2)
        // There must be no indirect links left
        XCTAssertFalse(new.links.contains(where: { $0.isIndirect}))
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
        
        graph.connect(proxy: proxy, representing: nodeA)
        let originalLink = graph.connect(from: proxy,
                                         to: nodeX,
                                         labels: [IndirectionLabel.IndirectOrigin])

        let new = rewriter.rewrite() {
            context in
            context.proposed.set(label: "aliasY")
            context.proposed.origin.set(label: "aliasY")
            return nil
        }

        let incoming = new.link(originalLink.id)!
        let newA = new.node(nodeA.id)!
        let newX = new.node(nodeX.id)!

        XCTAssertIdentical(incoming.target, newX)
        XCTAssertTrue(incoming.contains(label: "aliasY"))

        XCTAssertIdentical(incoming.origin, newA)
        XCTAssertTrue(newA.contains(label: "aliasY"))
    }
    func testRewriteReplaceProposedLink() throws {
        let nodeX = Node(labels: ["x"])
        let proxy = Node(labels: ["y"], role: .proxy)
        let nodeA = Node(labels: ["a"])
        
        graph.add(nodeX)
        graph.add(proxy)
        graph.add(nodeA)
        
        graph.connect(proxy: proxy, representing: nodeA)
        let originalLink = graph.connect(from: proxy,
                                         to: nodeX,
                                         labels: [IndirectionLabel.IndirectOrigin])

        let new = rewriter.rewrite() {
            context in
            return Link(origin: context.proposed.origin,
                        target: context.proposed.target,
                        labels: ["somethingNew"],
                        id: 1000)
        }

        XCTAssertNil(new.link(originalLink.id))

        let link = new.link(1000)!

        XCTAssertEqual(link.labels, ["somethingNew"])
        XCTAssertEqual(link.id, 1000)
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

        graph.connect(proxy: originProxy, representing: origin)
        graph.connect(proxy: targetProxy, representing: target)
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
    
    func testSubjectLinkOriginIsProxy() throws {
        let node = Node()
        let other = Node()
        graph.add(node)
        graph.add(other)

        graph.connect(from: node, to: other, labels: [IndirectionLabel.Subject])
        assertConstraintViolation("subject_link_origin_is_direct_proxy")
    }
    
    func testSubjectIndirectEndpointIsProxy() throws {
        let origin = Node()
        let target = Node()
        let bogus = Node()
        
        graph.add(origin)
        graph.add(target)
        graph.add(bogus)
        
        let originLink = graph.connect(from: origin,
                                       to: target,
                                       labels: [IndirectionLabel.IndirectOrigin])
        assertConstraintViolation("indirect_origin_is_proxy")

        graph.disconnect(link: originLink)
        graph.connect(from: origin,
                        to: target,
                    labels: [IndirectionLabel.IndirectTarget])
        assertConstraintViolation("indirect_target_is_proxy")
    }
    
}
