//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 31/08/2022.
//

/*
 
 Required constraints:
 
 - UNIQUE: "Represents" outgoing
 - INVALID: "Represents" and "Indirect Origin"
 
 */


extension Graph {
    /// List of all ports in the graph.
    ///
    public var proxies: [Node] {
        nodes.filter { $0.isProxy }
    }

    /// Connects a proxy node to its subject.
    ///
    /// Creates a properly annotated edge between the proxy object and its
    /// subject. Edge created this way can be used to resolve indirect edges
    /// into direct edges.
    ///
    /// See also: ``Graph/connect(from:to:labels:id:)``
    ///
    /// - Precondition: Proxy must be a proxy node.
    /// - Precondition: Proxy must not already contain an edge to its subject.
    ///
    @discardableResult
    public func connect(proxy: Node,
                        representing target: Node,
                        labels: LabelSet = [],
                        id: OID? = nil) -> Edge {
        precondition(proxy.isProxy)
        precondition(!outgoing(proxy).contains(where:{ $0.isSubject }),
        "An edge from a proxy to its subject already exists")

        // TODO: Check for cycles
        
        return connect(from: proxy,
                       to: target,
                       labels: labels.union([IndirectionLabel.Subject]),
                       id: id)
    }

    /// Connects two nodes with indirection. If either origin or a target are
    /// ports, then the edge at that endpoint will be marked as indirect.
    ///
    public func connectIndirect(from origin: Node,
                                to target: Node,
                                labels: LabelSet=[],
                                id: OID?=nil) -> Edge {
        // TODO: Check for cycles
        let additionalLabels: LabelSet
        if origin.isProxy && target.isProxy {
            additionalLabels = Set([IndirectionLabel.IndirectOrigin, IndirectionLabel.IndirectTarget])
        }
        else if origin.isProxy {
            additionalLabels = Set([IndirectionLabel.IndirectOrigin])
        }
        else if target.isProxy {
            additionalLabels = Set([IndirectionLabel.IndirectTarget])
        }
        else {
            additionalLabels = Set()
        }
        return connect(from: origin,
                       to: target,
                       labels: labels.union(additionalLabels),
                       id: id)
    }
}
