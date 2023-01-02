//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/09/2022.
//

/// Protocol for a Holon - a hierarchical structure.
///
public protocol HolonProtocol: GraphProtocol {
    /// List of child holons that belong to the receiver.
    ///
    var childHolons: [Node] { get }

    /// List of all holons that belong to the receiver, including holons
    /// of the children.
    ///
    var allHolons: [Node] { get }

    /// List of direct ports of the holon.
    ///
    var ports: [Node] { get }

    /// List of all ports of the holon.
    ///
    var allPorts: [Node] { get }
}

extension HolonProtocol {
    /// List of all holons, including nested one, that are contained in the
    /// graph.
    ///
    public var allHolons: [Node] {
        nodes.filter { $0.isHolon }
    }

    /// List of all ports, including nested one, that are contained in the
    /// graph.
    ///
    public var allPorts: [Node] {
        nodes.filter { $0.isProxy }
    }
}

