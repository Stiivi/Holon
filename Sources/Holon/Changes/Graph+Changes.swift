//
//  Holon+Changes.swift
//  
//
//  Created by Stefan Urbanek on 28/02/2022.
//

extension Graph {
    /// Apply the change to a graph and return a list of changes that would
    /// revert this change if applied in the order as returned.
    ///
    public func applyChange(_ change: GraphChange) -> [GraphChange] {
        switch change {
        case let .addNode(node):
            add(node)
            return [.removeNode(node)]

        case let .removeNode(node):
            let removed: [Link] = remove(node)
            let restore: [GraphChange] = removed.map { .addLink($0) }
            return [.addNode(node)] + restore

        case let .addLink(link):
            add(link)
            return [.removeLink(link)]
        case let .removeLink(link):
            disconnect(link: link)
            return [.addLink(link)]
        }
    }
}
