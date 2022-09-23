//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

// TODO: Node should be in World, not Holon, so we can benefit from the semantics

// Note: Node should not have any graph-mutable methods, neither for
// convenience. We need the user to understand the flow and potential
// constraints and effects.
//
// The original design (removed in this iteration) had mutation on the node.
public protocol Copying {
    func copy() -> Self
}
/// Object representing a node of a graph.
///
open class Node: Object, Copying {
    /// Type denoting a role of a node. Some nodes can have special meaning and
    /// treatment at the system level depending on their role. The roles can be:
    ///
    /// - ``default``: No special treatment of the node.
    /// - ``proxy``: Node represents a proxy node for another node.
    /// - ``holon``: Node represents a holon - a hierarchical grouping of other
    ///   nodes.
    ///
    public enum Role {
        /// Default node - no special treatment of the node.
        case `default`
        /// Role for proxy nodes - nodes that represent other nodes.
        case proxy
        /// Role for holon nodes - nodes that are hierarchical groupings of
        /// other nodes.
        case holon
        
        /// Label that represents the node role. Nil if the role has no special
        /// label.
        ///
        public var label: Label? {
            switch self {
            case .`default`: return nil
            case .proxy: return IndirectionLabel.Proxy
            case .holon: return HolonLabel.Holon
            }
        }
    }

    /// Create a node with a special role.
    /// 
    convenience public init(id: OID?=nil, labels: LabelSet=LabelSet(), role: Role) {
        if let label = role.label {
            self.init(id: id, labels: labels.union([label]))

        }
        else {
            self.init(id: id, labels: labels)
        }
    }

    /// Edges outgoing from the node, that is edges where the node is the
    /// origin.
    ///
    /// It is empty when the node is not associated with a graph.
    ///
    /// - Note: If you want to get both outgoing and incoming edges of a node
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for edges that are loops to and from the same
    ///   node.
    ///
    public var outgoing: [Edge] {
        return graph!.outgoing(self)
    }
    
    /// Edges incoming to the node, that is edges where the node is the target.
    ///
    /// It is empty when the node is not associated with a graph.
    ///
    /// - Note: If you want to get both outgoing and incoming edges of a node
    ///   then use ``neighbours``. Using ``outgoing`` + ``incoming`` might
    ///   result in duplicates for edges that are loops to and from the same
    ///   node.
    ///
    public var incoming: [Edge] {
        return graph!.incoming(self)
    }
        
    /// Creates an unassociated copy of the node.
    ///
    open func copy() -> Self {
        // FIXME: This is weird required casting
        return Node(id: id, labels: labels) as! Self
    }
}

extension Node: Hashable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs.id == rhs.id
        && lhs.labels == rhs.labels
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
