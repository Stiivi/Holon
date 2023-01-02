//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 02/09/2022.
//

/// Constraints for checking graph integrity when the graph contains holon
/// patterns.
///
/// Use the constraints on all graphs that has been imported from the
/// outside.
///
public enum HolonConstraint {
    // NOTE: When editing the constraints, make sure that the documentation
    //       comment and the description are exactly the same.
    // NOTE: Do not forget to update the All list at the bottom.


    /// A node must have only parent holon or no parent holon.
    ///
    public static let SingleParentHolon = NodeConstraint(
        name: "single_parent_holon",
        description: """
                     A node must have only parent holon or no parent holon.
                     """,
        match: AnyNodePredicate(),
        requirement: UniqueNeighbourRequirement(Holon.ParentHolonSelector)
    )
    
    /// List of all holon constraints.
    ///
    public static let All: [Constraint] = [
        SingleParentHolon,
    ]
}

/// - ToDo: Add strict holon constraints, such as cross-holon boundary crossing.
public enum StrictHolonConstraint {
    // TODO: Add StrictHolonConstraint list
    // Check cross-holon boundaries

    /// List of all strict holon constraints.
    ///
    public static let All: [Constraint] = [
    ]
}
