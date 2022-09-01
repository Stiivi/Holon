//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//

// TODO: CONSTRAINT: Subject link origin must be proxy

extension Link {
    public static let IndirectTargetLabel = "__indirect_target"
    public static let IndirectOriginLabel = "__indirect_origin"
    public static let HolonLinkLabel = "__holon"
    
    /// Label for links from a proxy node to potentially real node.
    /// Links with this label are expected to have a proxy node as origin.
    public static let SubjectLabel = "__subject"
    
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
