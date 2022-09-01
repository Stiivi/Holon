//
//  File.swift
//
//
//  Created by Stefan Urbanek on 2021/10/10.
//

/// Type for graph object identifier. There should be no expectation about
/// the value of the identifier.
///
public typealias OID = Int

/// An abstract class representing all objects in a graph. Concrete
/// kinds of graph objects are ``Node`` and ``Link``.
///
/// Each graph objects has a unique identity within the graph.
///
/// All object's attributes are optional. It is up to the user to add
/// constraints or validations for the attributes of graph objects.
///
open class Object: Identifiable, CustomStringConvertible {
    
    // TODO: Lifetime: static, dynamic, ephemeral
    
    /// Graph the object is associated with.
    ///
    public internal(set) var graph: Graph?
    

    /// A set of labels.
    ///
    public internal (set) var labels: LabelSet = []
    
    /// Identifier of the object that is unique within the owning graph.
    /// The attribute is populated when the object is associated with a graph.
    /// When the object is disassociate from a graph, the identifier is set to
    /// `nil`.
    ///
    public var id: OID?
    //    public internal(set) var id: OID?
    

    // TODO: Make this private. Use Holon.create() and Holon.connect()
    /// Create an empty object. The object needs to be associated with a graph.
    ///
    public init(id: OID?=nil, labels: LabelSet=[]) {
        self.id = id
        self.labels = labels
    }

//    /// List of initial labels for a given graph object. Subclasses might
//    /// override this method to provide set of default initial labels that
//    /// will be set for that particular subclass. Default implementation
//    /// returns an empty set.
//    ///
//    public func initialLabels() -> LabelSet {
//        return []
//    }
    
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
    public func set(label: Label) {
        labels.insert(label)
    }
    
    /// Unsets object label.
    public func unset(label: Label) {
        labels.remove(label)
    }
    
    open var description: String {
        return "Object(id: \(idDebugString), labels: \(labels.sorted())])"
    }
    
    /// String representing the object's ID for debugging purposes - either the
    /// object ID or ObjectIdentifier of the object
    var idDebugString: String {
        if let id = id {
            return String(id)
        }
        else {
            return String(describing: ObjectIdentifier(self))
        }
    }
    
    // MARK: - Prototyping/Experimental

    open var attributeKeys: [AttributeKey] {
        return []
    }
    
    open func attribute(forKey key: String) -> AttributeValue? {
        return nil
    }
}


/// A set of nodes and links.
///
//public struct GraphObjectSet: Collection {
//    // TODO: This needs attention
//    public typealias Index = Array<Object>.Index
//    public typealias Element = Object
//    public let objects: [Object]
//    
//    public init(nodes: [Node] = [], links: [Link] = []) {
//        self.nodes = nodes
//        self.links = links
//    }
//    
//    public var startIndex: Index { return links.startIndex }
//    public var endIndex: Index { return links.endIndex }
//
//    
//}
