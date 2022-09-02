//
//  IndirectionConstraints.swift
//  
//
//  Created by Stefan Urbanek on 02/09/2022.
//

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
    
    /// Origin of the proxy-subject link must be a proxy and
    /// the link must not have indirect origin.
    ///
    public static let SubjectLinkOriginIsDirectProxy = LinkConstraint(
        name: "subject_link_origin_is_direct_proxy",
        description: """
                     Origin of the proxy-subject link must be a proxy and
                     the link must not have indirect origin.
                     """,
        match: LabelPredicate(all: IndirectionLabel.Subject),
        requirement: LinkLabelsRequirement(
            origin: LabelPredicate(all: IndirectionLabel.Proxy),
            target: nil,
            link: LabelPredicate(none: IndirectionLabel.IndirectOrigin)
        )
    )
    
    /// All links that are marked as having indirect origin must
    /// have their origin to be a proxy.
    ///
    public static let IndirectOriginIsProxy = LinkConstraint(
        name: "indirect_origin_is_proxy",
        description: """
                     All links that are marked as having indirect origin must
                     have their origin to be a proxy.
                     """,
        match: LabelPredicate(all: IndirectionLabel.IndirectOrigin),
        requirement: LinkLabelsRequirement(
            origin: LabelPredicate(all: IndirectionLabel.Proxy),
            target: nil,
            link: nil
        )
    )

    /// All links that are marked as having indirect target must
    /// have their target to be a proxy.
    ///
    public static let IndirectTargetIsProxy = LinkConstraint(
        name: "indirect_target_is_proxy",
        description: """
                     All links that are marked as having indirect target must
                     have their target to be a proxy.
                     """,
        match: LabelPredicate(all: IndirectionLabel.IndirectTarget),
        requirement: LinkLabelsRequirement(
            origin: nil,
            target: LabelPredicate(all: IndirectionLabel.Proxy),
            link: nil
        )
    )
    
    /// List of all indirection constraints.
    public static let All: [Constraint] = [
        ProxyHasSingleSubject,
        SubjectLinkOriginIsDirectProxy,
        IndirectOriginIsProxy,
        IndirectTargetIsProxy
    ]
}
