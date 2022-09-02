//
//  IndirectionRewriter.swift
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

        /// Path to the subject of the origin, if the origin was indirect.
        /// It is `nil` if the origin was direct.
        let originPath: Path?

        /// Path to the subject of the target, if the target was indirect.
        /// It is `nil` if the target was direct.
        let targetPath: Path?
        
        /// Subject of the origin, if the origin was indirect.
        /// It is `nil` if the origin was direct.
        var originSubject: Node? { originPath?.target }

        /// Subject of the target, if the target was indirect.
        /// It is `nil` if the target was direct.
        var targetSubject: Node? { targetPath?.target }
        
        /// Link that is proposed to be created. The caller might modify
        /// the proposed link or create a new one. If a new link is created,
        /// then the proposed link will be disposed.
        var proposed: Link
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
    /// The algorithm is as follows:
    ///
    /// ```markdown
    /// 1. SET `to rewrite` TO all indirect links that are not subject links
    /// 2. WHILE there is a link in `to rewrite`  DO:
    ///     1. POP a link from `to rewrite`
    ///     2. FOR EACH indirect endpoint IN (origin, target) of the link:
    ///         1. ASSERT that the endpoint IS a proxy
    ///         2. GET path to the real subject of the endpoint
    ///     3. YIELD to caller to adjust the newly proposed link
    ///     4. DISCONNECT the link
    ///     5. CREATE new link between the new endpoints
    /// ```
    ///
    /// For example, with the following graph the caller will get two paths for
    /// potential transformation:
    ///
    /// - the origin path `[a1 -> a2, a2 -> a3, a3 -> X]`
    /// - the target path `[b1 -> b2, b2 -> Y]`
    ///
    /// ```
    ///        origin A1 ---------→ target B1
    ///         proxy               proxy
    ///           |                   |
    ///           | (indirect         | (indirect
    ///           ↓  subject)         ↓  subject)
    ///         proxy a2            proxy b2
    ///           |                   |
    ///           | (indirect         | (subject)
    ///           ↓  subject)         ↓
    ///         proxy a3           final target Y
    ///           |
    ///           | (subject)
    ///           ↓
    ///      final origin X
    ///
    ///
    /// ```
    ///
    ///  The result after rewriting will be:
    ///
    /// ```
    ///        origin A1           target B1
    ///         proxy               proxy
    ///           |                   |
    ///           | (indirect         | (indirect
    ///           ↓  subject)         ↓  subject)
    ///         proxy a2            proxy b2
    ///           |                   |
    ///           | (indirect         | (subject)
    ///           ↓  subject)         ↓
    ///         proxy a3           final target Y
    ///           |                   ↑
    ///           | (subject)         |
    ///           ↓                   |
    ///      final origin X ----------+
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
    /// - Important: The proposed link or a new proposal from within the
    ///   transformation block must have the same origin and target as
    ///   provided by the rewriter.
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
            let link = rewriteLinks.popFirst()!
            
            var labels = link.labels
            let originPath: Path?
            let targetPath: Path?
            
            // Follow indirect origin
            //
            if link.hasIndirectOrigin {
                let proxy = link.origin
                assert(proxy.isProxy, "Indirect origin must be a proxy")

                originPath = proxy.realSubjectPath()
                labels.remove(IndirectionLabel.IndirectOrigin)
            }
            else {
                originPath = nil
            }
            
            // Follow indirect target
            //
            if link.hasIndirectTarget {
                let proxy = link.target
                assert(proxy.isProxy, "Indirect target must be a proxy")

                targetPath = proxy.realSubjectPath()
                labels.remove(IndirectionLabel.IndirectTarget)
            }
            else {
                targetPath = nil
            }
            
            // Propose a new link
            //
            let newOrigin = originPath?.target ?? link.origin
            let newTarget = targetPath?.target ?? link.target

            var proposedLink = Link(origin: newOrigin,
                                    target: newTarget,
                                    labels: labels,
                                    id: link.id)

            let context = Context(
                replaced: link,
                originPath: originPath,
                targetPath: targetPath,
                proposed: proposedLink
            )

            // Give the caller a chance to modify the proposed link or to
            // provide a new link.
            //
            if let transform = transform {
                if let transformed = transform(context) {
                    proposedLink = transformed
                }
            }
            assert(newOrigin === proposedLink.origin
                    && newTarget === proposedLink.target,
                   "Proposed link endpoints can not be changed")

            graph.disconnect(link: link)
            graph.add(proposedLink)
        }
        
        return graph
    }
    
}
