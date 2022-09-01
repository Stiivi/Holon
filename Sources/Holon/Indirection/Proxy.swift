//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 23/08/2022.
//

import Foundation

// FIXME: Move this to Node.swift
extension Node {
    public static let ProxyLabel = "__proxy"

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
            case .proxy: return Node.ProxyLabel
            case .holon: return Holon.HolonLabel
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

    var isProxy: Bool { contains(label: Node.ProxyLabel) }
}



// FIXME: When removing a port represented object, graph becomes inconsistent because the pseudo-link remains

/// Node that represents another node.
///
/// When a proxy node is used as a link endpoint (as a target or as an origin),
/// and if the link is marked as indirect, then the link can be interpreted
/// as a link between the nodes that the proxy represents.
///
/// To resolve the indirect links the ``IndirectLinkRewriter`` can be used.
///
public class Proxy: Node {
    override public init(id: OID?=nil, labels: LabelSet=LabelSet()) {
        super.init(id: id, labels: labels.union([Node.ProxyLabel]))
    }

    /// Link that is a representation of the proxy node.
    ///
    /// Representation link is an outgoing link from the proxy node
    /// which has a label ``Link/RepresentsLabel``.
    ///
    public var subjectLink: Link? { outgoing.first { $0.isSubject } }
    
    /// A node that the port represents. Must be from the same holon as the
    /// referencing port.
    ///
    public var subject: Node? { return subjectLink?.target }
    
    /// Get the final node that the port represents.
    public var finalNode: Node? {
        if let proxy = subject as? Proxy {
            return proxy.subject
        }
        else {
            return subject
        }
    }

    /// Links passing through the port
    var links: [Link] = []
    
//    /// Creates a port with a represented node.
//    ///
//    /// The represented node must be either a node from the same holon as the
//    /// referencing port or must be a port from a child holon.
//    ///
//    /// - Note: Precondition checking of the relationship between the port and the
//    /// represented node happens when the port is added to the graph. It is
//    /// up to the user to make sure that the condition is satisfied, otherwise
//    /// it is considered a programming error.
//    ///
//    public init(_ representedNode: Node) {
//        self.representedNode = representedNode
//    }

    /// Creates an unassociated copy of the node.
    ///
    override public func copy() -> Node {
        return Proxy(id: id, labels: labels)
    }

    
    public override var description: String {
        let subjectID: String
        if let subject = subject {
            subjectID = subject.idDebugString
        }
        else {
            subjectID = "(no subject)"
        }
        return "Proxy(id: \(idDebugString), subject: \(subjectID), labels: \(labels.sorted())])"
    }
}
