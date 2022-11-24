//
//  File.swift
//
//
//  Created by Stefan Urbanek on 2021/10/10.
//

/// Type for graph object identifier. There should be no expectation about
/// the value of the identifier.
///
public typealias OID = Object.ID


// TODO: Consider to distinguish 'id' (in-app session) and 'persistentID'

/// An abstract class representing all objects in a graph. Concrete
/// kinds of graph objects are ``Node`` and ``Edge``.
///
/// Each graph objects has a unique identity within the graph.
///
/// All object's attributes are optional. It is up to the user to add
/// constraints or validations for the attributes of graph objects.
///
public class Object: Identifiable, CustomStringConvertible {
    static let defaultIDGenerator = SequentialIDGenerator()
    
    public typealias ID = UInt64
    // TODO: Lifetime: static, dynamic, ephemeral
    
    /// World the object is associated with.
    ///
    public internal (set) var world: World?
    

    /// A set of labels.
    ///
    public internal (set) var labels: LabelSet = []
   
    public internal (set) var components: ComponentSet
    
    /// Identifier of the object that is unique within the owning graph.
    ///
    /// The identifier can be set only when the object is not associated
    /// with a graph. Otherwise it is a serious programming error.
    ///
    public var id: OID {
        willSet(newID) {
            precondition(world == nil)
        }
    }
    

    // TODO: Make this private. Use Holon.create() and Holon.connect()
    /// Create an empty object. The object needs to be associated with a graph.
    ///
    /// If the ID is not provided, one will be assigned. The assigned ID is
    /// assumed to be unique for every object created without explicit ID,
    /// however it is not assumed to be unique with explicitly provided IDs.
    ///
    public init(id: OID?=nil, labels: LabelSet=[], components: [any Component]) {
        self.id = id ?? Object.defaultIDGenerator.next()
        self.labels = labels
        self.components = ComponentSet()
        self.components.set(components)
    }
    
    public convenience init(id: OID?=nil, labels: LabelSet=[], components: any Component...) {
        self.init(id: id, labels: labels, components: components)
    }

    /// Returns `true` if the object contains the given label.
    ///
    public func contains(label: Label) -> Bool {
        return labels.contains(label)
    }
    
    /// Returns `true` if the object contains all of the labels.
    ///
    public func contains(labels: LabelSet) -> Bool {
        return labels.isSubset(of: self.labels)
    }

    /// Sets object label.
    ///
    /// - Parameters:
    ///     - label: Label to be added to the set of labels associated with
    ///       the graph object. If the label already exists, nothing happens.
    ///
    public func set(label: Label) {
//        self.graph?.willChange(.setLabel(self, label))
        labels.insert(label)
    }
    
    /// Unsets object label.
    ///
    /// - Parameters:
    ///     - label: Label to be removed from the set of labels associated with
    ///       the graph object. If the label is not present, nothing happens.
    ///
    public func unset(label: Label) {
//        self.graph?.willChange(.unsetLabel(self, label))
        labels.remove(label)
    }
   
    /// Notifies the graph observer that an attribute of the graph object is
    /// about to be changed.
    ///
    /// Call this method for each observable property:
    ///
    /// ```swift
    /// public class Comment: Node {
    ///     public var text: String {
    ///         willSet {
    ///             self.willChangeAttribute("text", value: newValue)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This is part of a light-weight graph change observation
    ///   mechanism. We are not using Apple's Combine framework here for
    ///   portability reasons. This decision might be reconsidered in the
    ///   future.
    ///
    public func willChangeAttribute(_ key: String, value: any ValueProtocol) {
//        self.graph?.willChange(.setAttribute(self, key, value))
    }
    
    open var description: String {
        return "Object(id: \(idDebugString), labels: \(labels.sorted())])"
    }
    
    /// String representing the object's ID for debugging purposes - either the
    /// object ID or ObjectIdentifier of the object
    public var idDebugString: String {
        // TODO: This method is no longer needed
        return String(id)
    }
    
    // MARK: - Prototyping/Experimental

    open var attributeKeys: [AttributeKey] {
        return []
    }
    
    open func attribute(forKey key: String) -> (any AttributeValue)? {
        return nil
    }
    
    open func setAttribute(value: any AttributeValue, forKey key: AttributeKey) {
        fatalError("Object \(type(of:self)) does not have an attribute '\(key)'")
    }
}


/// A set of nodes and edges.
///
//public struct GraphObjectSet: Collection {
//    // TODO: This needs attention
//    public typealias Index = Array<Object>.Index
//    public typealias Element = Object
//    public let objects: [Object]
//    
//    public init(nodes: [Node] = [], edges: [Edge] = []) {
//        self.nodes = nodes
//        self.edges = edges
//    }
//    
//    public var startIndex: Index { return edges.startIndex }
//    public var endIndex: Index { return edges.endIndex }
//
//    
//}
