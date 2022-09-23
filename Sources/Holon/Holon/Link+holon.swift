//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

extension Edge {
    /// Flag whether this edge represents a child-holon edge.
    public var isHolonEdge: Bool { contains(label: HolonLabel.HolonEdge) }
}
