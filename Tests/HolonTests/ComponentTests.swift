//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 23/11/2022.
//

import Foundation

import XCTest
@testable import Holon


struct NameComponent: Component {
    var name: String
}

extension Node {
    var nameComponent: NameComponent {
        get {
            self[NameComponent.self]!
        }
        set(comp) {
            self[NameComponent.self] = comp
        }
    }
}

final class ComponentTests: XCTestCase {
    func testBasic() {
        let node = Node(NameComponent(name: "Alice"))
        
        let comp: NameComponent = node[NameComponent.self]!
        XCTAssertEqual(comp.name, "Alice")

        node[NameComponent.self]!.name = "Bob"
        let comp2: NameComponent = node[NameComponent.self]!
        XCTAssertEqual(comp2.name, "Bob")
    }
    func testWrapped() {
        let node = Node(NameComponent(name: "Alice"))
        
        XCTAssertEqual(node.nameComponent.name, "Alice")

        node.nameComponent.name = "Bob"
        let comp2: NameComponent = node[NameComponent.self]!
        XCTAssertEqual(comp2.name, "Bob")
    }
    
    func testClone() {
        let node = Node(NameComponent(name: "Alice"))
        let clone = node.clone()

        XCTAssertEqual(clone.nameComponent.name, "Alice")

        node.nameComponent.name = "Bob"
        clone.nameComponent.name = "Cecil"

        let nameOrig: NameComponent = node[NameComponent.self]!
        XCTAssertEqual(nameOrig.name, "Bob")

        let nameClone: NameComponent = clone[NameComponent.self]!
        XCTAssertEqual(nameClone.name, "Cecil")
    }
}
