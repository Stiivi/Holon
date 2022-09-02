//
//  LinkConstraints.swift
//  
//
//  Created by Stefan Urbanek on 16/06/2022.
//

// TODO: Merge with NodeConstraint

/// An object representing constraint that checks links.
///
public class LinkConstraint: Constraint {
    /// Name of the constraint.
    ///
    /// See ``Constraint/name`` for more information.
    public let name: String
    
    /// Human readable description of the constraint. See ``Constraint/description``.
    ///
    public let description: String?

    /// A predicate that matches all links to be considered for this constraint.
    ///
    /// See ``LinkPredicate`` for more information.
    ///
    public let match: LinkPredicate
    
    /// A requirement that needs to be satisfied for the matched links.
    ///
    public let requirement: LinkConstraintRequirement
    
    /// Creates a link constraint.
    ///
    /// - Properties:
    ///
    ///     - name: Constraint name
    ///     - description: Constraint description
    ///     - match: a link predicate that matches links to be considered for
    ///       this constraint
    ///     - requirement: a requirement that needs to be satisfied by the
    ///       matched links.
    ///
    public init(name: String, description: String? = nil, match: LinkPredicate, requirement: LinkConstraintRequirement) {
        self.name = name
        self.description = description
        self.match = match
        self.requirement = requirement
    }

    /// Check the graph for the constraint and return a list of nodes that
    /// violate the constraint
    ///
    public func check(_ graph: Graph) -> (nodes: [Node], links: [Link]) {
        let matched = graph.links.filter { match.match($0) }
        let violating = requirement.check(matched)
        return (nodes: [], links: violating)
    }
}

/// Definition of a constraint satisfaction requirement.
///
public protocol LinkConstraintRequirement {
    /// Check whether the constraint requirement is satisfied within the group
    /// of provided links.
    ///
    /// - Returns: List of graph objects that cause constraint violation.
    ///
    func check(_ links: [Link]) -> [Link]
}

/// Requirement that the link origin, link target and the link itself matches
/// given labels.
///
public class LinkLabelsRequirement: LinkConstraintRequirement {
    
    // TODO: Use CompoundPredicate
    // FIXME: I do not like this class
    
    /// Labels to be matched on the link's origin, if provided.
    public let originLabels: LabelPredicate?
    
    /// Labels to be matched on the link's target, if provided.
    public let targetLabels: LabelPredicate?
    
    /// Labels to be matched on the link itself, if provided.
    public let linkLabels: LabelPredicate?

    /// Creates a constraint requirement for links that tests for labels on
    /// link's origin, target and/or the link itself. At least one of the
    /// parameters needs to be specified.
    ///
    /// - Parameters:
    ///
    ///     - origin: Predicate that matches labels on the link's origin
    ///     - target: Predicate that matches labels on the link's target
    ///     - link: Predicate that matches labels on the link itself
    ///
    public init(origin: LabelPredicate? = nil,
                target: LabelPredicate? = nil,
                link: LabelPredicate? = nil) {
        guard !(origin == nil && target == nil && link == nil) else {
            preconditionFailure("At least one of the parameters must be set: origin or target")
        }
        
        self.originLabels = origin
        self.targetLabels = target
        self.linkLabels = link
    }
    
    public func check(_ links: [Link]) -> [Link] {
        var violations: [Link] = []
        
        for link in links {
            if let predicate = originLabels, !predicate.match(link.origin) {
                violations.append(link)
                continue
            }
            if let predicate = targetLabels, !predicate.match(link.target) {
                violations.append(link)
                continue
            }
            if let predicate = linkLabels, !predicate.match(link) {
                violations.append(link)
                continue
            }
        }

        return violations
    }
}
