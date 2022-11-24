//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/10/20.
//

// TODO: Node should be in World, not Holon, so we can benefit from the semantics

/// Object representing a node of a graph.
///
public class Node: Object {
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
    public convenience init(id: OID?=nil,
                labels: LabelSet=LabelSet(),
                role: Role = .`default`,
                _ components: any Component...) {
        self.init(id: id,
                  labels: labels,
                  role: role,
                  components)
    }
    /// Create a node with a special role.
    ///
    public init(id: OID?=nil,
                labels: LabelSet=LabelSet(),
                role: Role = .`default`,
                _ components: [any Component]) {
        // TODO: Reconsider existence of this initializer
        // – we are just assigning some system labels, which can be removed
        //   later anyway.
        if let label = role.label {
            super.init(id: id,
                       labels: labels.union([label]),
                       components: components)
        }
        else {
            super.init(id: id,
                       labels: labels,
                       components: components)
        }
    }
    /// Duplicates a node to create a new node.
    ///
    /// All components are copied. The newly created duplicate will have the
    /// id set to nil if not provided or set to the provided id. The duplicate
    /// will not be associated with a world.
    ///
    /// The caller is responsible for providing an id and associating the clone
    /// with a world.
    ///

    public func clone(id: OID? = nil) -> Node {
        return Node(id: id,
                    labels: self.labels,
                    self.components.components)
    }

    public subscript(componentType: Component.Type) -> (Component)? {
        get {
            return components[componentType]
        }
        set(component) {
            components[componentType] = component
        }
    }
    public subscript<T>(componentType: T.Type) -> T? where T : Component {
        get {
            return components[componentType]
        }
        set(component) {
            components[componentType] = component
        }
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

