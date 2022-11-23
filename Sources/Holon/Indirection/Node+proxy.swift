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
    
    
    
}
