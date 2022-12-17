//
//  IndirectionConstraints.swift
//  
//
//  Created by Stefan Urbanek on 02/09/2022.
//

/*
 
 
 Valid:
 
                                    %indirect-target
  N(*) --------------------------------------------> N(%proxy)

            %indirect-origin        %indirect-target
  N(%proxy) ---------------------------------------> N(%proxy)

            %indirect-origin
  N(%proxy) ---------------------------------------> N(*)

                                            %subject
  N(%proxy) ---------------------------------------> N(*)

                          %subject, %indirect-target
  N(%proxy) ---------------------------------------> N(%proxy)

 
 INVALID:
 

            %indirect-origin                %subject
  N(%proxy) ---------------------------------------> N(*)

 
                                            %subject
  N(%proxy) ---------------------------------------> N(*)
       |                                    %subject
       +-------------------------------------------> N(*)

 
              %indirect-origin       %indirect-target
  N(%! proxy) ---------------------------------------> N(! %proxy)

 
 
 
 */


/// Constraints for checking graph integrity when the graph contains indirection
/// patterns.
///
/// Use the constraints on all graphs that has been imported from the
/// outside.
///
public enum IndirectionConstraint {
    // NOTE: When editing the constraints, make sure that the documentation
    //       comment and the description are exactly the same.
    // NOTE: Do not forget to update the All list at the bottom.
    
    /// A proxy must have exactly one subject.
    ///
    public static let ProxyHasSingleSubject = NodeConstraint(
        name: "proxy_has_single_subject",
        description: """
                     A proxy must have exactly one subject.
                     """,
        match: LabelPredicate(all: IndirectionLabel.Proxy),
        requirement: UniqueNeighbourRequirement(Node.SubjectSelector,
                                                required: true)
    )
    
    /// Origin of the proxy-subject edge must be a proxy and
    /// the edge must not have indirect origin.
    ///
    public static let SubjectEdgeOriginIsDirectProxy = EdgeConstraint(
        name: "subject_edge_origin_is_direct_proxy",
        description: """
                     Origin of the proxy-subject edge must be a proxy and
                     the edge must not have indirect origin.
                     """,
        match: LabelPredicate(all: IndirectionLabel.Subject),
        requirement: EdgeLabelsRequirement(
            origin: LabelPredicate(all: IndirectionLabel.Proxy),
            target: nil,
            edge: LabelPredicate(none: IndirectionLabel.IndirectOrigin)
        )
    )
    
    /// All edges that are marked as having indirect origin must
    /// have their origin to be a proxy.
    ///
    public static let IndirectOriginIsProxy = EdgeConstraint(
        name: "indirect_origin_is_proxy",
        description: """
                     All edges that are marked as having indirect origin must
                     have their origin to be a proxy.
                     """,
        match: LabelPredicate(all: IndirectionLabel.IndirectOrigin),
        requirement: EdgeLabelsRequirement(
            origin: LabelPredicate(all: IndirectionLabel.Proxy),
            target: nil,
            edge: nil
        )
    )

    /// All edges that are marked as having indirect target must
    /// have their target to be a proxy.
    ///
    public static let IndirectTargetIsProxy = EdgeConstraint(
        name: "indirect_target_is_proxy",
        description: """
                     All edges that are marked as having indirect target must
                     have their target to be a proxy.
                     """,
        match: LabelPredicate(all: IndirectionLabel.IndirectTarget),
        requirement: EdgeLabelsRequirement(
            origin: nil,
            target: LabelPredicate(all: IndirectionLabel.Proxy),
            edge: nil
        )
    )
    
    /// List of all indirection constraints.
    public static let All: [Constraint] = [
        ProxyHasSingleSubject,
        SubjectEdgeOriginIsDirectProxy,
        IndirectOriginIsProxy,
        IndirectTargetIsProxy
    ]
}
