//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/09/2022.
//

/// Labels used for creating indirection graph structures and patterns.
///
public enum IndirectionLabel {
    /// Label for an edge indicating that the target of the edge is indirect.
    /// The target must be a proxy node (see ``Proxy``).
    ///
    public static let IndirectTarget = "%indirect-target"
    
    /// Label for an edge indicating that the origin of the edge is indirect.
    /// The origin must be a proxy node (see ``Proxy``).
    ///
    public static let IndirectOrigin = "%indirect-origin"
    
    /// Label for edges from a proxy node to potentially real node.
    /// Edges with this label are expected to have a proxy node as origin.
    ///
    /// See also: ``IndirectionConstraint``
    ///
    public static let Subject = "%subject"
    
    
    /// Label for a node that represents a proxy.
    ///
    /// Nodes that represent a proxy are expected to have exactly one
    /// edge to the proxy subject. The proxy is the origin and the subject
    /// is the target of the edge. The edge must have ``Subject`` label
    /// set.
    ///
    /// See also: ``IndirectionConstraint``
    ///
    public static let Proxy = "%proxy"
}
