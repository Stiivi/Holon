//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/09/2022.
//

/// Labels related to the holon hierarchical structures and patterns.
/// 
public enum HolonLabel {
    /// Label for edges that connect a holon with its child node. The edge is
    /// oriented from the child to the holon.
    ///
    public static let HolonEdge = "%holon"
    
    /// Label for a node that represents a holon.
    ///
    public static let Holon = "%holon"

}
