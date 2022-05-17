//
//  DatabaseProtocol.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import CoreLocation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case currentAndCompletedTasks
    case allTasks
    case auth
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask])
    func onAuthChange(change: DatabaseChange, currentUser: FirebaseAuth.User?)
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask])
}

protocol DatabaseProtocol: AnyObject {
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addTask(taskTitle: String, taskDescription: String, taskType: String, coordinate: CLLocationCoordinate2D?, seconds: Int, minutes: Int, hours: Int)
    func updateTask(taskId: String, taskTitle: String, taskDescription: String, taskType: String, coordinate: CLLocationCoordinate2D?, seconds: Int, minutes: Int, hours: Int)
    func deleteTask(task : ToDoTask, taskType: String)
    
//    func getTaskById(_ id: String) -> ToDoTask?
    func signIn( email: String, password: String)
    func createNewSignIn( email: String, password: String)
    var currentUser: FirebaseAuth.User? {get set}
    var currentDate: String? {get set}
    var currentLocation: CLLocationCoordinate2D? {get set}
    
    func setupTaskListener()
    
}
