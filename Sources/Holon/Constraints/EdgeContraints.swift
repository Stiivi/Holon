//
//  EdgeConstraints.swift
//  
//
//  Created by Stefan Urbanek on 16/06/2022.
//

// TODO: Merge with NodeConstraint

/// An object representing constraint that checks edges.
///
public class EdgeConstraint: Constraint {
    /// Name of the constraint.
    ///
    /// See ``Constraint/name`` for more information.
    public let name: String
    
    /// Human readable description of the constraint. See ``Constraint/description``.
    ///
    public let description: String?

    /// A predicate that matches all edges to be considered for this constraint.
    ///
    /// See ``EdgePredicate`` for more information.
    ///
    public let match: EdgePredicate
    
    /// A requirement that needs to be satisfied for the matched edges.
    ///
    public let requirement: EdgeConstraintRequirement
    
    /// Creates an edge constraint.
    ///
    /// - Properties:
    ///
    ///     - name: Constraint name
    ///     - description: Constraint description
    ///     - match: an edge predicate that matches edges to be considered for
    ///       this constraint
    ///     - requirement: a requirement that needs to be satisfied by the
    ///       matched edges.
    ///
    public init(name: String, description: String? = nil, match: EdgePredicate, requirement: EdgeConstraintRequirement) {
        self.name = name
        self.description = description
        self.match = match
        self.requirement = requirement
    }

    /// Check the graph for the constraint and return a list of nodes that
    /// violate the constraint
    ///
    public func check(_ graph: GraphProtocol) -> (nodes: [Node], edges: [Edge]) {
        let matched = graph.edges.filter {
            match.match(graph: graph, edge: $0)
        }
        let violating = requirement.check(graph: graph, edges: matched)
        return (nodes: [], edges: violating)
    }
}

/// Definition of a constraint satisfaction requirement.
///
public protocol EdgeConstraintRequirement {
    /// Check whether the constraint requirement is satisfied within the group
    /// of provided edges.
    ///
    /// - Returns: List of graph objects that cause constraint violation.
    ///
    func check(graph: GraphProtocol, edges: [Edge]) -> [Edge]
}

/// Requirement that the edge origin, edge target and the edge itself matches
/// given labels.
///
public class EdgeLabelsRequirement: EdgeConstraintRequirement {
    
    // TODO: Use CompoundPredicate
    // FIXME: I do not like this class
    
    /// Labels to be matched on the edge's origin, if provided.
    public let originLabels: LabelPredicate?
    
    /// Labels to be matched on the edge's target, if provided.
    public let targetLabels: LabelPredicate?
    
    /// Labels to be matched on the edge itself, if provided.
    public let edgeLabels: LabelPredicate?

    /// Creates a constraint requirement for edges that tests for labels on
    /// edge's origin, target and/or the edge itself. At least one of the
    /// parameters needs to be specified.
    ///
    /// - Parameters:
    ///
    ///     - origin: Predicate that matches labels on the edge's origin
    ///     - target: Predicate that matches labels on the edge's target
    ///     - edge: Predicate that matches labels on the edge itself
    ///
    public init(origin: LabelPredicate? = nil,
                target: LabelPredicate? = nil,
                edge: LabelPredicate? = nil) {
        guard !(origin == nil && target == nil && edge == nil) else {
            preconditionFailure("At least one of the parameters must be set: origin or target")
        }
        
        self.originLabels = origin
        self.targetLabels = target
        self.edgeLabels = edge
    }
    
    public func check(graph: GraphProtocol, edges: [Edge]) -> [Edge] {
        var violations: [Edge] = []
        
        for edge in edges {
            if let predicate = originLabels, !predicate.match(graph: graph, node: edge.origin) {
                violations.append(edge)
                continue
            }
            if let predicate = targetLabels, !predicate.match(graph: graph, node: edge.target) {
                violations.append(edge)
                continue
            }
            if let predicate = edgeLabels, !predicate.match(graph: graph, edge: edge) {
                violations.append(edge)
                continue
            }
        }

        return violations
    }
}
