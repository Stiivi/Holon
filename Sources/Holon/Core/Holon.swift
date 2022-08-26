//
//  Holon.swift
//  
//
//  Created by Stefan Urbanek on 26/08/2022.
//


public protocol HolonProtocol: GraphProtocol {
    var holons: [Holon] { get }
    var allHolons: [Holon] { get }
    var ports: [Port] { get }
    var allPorts: [Port] { get }
}

public extension HolonProtocol {
    /// List of all holons, including nested one, that are contained in the
    /// graph.
    ///
    var allHolons: [Holon] {
        nodes.compactMap { $0 as? Holon }
    }

    /// List of all ports, including nested one, that are contained in the
    /// graph.
    ///
    var allPorts: [Port] {
        nodes.compactMap { $0 as? Port }
    }
}

/// A special node representing a hierarchical entity within the graph.
///
public class Holon: Node, HolonProtocol, MutableGraphProtocol {
    
    /// List of nodes that belong to the holon directly. The list excludes all
    /// nodes that belong to the children holons.
    ///
    public var nodes: [Node] { graph!.nodes.filter { $0.holon === self } }

    /// Get all links that belong to the holon.
    ///
    /// Links that belong to the holon are those links that are between the
    /// direct children nodes of the holon. Links that are between nodes
    /// of the holon and a child or a parent holon are not included.
    ///
    public var links: [Link] {
        graph!.links.filter {
            $0.graph === self.graph
            && $0.origin.holon === self
            && $0.target.holon === self
        }
    }
    
    /// List of top-level holons – those holons that have no parent.
    ///
    public var holons: [Holon] {
        nodes.compactMap {
            if $0.holon == self {
                return $0 as? Holon
            }
            else {
                return nil
            }
        }
    }
    
    public var ports: [Port] {
        nodes.compactMap {
            if $0.holon == self {
                return $0 as? Port
            }
            else {
                return nil
            }
        }
    }

    /// Add a node to the holon.
    ///
    /// A node is added to the graph and marked as belonging to this holon.
    ///
    public func add(_ node: Node) {
        graph!.add(node, into: self)
    }
    
    /// Remove a node from the holon and from the owning graph.
    ///
    /// See ``Graph/remove(_:)`` for more information.
    ///
    /// - Precondition: Node must belong to the holon.
    ///
    public func remove(_ node: Node) -> (links: [Link], nodes: [Node]) {
        precondition(node.holon === self, "Trying to remove a node of another holon")
        return graph!.remove(node)
    }
    
    /// Connects two nodes within the holon. Both nodes must belong to the same
    /// holon.
    ///
    public func connect(from origin: Node, to target: Node, labels: LabelSet, id: OID?) -> Link {
        precondition(origin.holon === self, "Trying to connect a node (as origin) that belongs to another holon")
        precondition(target.holon === self, "Trying to connect a node (as target) that belongs to another holon")
        return graph!.connect(from: origin, to: target, labels: labels, id: id)
    }
    
    /// Disconnects a link.
    ///
    /// See: ``Graph/disconnect(link:)``
    ///
    /// - Precondition: At least one of origin or a target must belong to the holon.
    ///
    public func disconnect(link: Link) {
        precondition(link.origin.holon === self || link.target.holon === self,
                     "Trying to disconnect a link that does not belong to the holon, neither crosses its boundary")
        graph!.disconnect(link: link)
    }
}
