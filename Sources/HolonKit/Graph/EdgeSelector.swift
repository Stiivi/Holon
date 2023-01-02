//
//  EdgeSelector.swift
//  
//
//  Created by Stefan Urbanek on 17/01/2022.
//

/// Designation of which direction of an edge from a node projection perspective
/// is to be considered.
///
public enum EdgeDirection {
    /// Direction that considers edges where the node projection is the target.
    case incoming
    /// Direction that considers edges where the node projection is the origin.
    case outgoing
    
    /// Reversed direction. For ``incoming`` reversed is ``outgoing`` and
    /// vice-versa.
    ///
    public var reversed: EdgeDirection {
        switch self {
        case .incoming: return .outgoing
        case .outgoing: return .incoming
        }
    }
}

/// Describes edges that have a label attribute.
///
public struct EdgeSelector {
    /// Label of an edge. Edges with this label are conforming to this edge type.
    public let labels: LabelSet
    
    /// Direction of an edge.
    public let direction: EdgeDirection
    
    /// A selector with reversed direction.
    public var reversed: EdgeSelector {
        return EdgeSelector(labels, direction: direction.reversed)
    }
    
    /// Create an edge selector that matches edges with given label.
    ///
    /// - Parameters:
    ///     - label: Label of edges that conform to this type
    ///     - direction: Direction of edges to be considered when relating
    ///       to a projected node.
    public init(_ label: Label, direction: EdgeDirection = .outgoing) {
        self.labels = LabelSet([label])
        self.direction = direction
    }
    
    /// Create an edge selector that matches edges with all given labels.
    ///
    /// - Parameters:
    ///     - labels: Labels of edges that conform to this type
    ///     - direction: Direction of edges to be considered when relating
    ///       to a projected node.
    public init(_ labels: LabelSet, direction: EdgeDirection = .outgoing) {
        self.labels = labels
        self.direction = direction
    }

    /// Returns endpoint of the edge based on the direction. Returns edge's
    /// origin if the direction is ``EdgeDirection/incoming`` or returns edge's target if the
    /// direction is ``EdgeDirection/outgoing``.
    ///
    public func endpoint(_ edge: Edge) -> NodeID {
        switch direction {
        case .incoming: return edge.origin
        case .outgoing: return edge.target
        }
    }
}

