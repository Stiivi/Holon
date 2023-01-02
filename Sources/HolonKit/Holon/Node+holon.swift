//
//  Holon.swift
//  
//
//  Created by Stefan Urbanek on 26/08/2022.
//


extension Node {
    /// Flag whether the node is a holon.
    public var isHolon: Bool { contains(label: HolonLabel.Holon) }
    
    /// Edge between the node and holon that owns the node.
    ///
    public var holonEdge: Edge? {
        if world == nil {
            return nil
        }
        else {
            return world!.outgoing(self.id).first { $0.isHolonEdge }
        }
    }
    
    /// Holon the node is associated with.
    ///
    public var holon: NodeID? {
        if world == nil {
            return nil
        }
        else {
            return holonEdge?.target
        }
    }
}
