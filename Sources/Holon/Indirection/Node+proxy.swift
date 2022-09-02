//
//  Node+Proxy.swift
//
//
//  Created by Stefan Urbanek on 23/08/2022.
//

// FIXME: Move this to Node.swift
extension Node {
    /// A link selector that matches a link from a proxy to its subject.
    public static let SubjectSelector = LinkSelector(IndirectionLabel.Subject,
                                                     direction: .outgoing)
    
    public var isProxy: Bool { contains(label: IndirectionLabel.Proxy) }
    
    /// Link that is a representation of the proxy node.
    ///
    /// Representation link is an outgoing link from the proxy node
    /// which has a label ``IndirectionLabel/Subject``.
    ///
    public var subjectLink: Link? { outgoing.first { $0.isSubject } }
    
    /// A node that the port represents. This is a direct subject, not the
    /// real subject if the subject link is indirect.
    ///
    /// To get the real subject use ``realSubjectPath()`` to get the
    /// path to the real subject traversing indirect subject links.
    /// Target of the last link, which can be retrieved using ``Path/target``,
    /// is the real subject.
    ///
    public var subject: Node? { subjectLink?.target }
    
    /// Get a path from a proxy node to the real subject. Real subject is a
    /// node that is referenced by a direct subject link.
    ///
    /// The function follows all indirect links from the provided proxy node
    /// until it finds a subject link that direct.
    ///
    /// - Precondition: Node must be a proxy and indirection integrity must
    ///   be assured.
    ///
    public func realSubjectPath() -> Path {
        precondition(isProxy)
        
        var current = self
        var trail: [Link] = []
        
        while true {
            guard let link = current.subjectLink else {
                break
            }
            
            trail.append(link)
            
            if link.hasIndirectTarget {
                current = link.target
            }
            else {
                break
            }
        }
        
        return Path(trail)
    }
}
