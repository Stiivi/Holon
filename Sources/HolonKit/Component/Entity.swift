//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 29/08/2022.
//


public class Entity: Identifiable {
    public typealias ID = OID
    public var id: ID

    public var components: ComponentSet
    
    public init(id: ID) {
        self.id = id
        self.components = ComponentSet()
    }
}
