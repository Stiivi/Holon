//
//  Node+Proxy.swift
//
//
//  Created by Stefan Urbanek on 23/08/2022.
//

// FIXME: Move this to Node.swift
extension Node {
    /// An edge selector that matches an edge from a proxy to its subject.
    public static let SubjectSelector = EdgeSelector(IndirectionLabel.Subject,
                                                     direction: .outgoing)
    
    public var isProxy: Bool { contains(label: IndirectionLabel.Proxy) }
    
    /// Edge that is a representation of the proxy node.
    ///
    /// Representation edge is an outgoing edge from the proxy node
    /// which has a label ``IndirectionLabel/Subject``.
    ///
    public var subjectEdge: Edge? { outgoing.first { $0.isSubject } }
    
    /// A node that the port represents. This is a direct subject, not the
    /// real subject if the subject edge is indirect.
    ///
    /// To get the real subject use ``realSubjectPath()`` to get the
    /// path to the real subject traversing indirect subject edges.
    /// Target of the last edge, which can be retrieved using ``Path/target``,
    /// is the real subject.
    ///
    public var subject: Node? { subjectEdge?.target }
    
    /// Get a path from a proxy node to the real subject. Real subject is a
    /// node that is referenced by a direct subject edge.
    ///
    /// The function follows all indirect edges from the provided proxy node
    /// until it finds a subject edge that direct.
    ///
    /// - Precondition: Node must be a proxy and indirection integrity must
    ///   be assured.
    ///
    public func realSubjectPath() -> Path {
        precondition(isProxy)
        
        var current = self
        var trail: [Edge] = []
        
        while true {
            guard let edge = current.subjectEdge else {
                break
            }
            
            trail.append(edge)
            
            if edge.hasIndirectTarget {
                current = edge.target
            }
            else {
                break
            }
        }
        
        return Path(trail)
    }
}
