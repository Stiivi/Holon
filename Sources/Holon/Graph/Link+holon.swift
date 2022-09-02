//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

extension Link {
    /// Label for links that link a holon with its child node. The link is
    /// oriented from the child to the holon.
    ///
    public static let HolonLinkLabel = "%holon"
    
    /// Flag whether this link represents a child-holon link.
    public var isHolonLink: Bool { contains(label: Link.HolonLinkLabel) }
}
