//
//  LinkConstraints.swift
//  
//
//  Created by Stefan Urbanek on 16/06/2022.
//

// TODO: Merge with NodeConstraint

/// Holon constraint for a link.
///
public class LinkConstraint: Constraint {
    public let name: String
    public let description: String?
    public let match: LinkPredicate
    public let requirement: LinkConstraintRequirement
    
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
    
    let originLabels: LabelPredicate?
    let targetLabels: LabelPredicate?
    let linkLabels: LabelPredicate?

    public init(origin: LabelPredicate? = nil,
                target: LabelPredicate? = nil,
                link: LabelPredicate? = nil) {
        guard !(origin == nil && target == nil && link == nil) else {
            preconditionFailure("At least one of the parameters must be set: origin or target")
        }
        
        self.originLabels = origin
        self.targetLabels = target
        self.linkLabels = target
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
