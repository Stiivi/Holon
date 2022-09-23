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
    /// - Precondition: Edges must be not empty
    /// - Precondition: Path must be valid. See ``Path/isValid(_:)``.
    ///
    public init(_ edges: [Edge]) {
        precondition(edges.count > 0, "Path must have at least one edge")
        precondition(Path.isValid(edges), "Path of edges is invalid: \(edges)")
        self.edges = edges
    }
    
    /// Returns `true` if the sequence of edges is a valid path. Path is
    /// valid if the target of an edge is origin of the edge's successor in the
    /// sequence of edges.
    ///
    public static func isValid(_ edges: [Edge]) -> Bool {
        guard edges.count > 0 else {
            return false
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
    
    /// Origin of the path – origin of the very first item in the path.
    public var origin: Node { edges.first!.origin }

    /// Target of the path – target of the very last item in the path.
    public var target: Node { edges.last!.target }
    
    public static func ==(lhs: Path, rhs: Path) -> Bool {
        return lhs.edges == rhs.edges
    }
}

extension Path: MutableCollection {
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
        set(item) {
            return edges[index] = item
        }
    }

}
