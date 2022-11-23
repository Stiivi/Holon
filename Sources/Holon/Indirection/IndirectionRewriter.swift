//
//  IndirectionRewriter.swift
//  
//
//  Created by Stefan Urbanek on 29/08/2022.
//


/// A graph rewriter that rewrites indirect edges into direct edges.
///
/// See ``IndirectionRewriter/rewrite(transform:)`` for more information about the
/// process.
///
public class IndirectionRewriter {
    public let transform: ((IndirectionRewriter.Context) -> Edge?)?
                           
    /// Rewriting context that is passed to the caller to allow adjustments
    /// of the newly created edge.
    ///
    public struct Context {
        /// The edge that is being replaced. This object will be disassociated
        /// from the graph.
        ///
        let replaced: Edge

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
        
        /// Edge that is proposed to be created. The caller might modify
        /// the proposed edge or create a new one. If a new edge is created,
        /// then the proposed edge will be disposed.
        var proposed: Edge
    }
    
    /// Creates a view for a graph where all of the indirect edges will be
    /// resolved to direct edges. Edge ID of the resolved edge is the same as
    /// the edge ID of the indirect edge.
    /// 
    public init(_ transform: ((IndirectionRewriter.Context) -> Edge?)? = nil) {
        self.transform = transform
    }
    
    
    /// Returns a new graph created by rewriting the original graph. The new
    /// graph will have indirect edges rewritten into direct edges.
    ///
    /// The algorithm is as follows:
    ///
    /// ```markdown
    /// 1. SET `to rewrite` TO all indirect edges that are not subject edges
    /// 2. WHILE there is an edge in `to rewrite`  DO:
    ///     1. POP an edge from `to rewrite`
    ///     2. FOR EACH indirect endpoint IN (origin, target) of the edge:
    ///         1. ASSERT that the endpoint IS a proxy
    ///         2. GET path to the real subject of the endpoint
    ///     3. YIELD to caller to adjust the newly proposed edge
    ///     4. DISCONNECT the edge
    ///     5. CREATE new edge between the new endpoints
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
    /// - Note: Any edge to or from a proxy that is not marked as indirect
    ///         will consider the proxy to be the final endpoint. Subject
    ///         will not be followed. Note the _"all indirect edges that are not
    ///         subject edges"_ selection of edges. This is to allow creation
    ///         of edges to or from proxies that have domain specific meaning,
    ///         for example provide more information about the proxies or
    ///         make collections of proxies.
    ///
    /// - Important: The proposed edge or a new proposal from within the
    ///   transformation block must have the same origin and target as
    ///   provided by the rewriter.
    ///
    /// - Important: To successfully rewrite the indirections, the graph must fulfil
    ///   indirection constraints. See ``IndirectionConstraint`` for more
    ///   information. It is up to the caller to make sure that the graph
    ///   is correct. If the constraints are not met, then the function will
    ///   fail with an error.
    ///
    public func rewrite(_ graph: Graph) {
        // Nodes without ports

        // Get all indirect edges that are not subject edges (edges from a proxy
        // to its real subject)
        //
        var rewriteEdges = Set(graph.edges.filter {
            $0.isIndirect && !$0.isSubject
        })
        
        while !rewriteEdges.isEmpty {
            let edge = rewriteEdges.popFirst()!
            
            var labels = edge.labels
            let originPath: Path?
            let targetPath: Path?
            
            // Follow indirect origin
            //
            if edge.hasIndirectOrigin {
                let proxy = edge.origin
                assert(proxy.isProxy, "Indirect origin must be a proxy")

                originPath = proxy.realSubjectPath()
                labels.remove(IndirectionLabel.IndirectOrigin)
            }
            else {
                originPath = nil
            }
            
            // Follow indirect target
            //
            if edge.hasIndirectTarget {
                let proxy = edge.target
                assert(proxy.isProxy, "Indirect target must be a proxy")

                targetPath = proxy.realSubjectPath()
                labels.remove(IndirectionLabel.IndirectTarget)
            }
            else {
                targetPath = nil
            }
            
            // Propose a new edge
            //
            let newOrigin = originPath?.target ?? edge.origin
            let newTarget = targetPath?.target ?? edge.target

            var proposedEdge = Edge(origin: newOrigin,
                                    target: newTarget,
                                    labels: labels,
                                    id: edge.id)

            let context = Context(
                replaced: edge,
                originPath: originPath,
                targetPath: targetPath,
                proposed: proposedEdge
            )

            // Give the caller a chance to modify the proposed edge or to
            // provide a new edge.
            //
            if let transform = self.transform {
                if let transformed = transform(context) {
                    proposedEdge = transformed
                }
            }
            assert(newOrigin === proposedEdge.origin
                    && newTarget === proposedEdge.target,
                   "Proposed edge endpoints can not be changed")

            graph.remove(edge)
            graph.add(proposedEdge)
        }
    }
    
}
