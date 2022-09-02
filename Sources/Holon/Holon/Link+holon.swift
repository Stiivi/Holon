//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

extension Link {
    /// Flag whether this link represents a child-holon link.
    public var isHolonLink: Bool { contains(label: HolonLabel.HolonLink) }
}
