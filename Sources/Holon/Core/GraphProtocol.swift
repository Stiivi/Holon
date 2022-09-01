//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 23/08/2022.
//

public protocol GraphProtocol {
    var nodes: [Node] { get }
    var links: [Link] { get }
    /// Check whether the graph contains a node and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the node.
    ///
    /// - Note: Node comparison is based on its identity. Two nodes with the
    /// same attributes that are equatable are considered distinct nodes in the
    /// graph.
    ///
    ///
    func contains(node: Node) -> Bool
    
    /// Check whether the graph contains a link and whether the node is valid.
    ///
    /// - Returns: `true` if the graph contains the link.
    ///
    /// - Note: Link comparison is based on its identity.
    ///
    func contains(link: Link) -> Bool

    /// Get a list of outgoing links from a node.
    ///
    /// - Parameters:
    ///     - origin: Node from which the links originate - node is origin
    ///     node of the link.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    /// - Note: If you want to get both outgoing and incoming links of a node
    ///   then use ``neighbours(_:)-d13k``. Using ``outgoing(_:)`` + ``incoming(_:)-3rfqk`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    func outgoing(_ origin: Node) -> [Link]
    
    /// Get a node by ID.
    ///
    func node(_ id: Object.ID) -> Node?

    /// Get a link by ID.
    ///
    func link(_ id: Object.ID) -> Link?

    
    /// Get a list of links incoming to a node.
    ///
    /// - Parameters:
    ///     - target: Node to which the links are incoming – node is a target
    ///       node of the link.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///
    /// - Note: If you want to get both outgoing and incoming links of a node
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///

    func incoming(_ target: Node) -> [Link]
    /// Get a list of links that are related to the neighbours of the node. That
    /// is, list of links where the node is either an origin or a target.
    ///
    /// - Returns: List of links.
    ///
    /// - Complexity: O(n). All links are traversed.
    ///

    func neighbours(_ node: Node) -> [Link]
    
    /// Returns links that are related to the node and that match the given
    /// link selector.
    ///
    func neighbours(_ node: Node, selector: LinkSelector) -> [Link]

}

extension GraphProtocol {
    public func contains(node: Node) -> Bool {
        return nodes.contains { $0 === node }
    }

    public func contains(link: Link) -> Bool {
        return links.contains { $0 === link }
    }
    
    /// Get a node by ID.
    ///
    /// If id is `nil` then returns nil.
    ///
    public func node(_ id: Object.ID) -> Node? {
        guard let id = id else {
            return nil
        }
        return nodes.first { $0.id == id }
    }

    /// Get a link by ID.
    ///
    /// If id is `nil` then returns nil.
    ///
    public func link(_ id: Object.ID) -> Link? {
        guard let id = id else {
            return nil
        }
        return links.first { $0.id == id }
    }

    public func outgoing(_ origin: Node) -> [Link] {
        let result: [Link]
        
        result = self.links.filter {
            $0.origin === origin
        }

        return result
    }
    public func incoming(_ target: Node) -> [Link] {
        let result: [Link]
        
        result = self.links.filter {
            $0.target === target
        }

        return result
    }
    public func neighbours(_ node: Node) -> [Link] {
        let result: [Link]
        
        result = self.links.filter {
            $0.target === node || $0.origin === node
        }

        return result
    }
    public func neighbours(_ node: Node, selector: LinkSelector) -> [Link] {
        // TODO: Find a better name
        let links: [Link]
        switch selector.direction {
        case .incoming: links = self.incoming(node)
        case .outgoing: links = self.outgoing(node)
        }
        
        return links.filter { $0.contains(label: selector.label) }
    }

}

public protocol MutableGraphProtocol: GraphProtocol {
    func add(_ node: Node)
    func remove(_ node: Node) -> [Link]
    func connect(from origin: Node, to target: Node, labels: LabelSet, id: OID?) -> Link
    func disconnect(link: Link)
}
