//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 24/07/2022.
//

/**
 
 Node/Edge states:
 
 - state(graph,id)
 - new(nil, nil): unassigned to a graph, being initialised
 - assigned(val, val): node belongs to a graph, as an id
 - detached(nil, val): node does not belong to a graph, but can be
   in an undo queue
 - 
 
 
 
 */

class ChangeCommand {
    
}

class GraphHistoryManager {
}
