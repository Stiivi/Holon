//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//

// TODO: CONSTRAINT: Subject link origin must be proxy

extension Link {
    /// Label for a link indicating that the target of the link is indirect.
    /// The target must be a proxy node (see ``Node/ProxyLabel``).
    ///
    public static let IndirectTargetLabel = "%indirect-target"

    /// Label for a link indicating that the origin of the link is indirect.
    /// The origin must be a proxy node (see ``Node/ProxyLabel``).
    ///
    public static let IndirectOriginLabel = "%indirect-origin"
    
    /// Label for links from a proxy node to potentially real node.
    /// Links with this label are expected to have a proxy node as origin.
    ///
    /// See also: ``IndirectionConstraints``
    ///
    public static let SubjectLabel = "%subject"
    
    /// Flag denoting whether at least one of the link's endpoints is indirect.
    ///
    public var isIndirect: Bool { hasIndirectOrigin || hasIndirectTarget }

    /// Flag whether to interpret the origin node as indirect.
    ///
    /// An indirect node is a node that has a reference node link.
    public var hasIndirectOrigin: Bool { contains(label: Link.IndirectOriginLabel) }

    /// Flag whether to interpret the target node as indirect
    public var hasIndirectTarget: Bool { contains(label: Link.IndirectTargetLabel) }

    /// Flag whether the link is from a proxy to proxy subject - a potentially
    /// real node.
    public var isSubject: Bool { contains(label: Link.SubjectLabel) }
}
