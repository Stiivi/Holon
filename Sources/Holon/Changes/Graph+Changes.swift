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
            let removed: [Edge] = remove(node)
            let restore: [GraphChange] = removed.map { .addEdge($0) }
            return [.addNode(node)] + restore

        case let .addEdge(edge):
            add(edge)
            return [.removeEdge(edge)]
        case let .removeEdge(edge):
            remove(edge)
            return [.addEdge(edge)]
        case let .setLabel(object, label):
            object.set(label: label)
            return [.unsetLabel(object, label)]
        case let .unsetLabel(object, label):
            object.unset(label: label)
            return [.setLabel(object, label)]
        case let .setAttribute(object, key, value):
            let previous = object.attribute(forKey: key)!
            object.setAttribute(value: value, forKey: key)
            return [.setAttribute(object, key, previous)]
        }
    }
}
