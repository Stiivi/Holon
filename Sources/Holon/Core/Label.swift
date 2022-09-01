//
//  Label.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

/// Type of a node or a link label.
///
/// ## System Labels
///
/// Labels that start with `%` such as `%proxy` are labels that are managed
/// by the Holon library. The labels can be read by a user, however it is
/// strongly advised against setting or removing them manually. By manually
/// changing symbol labels the graph might get into an inconsistent, corrupted
/// state.
///
public typealias Label = String

/// Type for set of labels.
///
public typealias LabelSet = Set<String>

extension String {
    /// Flag whether the label is a system label. System labels start with
    /// `%` (a percent symbol).
    ///
    public var isSystemLabel: Bool { return hasPrefix("%")}
}

public class LabelDescription {
    
    
}
