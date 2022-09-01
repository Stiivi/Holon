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
    
    public var finalOrigin: Node? {
        if let proxy = origin as? Proxy {
            return proxy.finalNode
        }
        else {
            return origin
        }
    }

    public var finalTarget: Node? {
        if let proxy = target as? Proxy {
            return proxy.finalNode
        }
        else {
            return target
        }
    }
    
    /// Create an unassociated link object where the origin and target are final
    /// origin and final target of this link.
    ///
    /// Newly created link can not be associated with the same graph as the
    /// original link, because the IDs within a graph must be unique.
    ///
    /// Resolved link and the original link share the same identity because
    /// logically they represent the same link.
    ///
    /// - Note: Resolved link can not be used in the same graph
    ///
    public func resolved() -> Link {
        // TODO: This is slower a bit
        if isIndirect {
            guard let finalOrigin = self.finalOrigin else {
                preconditionFailure("Final origin must exist")
            }
            guard let finalTarget = self.finalTarget else {
                preconditionFailure("Final target must exist")
            }
            let link = Link(origin: finalOrigin,
                            target: finalTarget,
                            labels: labels,
                            id: id)
            return link
        }
        else {
            return self
        }
    }
}
