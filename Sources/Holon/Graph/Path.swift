//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//


/// An object representing a sequence of edges.
///
public class Path: Equatable {
    
    /// List of edges that represent the path.
    public internal(set) var edges: [Edge]
    
    /// Creates a path from a list of edges.
    ///
    /// - Precondition: Path must be valid. See ``Path/isValid(_:)``.
    ///
    public init(_ edges: [Edge] = []) {
        precondition(Path.isValid(edges), "Path of edges is invalid: \(edges)")
        self.edges = edges
    }
    
    /// Returns `true` if the sequence of edges is a valid path. Path is
    /// valid if the target of an edge is origin of the edge's successor in the
    /// sequence of edges.
    ///
    /// Empty path is a valid path.
    ///
    public static func isValid(_ edges: [Edge]) -> Bool {
        guard edges.count > 0 else {
            return true
        }
        
        var iterator = edges.makeIterator()
        
        var current: Edge = iterator.next()!
        while let edge = iterator.next() {
            if current.target !== edge.origin {
                return false
            }
            current = edge
        }
        
        return true
    }
    
    /// Appends an edge to the path.
    ///
    /// - Precondition: Edge's origin must be path's last target.
    ///
    public func append(_ edge: Edge) {
        if let last = edges.last {
            precondition(last.target === edge.origin)
        }
        edges.append(edge)
    }
    
    /// Origin of the path – origin of the very first item in the path.
    public var origin: Node { edges.first!.origin }

    /// Target of the path – target of the very last item in the path.
    public var target: Node { edges.last!.target }
    
    public static func ==(lhs: Path, rhs: Path) -> Bool {
        return lhs.edges == rhs.edges
    }
    
    /// Returns true if the path traverses through `node`.
    ///
    public func joins(_ node: Node) -> Bool {
        return edges.contains {
            $0.origin === node || $0.target === node
        }
    }
}

extension Path: Collection {
    public typealias Index = Array<Edge>.Index
    public typealias Element = Edge
    
    public var startIndex: Index { return edges.startIndex }
    public var endIndex: Index { return edges.endIndex }
    public func index(after index: Index) -> Index {
        return edges.index(after: index)
    }

    public subscript(index: Index) -> Element {
        get {
            return edges[index]
        }
    }

}
