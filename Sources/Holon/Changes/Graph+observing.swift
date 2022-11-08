//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/11/2022.
//

public protocol GraphObserver {
    func graphWillChange(graph: Graph, change: GraphChange)
}

#if canImport(Combine)
import Combine

/// Type of a publisher that publishes graph changes.
///
@available(macOS 10.15, *)
public typealias GraphChangePublisher = PassthroughSubject<GraphChange,Never>

/// Observer that publishes changes using a ``Publisher``.
///
@available(macOS 10.15, *)
public class PublishingObserver: GraphObserver {
    /// Publisher that publishes all graph changes.
    ///
    public let publisher: GraphChangePublisher
    
    
    public init() {
        self.publisher = GraphChangePublisher()
    }
    
    public func graphWillChange(graph: Graph, change: GraphChange) {
        publisher.send(change)
    }
}

@available(macOS 10.15, *)
extension Graph {
    public var willChangePublisher:GraphChangePublisher? {
        (self.observer as? PublishingObserver)?.publisher
    }
}

#endif
