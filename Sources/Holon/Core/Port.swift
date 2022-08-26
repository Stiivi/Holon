//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 23/08/2022.
//

import Foundation

/// Node that represents another node from within a holon.
///
/// Port belongs to a holon and represents a node from the same holon. If
/// a connection is made that follows ports, then the new connection is created
/// in a way that it connects the represented object of the port. If the
/// represented object of the port is another port, then it is followed through
/// until a non-port object is reached.
///
public class Port: Node {
    /// A node that the port represents. Must be from the same holon as the
    /// referencing port.
    ///
    public private(set) var representedNode: Node
    
    /// Get the final node that the port represents.
    public var finalNode: Node {
        if let port = representedNode as? Port {
            return port.representedNode
        }
        else {
            return representedNode
        }
    }
    
    /// Links passing through the port
    var links: [Link] = []
    
    /// Creates a port with a represented node.
    ///
    /// The represented node must be either a node from the same holon as the
    /// referencing port or must be a port from a child holon.
    ///
    /// - Note: Precondition checking of the relationship between the port and the
    /// represented node happens when the port is added to the graph. It is
    /// up to the user to make sure that the condition is satisfied, otherwise
    /// it is considered a programming error.
    ///
    public init(_ representedNode: Node) {
        self.representedNode = representedNode
    }

    public override var description: String {
        let idString = id.map { String($0) } ?? "nil"
        let roidString = representedNode.id.map { String($0) } ?? "nil"

        return "Port(id: \(idString), target: \(roidString), labels: \(labels.sorted())])"
    }
}
