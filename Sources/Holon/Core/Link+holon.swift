//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

extension Link {
    public static let HolonLinkLabel = "%holon"
    
    public var isHolonLink: Bool { contains(label: Link.HolonLinkLabel) }
}
