//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 29/08/2022.
//


/// A graph rewriter that rewrites indirect links into direct links.
///
/// See ``IndirectionRewriter/rewrite(transform:)`` for more information about the
/// process.
///
public class IndirectionRewriter {
    public let graph: Graph
   
    /// Rewriting context that is passed to the caller to allow adjustments
    /// of the newly created link.
    ///
    public struct Context {
        /// The link that is being replaced. This object will be disassociated
        /// from the graph.
        ///
        let replaced: Link

        /// Link to the subject of the origin, if the origin was indirect.
        /// It is `nil` if the origin was direct.
        let originSubjectLink: Link?

        /// Link to the subject of the target, if the target was indirect.
        /// It is `nil` if the target was direct.
        let targetSubjectLink: Link?
        
        /// Subject of the origin, if the origin was indirect.
        /// It is `nil` if the origin was direct.
        var originSubject: Node? { originSubjectLink?.target }

        /// Subject of the target, if the target was indirect.
        /// It is `nil` if the target was direct.
        var targetSubject: Node? { targetSubjectLink?.target }
        
        /// Link that is proposed to be created. The caller might modify
        /// the proposed link or create a new one. If a new link is created,
        /// then the proposed link will be disposed.
        var proposed: Link
        
        /// Flag whether the link replacement is final for the proposed link.
        ///
        let isFinal: Bool
    }
    
    /// Creates a view for a graph where all of the indirect links will be
    /// resolved to direct links. Link ID of the resolved link is the same as
    /// the link ID of the indirect link.
    /// 
    public init(_ graph: Graph) {
        self.graph = graph
    }
    
    
    /// Returns a new graph created by rewriting the original graph. The new
    /// graph will have indirect links rewritten into direct links.
    ///
    ///
    /// The algorithm is as follows:
    ///
    /// ```markdown
    /// 1. SET `to rewrite` TO all indirect links that are not subject links
    /// 2. WHILE there is a link in `to rewrite`  DO:
    ///     1. POP a link from `to rewrite`
    ///     2. FOR EACH indirect endpoint IN (origin, target) of the link:
    ///         1. ASSERT that the endpoint IS a proxy
    ///         2. GET subject link of the endpoint
    ///         3. SET new endpoint = target of subject link
    ///         4. IF subject link is indirect:
    ///             - PUT the link back to the `to rewrite` set
    ///     3. DISCONNECT the link
    ///     4. YIELD to caller to adjust the newly proposed link
    ///     5. CREATE new link between the new endpoints
    /// ```
    ///
    /// To better visualise the algorithm, think of the indirect link as a
    /// stick, where on each of the indirect endpoint there is a string of subject
    /// links attached to it. Hold the stick horizontally with strings hanging
    /// down. Now roll the stick so the hanging strings will be winded up on the
    /// stick until they reach the end. When the strings are fully wound we
    /// have a direct link – no proxies are dangling any more.
    ///
    ///
    /// ```
    ///        origin ----------→ target              ← the stick
    ///         proxy              proxy
    ///           |                  |                    ↑
    ///           | (indirect        | (indirect          |
    ///           ↓  subject)        ↓  subject)          | winding direction ↺
    ///         proxy              proxy                  |
    ///           |                  |
    ///           | (indirect        | (subject)
    ///           ↓  subject)        ↓
    ///         proxy            final target
    ///           |
    ///           | (subject)
    ///           ↓
    ///      final origin
    ///
    ///
    /// ```
    ///
    /// - Note: Any link to or from a proxy that is not marked as indirect
    ///         will consider the proxy to be the final endpoint. Subject
    ///         will not be followed. Note the _"all indirect links that are not
    ///         subject links"_ selection of links. This is to allow creation
    ///         of links to or from proxies that have domain specific meaning,
    ///         for example provide more information about the proxies or
    ///         make collections of proxies.
    ///
    /// - Important: To successfully rewrite the indirections, the graph must fulfil
    ///   indirection constraints. See ``IndirectionConstraint`` for more
    ///   information. It is up to the caller to make sure that the graph
    ///   is correct. If the constraints are not met, then the function will
    ///   fail with an error.
    ///
    public func rewrite(transform: ((IndirectionRewriter.Context) -> Link?)? = nil) -> Graph {
        // Nodes without ports
        let graph = self.graph.copy()

        // Get all indirect links that are not subject links (links from a proxy
        // to its real subject)
        //
        var rewriteLinks = Set(graph.links.filter {
            $0.isIndirect && !$0.isSubject
        })
        
        while !rewriteLinks.isEmpty {
            // Take a link (any)
            let link = rewriteLinks.popFirst()!
            
            var newOrigin: Node
            var newTarget: Node
            var labels = link.labels

            // Indirect endpoint – for both origin and target do:
            // 1. Expect the endpoint to be a proxy -> otherwise error
            // 2. Get a proxy subject link. MUST exist
            // 3. Endpoint will be target of the subject link
            // 4. If either of the endpoints was indirect, then the new link
            //    will be marked as indirect and placed back to the rewrite list
            
            let originSubjectLink: Link?
            let targetSubjectLink: Link?
            
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
                newOrigin = subjectLink.target
                
                if subjectLink.target.isProxy && subjectLink.isIndirect {
                    followAgain = true
                }
                else {
                    labels.remove(IndirectionLabel.IndirectOrigin)
                }
                originSubjectLink = subjectLink
            }
            else {
                newOrigin = link.origin
                originSubjectLink = nil
            }

            if link.hasIndirectTarget {
                let proxy = link.target
                guard proxy.isProxy else {
                    fatalError("Indirect origin must be a proxy")
                }
                guard let subjectLink = proxy.subjectLink else {
                    fatalError("Proxy must have a represented node")
                }
                newTarget = subjectLink.target
                
                if subjectLink.target.isProxy && subjectLink.isIndirect {
                    followAgain = true
                }
                else {
                    labels.remove(IndirectionLabel.IndirectTarget)
                }
                
                targetSubjectLink = subjectLink
            }
            else {
                newTarget = link.target
                targetSubjectLink = nil
            }
            
            var proposedLink = Link(origin: newOrigin,
                                    target: newTarget,
                                    labels: labels,
                                    id: link.id)

            let context = Context(
                replaced: link,
                originSubjectLink: originSubjectLink,
                targetSubjectLink: targetSubjectLink,
                proposed: proposedLink,
                isFinal: !followAgain
            )

            if let transform = transform {
                // Ask the caller to transform the proposed link
                if let transformed = transform(context) {
                    proposedLink = transformed
                }
            }
            
            // FIXME: What about the link ID?
            graph.disconnect(link: link)
            graph.add(proposedLink)
            
            if followAgain {
                rewriteLinks.insert(proposedLink)
            }
        }
        
        return graph
    }
    
    /// Get a path from a proxy node to the real subject. Real subject is a
    /// node that is referenced by a direct subject link.
    ///
    /// The function follows all indirect links from the provided proxy node
    /// until it finds a subject link that direct.
    ///
//    public func realSubjectPath(node: Node) -> Path {
//        
//    }
}
