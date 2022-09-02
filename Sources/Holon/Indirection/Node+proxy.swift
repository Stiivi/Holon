//
//  Node+Proxy.swift
//
//
//  Created by Stefan Urbanek on 23/08/2022.
//

// FIXME: Move this to Node.swift
extension Node {
    /// A link selector that matches a link from a proxy to its subject.
    public static let SubjectSelector = LinkSelector(IndirectionLabel.Subject,
                                                     direction: .outgoing)
    
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
            case .holon: return Node.HolonLabel
            }
        }
    }

    convenience public init(id: OID?=nil, labels: LabelSet=LabelSet(), role: Role) {
        if let label = role.label {
            self.init(id: id, labels: labels.union([label]))

        }
        else {
            self.init(id: id, labels: labels)
        }
    }

    public var isProxy: Bool { contains(label: IndirectionLabel.Proxy) }
    
    /// Link that is a representation of the proxy node.
    ///
    /// Representation link is an outgoing link from the proxy node
    /// which has a label ``Link/SubjectLabel``.
    ///
    public var subjectLink: Link? { outgoing.first { $0.isSubject } }
    
    /// A node that the port represents. Must be from the same holon as the
    /// referencing port.
    ///
    public var subject: Node? { subjectLink?.target }
    
}
