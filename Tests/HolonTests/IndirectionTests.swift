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
        let proxy = Proxy()
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
        let proxy1 = Proxy(labels: ["proxy1"])
        let proxy2 = Proxy(labels: ["proxy2"])

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
        let proxy1 = Proxy(labels: ["proxy1"])
        let proxy2 = Proxy(labels: ["proxy2"])

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

