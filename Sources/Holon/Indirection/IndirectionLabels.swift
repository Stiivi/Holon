//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/09/2022.
//

/// Labels used for creating indirection graph structures and patterns.
///
public enum IndirectionLabel {
    /// Label for a link indicating that the target of the link is indirect.
    /// The target must be a proxy node (see ``Proxy``).
    ///
    public static let IndirectTarget = "%indirect-target"
    
    /// Label for a link indicating that the origin of the link is indirect.
    /// The origin must be a proxy node (see ``Proxy``).
    ///
    public static let IndirectOrigin = "%indirect-origin"
    
    /// Label for links from a proxy node to potentially real node.
    /// Links with this label are expected to have a proxy node as origin.
    ///
    /// See also: ``IndirectionConstraint``
    ///
    public static let Subject = "%subject"
    
    
    /// Label for a node that represents a proxy.
    ///
    /// Nodes that represent a proxy are expected to have exactly one
    /// link to the proxy subject. The proxy is the origin and the subject
    /// is the target of the link. The link must have ``Subject`` label
    /// set.
    ///
    /// See also: ``IndirectionConstraint``
    ///
    public static let Proxy = "%proxy"
}
