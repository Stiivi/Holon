//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//

// TODO: CONSTRAINT: Subject link origin must be proxy

extension Link {
    /// Flag whether to interpret the origin node as indirect.
    ///
    /// An indirect node is a node that has a reference node link.
    public var hasIndirectOrigin: Bool { contains(label: IndirectionLabel.IndirectOrigin) }

    /// Flag whether to interpret the target node as indirect
    public var hasIndirectTarget: Bool { contains(label: IndirectionLabel.IndirectTarget) }

    /// Flag denoting whether at least one of the link's endpoints is indirect.
    ///
    public var isIndirect: Bool { hasIndirectOrigin || hasIndirectTarget }

    /// Flag whether the link is from a proxy to proxy subject - a potentially
    /// real node.
    public var isSubject: Bool { contains(label: IndirectionLabel.Subject) }
}
