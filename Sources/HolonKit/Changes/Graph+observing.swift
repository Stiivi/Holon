//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 06/11/2022.
//

public protocol WorldObserver {
    func graphWillChange(world: World, change: GraphChange)
}

#if canImport(Combine)
import Combine

/// Type of a publisher that publishes graph changes.
///
@available(macOS 10.15, *)
public typealias WorldChangePublisher = PassthroughSubject<GraphChange,Never>

/// Observer that publishes changes using a ``Publisher``.
///
@available(macOS 10.15, *)
public class PublishingObserver: WorldObserver {
    /// Publisher that publishes all graph changes.
    ///
    public let publisher: WorldChangePublisher
    
    
    public init() {
        self.publisher = WorldChangePublisher()
    }
    
    public func graphWillChange(world: World, change: GraphChange) {
        publisher.send(change)
    }
}

@available(macOS 10.15, *)
extension World {
    public var willChangePublisher:WorldChangePublisher? {
        (self.observer as? PublishingObserver)?.publisher
    }
}

#endif
