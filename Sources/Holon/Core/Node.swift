//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

// TODO: Node should be in World, not Holon, so we can benefit from the semantics

// Note: Node should not have any graph-mutable methods, neither for
// convenience. We need the user to understand the flow and potential
// constraints and effects.
//
// The original design (removed in this iteration) had mutation on the node.

/// Object representing a node of a graph.
///
open class Node: Object {
    /// Graph the object is associated with.
    ///
    public internal(set) var holon: Holon?
    

    var isProxy: Bool { false }

    /// Links outgoing from the node, that is links where the node is the
    /// origin.
    ///
    /// It is empty when the node is not associated with a graph.
    ///
    /// - Note: If you want to get both outgoing and incoming links of a node
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    public var outgoing: [Link] {
        return graph!.outgoing(self)
    }

    /// Links incoming to the node, that is links where the node is the target.
    ///
    /// It is empty when the node is not associated with a graph.
    ///
    /// - Note: If you want to get both outgoing and incoming links of a node
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for links that are loops to and from the same
    ///   node.
    ///
    public var incoming: [Link] {
        return graph!.incoming(self)
    }
    
    /// All the links that are associated somewhat with the node.
    ///
    /// It is empty when the node is not associated with a graph.
    ///
    public var neighbours: [Link] {
        return graph!.neighbours(self)
    }
    
    /// Returns links that match the selector `selector`.
    public func linksWithSelector(_ selector: LinkSelector) -> [Link] {
        // TODO: Find a better name
        let links: [Link]
        switch selector.direction {
        case .incoming: links = self.incoming
        case .outgoing: links = self.outgoing
        }
        
        return links.filter { $0.contains(label: selector.label) }
    }
}
