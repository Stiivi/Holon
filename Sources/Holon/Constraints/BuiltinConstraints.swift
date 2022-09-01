//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

// TODO: Is the following statement still true?
// There is no need to check for these constraints during application lifetime.
// They are assured by the library.
//
/// Constraints to be checked on all graphs that has been imported from the
/// outside.
///
public let IndirectionConstraints: [Constraint] = [

    // MARK: - Proxy and Indirection Constraints
    //
    NodeConstraint(
        name: "proxy_single_subject",
        description: """
                     A proxy must have exactly one subject.
                     """,
        match: LabelPredicate(all: Node.ProxyLabel),
        requirement: UniqueNeighbourRequirement(Node.SubjectSelector,
                                                required: true)
    ),

    LinkConstraint(
        name: "subject_link_origin_is_proxy",
        description: """
                     Origin of the proxy-subject link must be a proxy.
                     """,
        match: LabelPredicate(all: Link.SubjectLabel),
        requirement: LinkLabelsRequirement(
            origin: LabelPredicate(all: Node.ProxyLabel),
            target: nil,
            link: nil
        )
    ),
    
    LinkConstraint(
        name: "indirect_origin_is_proxy",
        description: """
                     All links that are marked as having indirect origin must
                     have their origin to be a proxy.
                     """,
        match: LabelPredicate(all: Link.IndirectOriginLabel),
        requirement: LinkLabelsRequirement(
            origin: LabelPredicate(all: Node.ProxyLabel),
            target: nil,
            link: nil
        )
    ),
    
    LinkConstraint(
        name: "indirect_target_is_proxy",
        description: """
                     All links that are marked as having indirect target must
                     have their target to be a proxy.
                     """,
        match: LabelPredicate(all: Link.IndirectTargetLabel),
        requirement: LinkLabelsRequirement(
            origin: nil,
            target: LabelPredicate(all: Node.ProxyLabel),
            link: nil
        )
    ),

]

// MARK: - Holon Constraints
//
/// List of constraints to check whether holon structures are consistent.
///
/// The constraints include:
///
/// - Every node must have only one parent holon.
///
/// - SeeAlso: ``StrictHolonConstraints``.
///
public let HolonConstraints: [Constraint] = [
    NodeConstraint(
        name: "single_parent_holon",
        description: """
                     A node must have only parent holon or no parent holon.
                     """,
        match: AnyNodePredicate(),
        requirement: UniqueNeighbourRequirement(Node.ParentHolonSelector)
    ),
]

/// Additional list of constraints (to the ``HolonConstraints``) to check
/// whether the holon structures are consistent.
///
/// The constraints include:
///
/// - There must be no links between nodes of two different holons.
///
///
/// - SeeAlso: ``HolonConstraints``.
///
public let StrictHolonConstraints: [Constraint] = [
    // TODO: Add constraints as promised above (this is just a placeholder/reminder)
//    NodeConstraint(
//        name: "single_parent_holon",
//        description: """
//                     A node must have only parent holon or no parent holon.
//                     """,
//        match: AnyNodePredicate(),
//        requirement: UniqueNeighbourRequirement(Node.ParentHolonSelector)
//    ),
]
