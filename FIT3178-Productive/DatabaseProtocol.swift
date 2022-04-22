//
//  DatabaseProtocol.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case task
    case currentTask
    case completedTask
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    
    
}
