//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 2021/11/30.
//
/// Representation of a change within a graph.
///
/// - Attention: Unused for now.
///
/// - ToDo: Currently unused, just ported from another library and needs
///         to be adopted back again.
///
///
public enum GraphChange: Equatable {
    // ``GraphChange`` is used for observation of changes. Instances are being
    // sent in the observation process through methods such as ``Holon/observe()``,
    // ``Holon/observeNeighbourhood(node:)`` or ``Holon/observeAttributes(object:)``.

    // TODO: Add case holonMoved(Holon, to: Holon)
    
    /// A change that represents node addition.
    ///
    case addNode(Node)
    
    /// A change that represents node removal.
    ///
    case removeNode(Node)

    /// Denotes a change to a graph when an edge was created.
    ///
    case addEdge(Edge)

    /// Denotes a change to a graph when an edge was removed.
    ///
    case removeEdge(Edge)
    
    /// Denotes a change to a graph object - either a node or an edge - where
    /// an attribute was set to a new, non-nil value.
    ///
    case setAttribute(Object, AttributeKey, any ValueProtocol)

//    /// Denotes a change to a graph object - either a node or an edge - where
//    /// an attribute was removed or set to a `nil` value.
//    ///
//    case unsetAttribute(Object, AttributeKey)

    case setLabel(Object, Label)
    case unsetLabel(Object, Label)
    
    /// Returns `true` if the change is related to given object. For node
    /// removal, node addition and attribute changes the object is related
    /// is the only objects of the change. For connection and disconnection
    /// changes the object is related if the object is the edge, origin or
    /// a target of the edge.
    ///
    public func isRelated(_ object: Object) -> Bool {
        switch self {
        case let .addNode(node): return node === object
        case let .removeNode(node): return node === object
        case let .addEdge(edge): return edge === object || edge.origin === object || edge.target === object
        case let .removeEdge(edge): return edge === object || edge.origin === object || edge.target === object
        case let .setLabel(another, _): return another === object
        case let .unsetLabel(another, _): return another === object
        case let .setAttribute(another, _, _): return another === object
        }
    }
    
    /// Compare two changes. Two graph changes are equal if they are of the same
    /// type, when the graph objects are identical and when the rest of
    /// compared change attributes are equal.
    /// 
    public static func ==(lhs: GraphChange, rhs: GraphChange) -> Bool {
        switch (lhs, rhs) {
        case let (.addNode(lnode), .addNode(rnode)):
            return lnode === rnode
        case let (.removeNode(lnode), .removeNode(rnode)):
            return lnode === rnode
        case let (.addEdge(ledge), .addEdge(redge)):
            return ledge === redge
        case let (.removeEdge(ledge), .removeEdge(redge)):
            return ledge === redge
        case let (.setLabel(lobj, llabel), .setLabel(robj, rlabel)):
            return lobj === robj && llabel == rlabel
        case let (.unsetLabel(lobj, llabel), .unsetLabel(robj, rlabel)):
            return lobj === robj && llabel == rlabel
        case let (.setAttribute(lobj, lattr, lvalue), .setAttribute(robj, rattr, rvalue)):
            return lobj === robj && lattr == rattr && lvalue.isEqual(to: rvalue)
        default: return false
        }
    }
}
