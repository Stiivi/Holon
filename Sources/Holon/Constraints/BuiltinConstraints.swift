//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//


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
