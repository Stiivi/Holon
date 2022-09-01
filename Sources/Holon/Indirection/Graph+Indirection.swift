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
    public var proxies: [Proxy] {
        nodes.compactMap { return $0 as? Proxy }
    }

    /// Connects a proxy node to its subject.
    ///
    /// Creates a properly annotated link between the proxy object and its
    /// subject. Link created this way can be used to resolve indirect links
    /// into direct links.
    ///
    /// See also: ``Graph/connect(from:to:labels:id:)``
    ///
    /// - Precondition: Proxy must not already contain a link to its subject.
    ///
    @discardableResult
    public func connect(proxy: Proxy,
                        representing target: Node,
                        labels: LabelSet = [],
                        id: OID? = nil) -> Link {
        precondition(!outgoing(proxy).contains(where:{ $0.isSubject }),
        "A link from a proxy to its subject already exists")

        // TODO: Check for cycles
        
        return connect(from: proxy,
                       to: target,
                       labels: labels.union([Link.SubjectLabel]),
                       id: id)
    }

    /// Connects two nodes with indirection. If either origin or a target are
    /// ports, then the link at that endpoint will be marked as indirect.
    ///
    public func connectIndirect(from origin: Node,
                        to target: Node,
                        labels: LabelSet=[],
                        id: OID?=nil) -> Link {
        let additionalLabels: LabelSet
        if origin.isProxy && target.isProxy {
            additionalLabels = Set([Link.IndirectOriginLabel, Link.IndirectTargetLabel])
        }
        else if origin.isProxy {
            additionalLabels = Set([Link.IndirectOriginLabel])
        }
        else if target.isProxy {
            additionalLabels = Set([Link.IndirectTargetLabel])
        }
        else {
            additionalLabels = Set()
        }
        return connect(from: origin,
                       to: target,
                       labels: labels.union(additionalLabels),
                       id: id)
    }
    
    /// Returns a path towards final representation of a node.
    ///
    /// Representation path is a path of links where the target is represented
    /// by another node.
    ///
    /// Each node can have only one node it directly represents.
    ///
    public func proxyPath(_ node: Node) -> Path {
        var current = node
        var links: [Link] = []
        
        while true {
            // Get the next reference link
            guard let link = outgoing(current).first(where: { $0.isSubject }) else {
                break
            }
            // Append the link to the list of traversed links
            links.append(link)
            if link.hasIndirectTarget {
                current = link.target
            }
            else {
                break
            }
        }

        // TODO: Remove this assert and add it somewhere else as a constraint check
        assert(links.count != 0)
        
        return Path(links)
    }
}
