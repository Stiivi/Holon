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


extension MutableGraphProtocol {
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
    @available(*, deprecated, message: "Create edge separately")
    @discardableResult
    public func connect(proxy proxyID: NodeID,
                        representing targetID: NodeID,
                        labels: LabelSet = [],
                        id: OID? = nil) -> Edge {
        let proxy = node(proxyID)!
        precondition(proxy.isProxy)
        
        precondition(!outgoing(proxyID).contains(where:{ $0.isSubject }),
                     "An edge from a proxy to its subject already exists")
        
        // TODO: Check for cycles
        
        let edge = Edge(origin: proxyID,
                        target: targetID,
                        labels: labels.union([IndirectionLabel.Subject]),
                        id: id)
        self.add(edge)
        return edge
    }
    
    /// Connects two nodes with indirection. If either origin or a target are
    /// ports, then the edge at that endpoint will be marked as indirect.
    ///
    @available(*, deprecated, message: "Create edge separately")
    public func connectIndirect(from originID: NodeID,
                                to targetID: NodeID,
                                labels: LabelSet=[],
                                id: OID?=nil) -> Edge {
        // TODO: Alternative names: connectWithIndirection, or flag: indirection: true
        let origin = node(originID)!
        let target = node(targetID)!
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
        let edge = Edge(origin: originID,
                        target: targetID,
                        labels: labels.union(additionalLabels),
                        id: id)
        self.add(edge)
        return edge
    }
}

extension GraphProtocol {
    /// List of all ports in the graph.
    ///
    public var proxies: [Node] {
        nodes.filter { $0.isProxy }
    }
    
    /// Get a path from a proxy node to the real subject. Real subject is a
    /// node that is referenced by a direct subject edge.
    ///
    /// The function follows all indirect edges from the provided proxy node
    /// until it finds a subject edge that direct.
    ///
    /// - Precondition: Node must be a proxy and indirection integrity must
    ///   be assured.
    ///
    public func realSubjectPath(_ proxy: Node) -> Path {
        // FIXME: Check for loops
        precondition(proxy.isProxy)
        
        var current = proxy
        let path = Path()
        
        while true {
            guard let edge = subjectEdge(current.id) else {
                break
            }
            
            // FIXME: Deal with this
            if edge.hasIndirectTarget {
                current = node(edge.target)!
                assert(!path.joins(current.id), "Path must not contain a loop")
            }
            path.append(edge)
            if !edge.hasIndirectTarget {
                break
            }
            
        }
        
        return path
    }

    /// Edge that is a representation of the proxy node.
    ///
    /// Representation edge is an outgoing edge from the proxy node
    /// which has a label ``IndirectionLabel/Subject``.
    ///
    public func subjectEdge(_ proxy: NodeID) -> Edge? {
        return self.outgoing(proxy).first { $0.isSubject }
    }
    /// A node that the port represents. This is a direct subject, not the
    /// real subject if the subject edge is indirect.
    ///
    /// To get the real subject use ``realSubjectPath()`` to get the
    /// path to the real subject traversing indirect subject edges.
    /// Target of the last edge, which can be retrieved using ``Path/target``,
    /// is the real subject.
    ///
    public func subject(_ proxy: NodeID) -> NodeID? {
        return subjectEdge(proxy)?.target
    }

}
