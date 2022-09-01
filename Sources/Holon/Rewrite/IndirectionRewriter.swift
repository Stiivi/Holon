//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 29/08/2022.
//


/// A graph rewriter that rewrites indirect links into direct links.
///
/// See ``IndirectionRewriter/rewrite()`` for more information about the
/// process.
///
public class IndirectionRewriter {
    public let graph: Graph
    
    /// Creates a view for a graph where all of the indirect links will be
    /// resolved to direct links. Link ID of the resolved link is the same as
    /// the link ID of the indirect link.
    /// 
    public init(_ graph: Graph) {
        self.graph = graph
    }
    
    
    /// Returns a new graph created by rewriting the original graph. The new
    /// graph will have indirect links rewritten into direct links. All proxy
    /// node will be removed as well.
    ///
    /// - Note: To successfully rewrite the indirections, the graph must fulfil
    ///   indirection constraints. See ``IndirectionConstraints`` for more
    ///   information.
    ///
    public func rewrite() -> Graph {
        // FIXME: New links have no ID
        // Nodes without ports
        let graph = self.graph.copy()

        // Get all indirect links to rewrite
        var rewriteLinks = Set(graph.links.filter { $0.isIndirect })
        
        while !rewriteLinks.isEmpty {
            // Take a link (any)
            let link = rewriteLinks.popFirst()!
            
            var origin: Node?
            var target: Node?
            var labels = link.labels

            // Indirect endpoint – for both origin and target do:
            // 1. Expect the endpoint to be a proxy -> otherwise error
            // 2. Get a proxy subject link. MUST exist
            // 3. Endpoint will be target of the subject link
            // 4. If either of the endpoints was indirect, then the new link
            //    will be marked as indirect and placed back to the rewrite list
            
            // Whether to follow the link again
            var followAgain: Bool = false
            if link.hasIndirectOrigin {
                let proxy = link.origin
                guard proxy.isProxy else {
                    fatalError("Indirect origin must be a proxy")
                }
                guard let subjectLink = proxy.subjectLink else {
                    fatalError("Proxy must have a subject link")
                }
                origin = subjectLink.target
                
                if subjectLink.target.isProxy && subjectLink.isIndirect {
                    followAgain = true
                }
                else {
                    labels.remove(Link.IndirectOriginLabel)
                }
            }

            if link.hasIndirectTarget {
                let proxy = link.target
                guard proxy.isProxy else {
                    fatalError("Indirect origin must be a proxy")
                }
                guard let subjectLink = proxy.subjectLink else {
                    fatalError("Proxy must have a represented node")
                }
                target = subjectLink.target
                
                if subjectLink.target.isProxy && subjectLink.isIndirect {
                    followAgain = true
                }
                else {
                    labels.remove(Link.IndirectTargetLabel)
                }
            }
            // FIXME: What about the link ID?
            graph.disconnect(link: link)
            let newLink = graph.connect(from: origin ?? link.origin,
                                        to: target ?? link.target,
                                        labels: labels,
                                        id: link.id)

            if followAgain {
                rewriteLinks.insert(newLink)
            }
        }
        
        return graph
    }
}
