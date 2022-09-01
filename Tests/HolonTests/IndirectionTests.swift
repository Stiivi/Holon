//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//

import XCTest
@testable import Holon

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
                                         labels: [Link.IndirectTargetLabel],
                                         id: 1)

        let new = rewriter.rewrite()
        
        let link = new.link(indirectLink.id)!
        XCTAssertEqual(link.origin, origin)
        XCTAssertEqual(link.target, target)

        // There must be no indirect links left
        XCTAssertFalse(new.links.contains(where: { $0.isIndirect}))
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
        graph.connect(proxy: proxy1, representing: proxy2, labels: [Link.IndirectTargetLabel])

        let indirectLink = graph.connect(from: origin,
                                         to: proxy1,
                                         labels: [Link.IndirectTargetLabel],
                                         id: 1)

        let new = rewriter.rewrite()
        let link = new.link(indirectLink.id)!
        XCTAssertEqual(link.origin, origin)
        XCTAssertEqual(link.target, target)
        // There must be no indirect links left
        XCTAssertFalse(new.links.contains(where: { $0.isIndirect}))
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
                                         labels: [Link.IndirectTargetLabel],
                                         id: 1)

        let new = rewriter.rewrite()
        let link = new.link(indirectLink.id)!
        XCTAssertEqual(link.origin, origin)
        XCTAssertEqual(link.target, proxy2)
        // There must be no indirect links left
        XCTAssertFalse(new.links.contains(where: { $0.isIndirect}))
    }

}

final class IndirectionConstraintsTests: XCTestCase, ConstraintTestProtocol {
    var graph: Graph!
    var checker: ConstraintChecker!
    var strictChecker: ConstraintChecker!
    
    override func setUp() {
        graph = Graph()
        checker = ConstraintChecker(constraints: IndirectionConstraints)
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
        assertConstraintViolation("proxy_single_subject")

        // Just right
        graph.connect(from: proxy, to: node, labels: [Link.SubjectLabel])
        assertNoViolation()

        // Too many subjects here
        graph.connect(from: proxy, to: node, labels: [Link.SubjectLabel])
        assertConstraintViolation("proxy_single_subject")
    }
    
    func testSubjectLinkOriginIsProxy() throws {
        let node = Node()
        let other = Node()
        let proxy = Node(role:.proxy)
        graph.add(node)
        graph.add(other)
        graph.add(proxy)

        graph.connect(from: node, to: other, labels: [Link.SubjectLabel])
        assertConstraintViolations(["subject_link_origin_is_proxy",
                                    "proxy_single_subject"])

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
                                       labels: [Link.IndirectOriginLabel])
        assertConstraintViolation("indirect_origin_is_proxy")

        graph.disconnect(link: originLink)
        graph.connect(from: origin,
                        to: target,
                    labels: [Link.IndirectTargetLabel])
        assertConstraintViolation("indirect_target_is_proxy")
    }
}
