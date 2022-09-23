//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 13/06/2022.
//


/// Predicate that matches a graph object (either a node or an edge) for
/// existence of labels. The tested object must have all the specified labels
/// set.
///
public class LabelPredicate: NodePredicate, EdgePredicate  {
    public let mode: MatchMode
    public let labels: LabelSet
    
    public enum MatchMode {
        /// Match any of the labels specified in the predicate
        case any
        /// Match all of the labels specified in the predicate
        case all
        // #TODO: Replace `none` with negation predicate
        /// Match none of the labels
        case none
    }
    
    /// Creates a predicate from a list of labels to be matched.
    ///
    public convenience init(any labels: String...) {
        self.init(labels: Set(labels), mode: .any)
    }

    /// Creates a predicate from a list of labels to be matched.
    ///
    public convenience init(all labels: String...) {
        self.init(labels: Set(labels), mode: .all)
    }

    /// Creates a predicate that matches objects which do not contain any of
    /// the labels.
    ///
    public convenience init(none labels: String...) {
        // # TODO: Replace this with negation predicate
        self.init(labels: Set(labels), mode: .none)
    }

    /// Creates a predicate from a list of labels to be matched.
    ///
    public init(labels: LabelSet, mode: MatchMode) {
        self.labels = labels
        self.mode = mode
    }
    
    // FIXME: See Predicate comment about rewriting
    public func match(_ object: Object) -> Bool {
        switch mode {
        case .all: return object.contains(labels: labels)
        case .any: return !labels.intersection(object.labels).isEmpty
        case .none: return labels.intersection(object.labels).isEmpty
        }
    }

    public func match(_ node: Node) -> Bool {
        switch mode {
        case .all: return node.contains(labels: labels)
        case .any: return !labels.intersection(node.labels).isEmpty
        case .none: return labels.intersection(node.labels).isEmpty
        }
    }

    public func match(_ edge: Edge) -> Bool {
        switch mode {
        case .all: return edge.contains(labels: labels)
        case .any: return !labels.intersection(edge.labels).isEmpty
        case .none: return labels.intersection(edge.labels).isEmpty
        }
    }
}

public enum LogicalConnective {
    case and
    case or
}

// TODO: Convert this to a generic.
// NOTE: So far I was fighting with the compiler (5.6):
// - compiler segfaulted
// - got: "Runtime support for parameterized protocol types is only available in macOS 99.99.0 or newer"
// - various compilation errors

/// A predicate.
///
/// - ToDo: This is waiting for Swift 5.7 for some rewrite.
///
public protocol Predicate {
    func match(_ object: Object) -> Bool
    func and(_ predicate: Predicate) -> CompoundPredicate
    func or(_ predicate: Predicate) -> CompoundPredicate
}

extension Predicate {
    public func and(_ predicate: Predicate) -> CompoundPredicate {
        return CompoundPredicate(.and, predicates: self, predicate)
    }
    public func or(_ predicate: Predicate) -> CompoundPredicate {
        return CompoundPredicate(.or, predicates: self, predicate)
    }
}

public class CompoundPredicate: Predicate {
    public let connective: LogicalConnective
    public let predicates: [Predicate]
    
    public init(_ connective: LogicalConnective, predicates: any Predicate...) {
        self.connective = connective
        self.predicates = predicates
    }
    
    public func match(_ object: Object) -> Bool {
        switch connective {
        case .and: return predicates.allSatisfy{ $0.match(object) }
        case .or: return predicates.contains{ $0.match(object) }
        }
    }
}

public class NegationPredicate: Predicate {
    public let predicate: Predicate
    public init(_ predicate: any Predicate) {
        self.predicate = predicate
    }
    public func match(_ object: Object) -> Bool {
        return !predicate.match(object)
    }
}
