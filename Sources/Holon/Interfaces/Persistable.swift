//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 30/09/2022.
//


public protocol PersistableObject: Object, KeyedAttributes {
    /// Name of the type to be stored. The type name is then used to get a
    /// concrete type from ``PersistableGraphContext``.
    ///
    var persistableTypeName: String { get }
}

// TODO: Make all nodes and edges persistable
/// Protocol for objects that can be initialised from a dictionary.
public protocol PersistableNode: Node, PersistableObject {
    /// Creates a node from attribute dictionary.
    ///
    init(record: ForeignRecord, labels: LabelSet, id: OID?) throws
}

public protocol PersistableEdge: Edge, PersistableObject {
    /// Creates an edge from attribute dictionary.
    ///
    init(origin: Node, target: Node, record: ForeignRecord, labels: LabelSet, id: OID?) throws
}

public protocol GraphExporter {
    // TODO: Maybe write(nodes:edges:names:)?
    func export(from: Graph, names: [String:Node]) throws
}

public protocol Loader {
    /// Imports nodes and edges from into the specified graph.
    ///
    /// The importer returns a a name dictionary – external
    /// references to imported objects. Caller might use that information
    /// to do some post-loading object linking.
    ///
    /// - Parameters:
    ///   - graph: Graph into which the nodes and edges are to be imported.
    ///   - preserveIdentity: Flag whether the loader should preserve IDs from
    ///     the source and set the internal IDs to be the same.
    ///   - idGenerator: an object that generates IDs for newly created objects.
    ///
    /// It is up to the caller of this method how the linking of the named
    /// nodes is performed after the loading. For example the command-line tool
    /// uses a node named `batch` and links it with the catalog under the name
    /// `last_import`. ``TarotFileLoader`` provides a name `catalog` which
    /// points to a node representing a node catalog. This is used, for example,
    /// when loading a new graph into the graph manager. Can be used for
    /// merging two catalogs.
    ///
    /// - Tip: It is recommended that the importer returns at least one named
    /// node. Returned node represents the loaded batch, document or a
    /// collection of items. Suggested name is `batch` to make it work
    /// with the import command.
    ///
    /// Objects implementing the method should throw an
    /// ``ImporterError/preserveIdentityNotSupported`` error if they
    /// are asked to preserve identity but they can not preserve it. For
    /// example if there is no identity at the source.
    ///
    /// - Note: For the time being, the loaders preserving identity should
    /// throw an error if an object with supposed identity already exists.
    ///
    /// - Returns:Dictionary of named nodes that have been loaded. The
    /// keys are object names, the values are the nodes.
    ///
    func load(into: Graph,
              preserveIdentity: Bool,
              context: PersistableGraphContext) throws -> [String:Node]
}

/// Errors raised by objects conforming to ``Importer``.
///
/// Some of the cases have a custom context information value. This can be
/// a reference to a container in the source if there are multiple, or
/// location information into a file, or any other useful information
/// that the user can use to porentially correct the problem.
///
public enum LoadError: Error {
    /// Raised by the loader when it is asked to preserve identity of nodes
    /// or links and when the loader does not support the feature.
    case preserveIdentityNotSupported
        
    /// Source is missing an ID for a node or a link. The value is a custom
    /// context information.
    case missingSourceID(String)
    
    /// A duplicate ID at the source has been found – two nodes or two links
    /// at the source have the same ID.
    ///
    /// First value is the duplicate ID, the second value is a custom context
    /// information.
    case duplicateSourceID(CustomStringConvertible, String)

    /// The type of an ID in the source can not be converted to the internal
    /// ID.
    ///
    /// First value is the malformed ID, the second value is a custom context
    /// information.
    case sourceIDTypeMismatch(CustomStringConvertible, String)
    
    /// Record is missing a required attribute or a field.
    ///
    /// First value is an attribute name. The second value is a custom context
    /// information.
    case missingAttribute(String, String)
    
    /// A node with given key can not be find. The second value is a context of
    /// the node, for example a container, relation or a resource name.
    case unknownNode(CustomStringConvertible, String)
}

// TODO: Rename to "ExternalGraphContext" or exported, externalized, inout, ... something like that
public class PersistableGraphContext {
    public let idGenerator: IdentityGenerator

    public let nodeTypes: [String:PersistableNode.Type]
    public let defaultNodeType: PersistableNode.Type?
    public let edgeTypes: [String:PersistableEdge.Type]
    public let defaultEdgeType: PersistableEdge.Type?
    
    public init(idGenerator: IdentityGenerator? = nil,
         nodeTypes: [String:PersistableNode.Type] = [:],
         defaultNodeType: PersistableNode.Type? = nil,
         edgeTypes: [String:PersistableEdge.Type] = [:],
         defaultEdgeType: PersistableEdge.Type?) {

        self.idGenerator = idGenerator ?? SequentialIDGenerator()
        self.nodeTypes = nodeTypes
        self.defaultNodeType = defaultNodeType
        self.edgeTypes = edgeTypes
        self.defaultEdgeType = defaultEdgeType
    }
    public func nodeType(_ name: String) -> PersistableNode.Type? {
        return nodeTypes[name] ?? defaultNodeType
    }
    public func edgeType(_ name: String) -> PersistableEdge.Type? {
        return edgeTypes[name] ?? defaultEdgeType
    }
}

extension Graph {
    public var persistableNodes: [PersistableNode] {
        nodes.compactMap { $0 as? PersistableNode }
    }
    public var persistableEdges: [PersistableEdge] {
        edges.compactMap { $0 as? PersistableEdge }
    }
}
