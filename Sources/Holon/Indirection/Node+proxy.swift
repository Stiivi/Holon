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
    
    /// A node that the port represents. Must be from the same holon as the
    /// referencing port.
    ///
    public var subject: Node? { subjectLink?.target }
    
}
