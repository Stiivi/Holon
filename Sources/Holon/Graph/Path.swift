//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//


/// An object representing a sequence of links.
///
public class Path: Equatable {
    
    /// List of links that represent the path.
    public internal(set) var links: [Link]
    
    /// Creates a path from a list of links.
    ///
    /// - Precondition: Links must be not empty
    /// - Precondition: Path must be valid. See ``Path/isValid(_:)``.
    ///
    public init(_ links: [Link]) {
        precondition(links.count > 0, "Path must have at least one link")
        precondition(Path.isValid(links), "Path of links is invalid: \(links)")
        self.links = links
    }
    
    /// Returns `true` if the sequence of links is a valid path. Path is
    /// valid if the target of a link is origin of the link's successor in the
    /// sequence of links.
    ///
    public static func isValid(_ links: [Link]) -> Bool {
        guard links.count > 0 else {
            return false
        }
        
        var iterator = links.makeIterator()
        
        var current: Link = iterator.next()!
        while let link = iterator.next() {
            if current.target !== link.origin {
                return false
            }
            current = link
        }
        
        return true
    }
    
    /// Origin of the path – origin of the very first item in the path.
    public var origin: Node { links.first!.origin }

    /// Target of the path – target of the very last item in the path.
    public var target: Node { links.last!.target }
    
    public static func ==(lhs: Path, rhs: Path) -> Bool {
        return lhs.links == rhs.links
    }
}

extension Path: MutableCollection {
    public typealias Index = Array<Link>.Index
    public typealias Element = Link
    
    public var startIndex: Index { return links.startIndex }
    public var endIndex: Index { return links.endIndex }
    public func index(after index: Index) -> Index {
        return links.index(after: index)
    }

    public subscript(index: Index) -> Element {
        get {
            return links[index]
        }
        set(item) {
            return links[index] = item
        }
    }

}
