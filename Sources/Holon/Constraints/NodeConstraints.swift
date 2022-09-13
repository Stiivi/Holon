//
//  NodeConstraints.swift
//  
//
//  Created by Stefan Urbanek on 16/06/2022.
//

// TODO: Merge with LinkConstraint

/// An object representing constraint that checks nodes.
///
public class NodeConstraint: Constraint {
    public let name: String
    public let description: String?
    public let match: NodePredicate
    public let requirement: NodeConstraintRequirement
    
    /// Creates a node constraint.
    ///
    /// - Properties:
    ///
    ///     - name: Constraint name
    ///     - description: Constraint description
    ///     - match: a node predicate that matches nodes to be considered for
    ///       this constraint
    ///     - requirement: a requirement that needs to be satisfied by the
    ///       matched nodes.
    ///

    public init(name: String, description: String? = nil, match: NodePredicate, requirement: NodeConstraintRequirement) {
        self.name = name
        self.description = description
        self.match = match
        self.requirement = requirement
    }

    /// Check the graph for the constraint and return a list of nodes that
    /// violate the constraint
    ///
    public func check(_ graph: Graph) -> (nodes: [Node], links: [Link]) {
        let matched = graph.nodes.filter { match.match($0) }
        let violating = requirement.check(matched)
        return (nodes: violating, links: [])
    }
}

/// Definition of a constraint satisfaction requirement.
///
public protocol NodeConstraintRequirement {
    /// Check whether the constraint requirement is satisfied within the group
    /// of provided nodes.
    ///
    /// - Returns: List of graph objects that cause constraint violation.
    ///
    func check(_ nodes: [Node]) -> [Node]
}


public class UniqueNeighbourRequirement: NodeConstraintRequirement {
    public let linkSelector: LinkSelector
    public let isRequired: Bool
    
    /// Creates a constraint for unique neighbour.
    ///
    /// If the unique neighbour is required, then the constraint fails if there
    /// is no neighbour matching the link selector. If the neighbour is not
    /// required, then the constraint succeeds either where there is exactly
    /// one neighbour or when there is none.
    ///
    /// - Parameters:
    ///     - nodeLabels: labels that match the nodes for the constraint
    ///     - linkSelector: link selector that has to be unique for the matching node
    ///     - required: Wether the unique neighbour is required.
    ///
    public init(_ linkSelector: LinkSelector, required: Bool=false) {
        self.linkSelector = linkSelector
        self.isRequired = required
    }

    public convenience init(_ label: String, direction: LinkDirection = .outgoing, required: Bool=false) {
        self.init(LinkSelector(label, direction: direction), required: required)
    }
    
    public func check(_ node: Node) -> Bool {
        guard let graph = node.graph else {
            preconditionFailure("Node must be associated with a graph to be checked")
        }
        let links = graph.neighbours(node, selector: linkSelector)
        
        if isRequired {
            return links.count == 1
        }
        else {
            return links.count == 0 || links.count == 1
        }
    }

    public func check(_ nodes: [Node]) -> [Node] {
        return nodes.filter { !check($0) }
    }
}
