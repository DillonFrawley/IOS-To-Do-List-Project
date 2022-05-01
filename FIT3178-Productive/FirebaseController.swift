//
//  FirebaseController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift


class FirebaseController: NSObject, DatabaseProtocol {
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var allTaskList: [ToDoTask]
    var currentTasks: [ToDoTask]
    var completedTasks: [ToDoTask]
    
    lazy var authController: Auth = {
        return Auth.auth()
    }()
    var database: Firestore
    var usersRef: CollectionReference?
    var allTasksRef: CollectionReference?
    var currentTaskRef: CollectionReference?
    var completedTaskRef: CollectionReference?
    var taskRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    var userID: String?

    
    override init() {
        FirebaseApp.configure()
        database = Firestore.firestore()
        taskList = [ToDoTask]()
        super.init()
        if authController.currentUser != nil {
            self.currentUser = authController.currentUser
            guard let userID = authController.currentUser?.uid else { return }
            self.userID = userID
            self.usersRef = self.database.collection("Users")
            self.setupTaskListener()
        }
        
    }
    
    func addTask(taskTitle: String, taskDescription: String, taskType: String) -> ToDoTask {
        let task = ToDoTask()
        task.taskTitle = taskTitle
        task.taskDescription = taskDescription
        if taskType == "allTasks" {
            do {
                if let taskRef = try self.allTasksRef?.addDocument(from: task) {
                    task.id = taskRef.documentID
                }
            } catch {
                print("Failed to serialize task")
            }
        }
        else if taskType == "current" {
            do {
                if let taskRef = try self.currentTaskRef?.addDocument(from: task) {
                    task.id = taskRef.documentID
                }
            } catch {
                print("Failed to serialize task")
            }
        }
        else if taskType == "completed" {
            do {
                if let taskRef = try self.completedTaskRef?.addDocument(from: task) {
                    task.id = taskRef.documentID
                }
            } catch {
                print("Failed to serialize task")
            }
        }
        return task
    }
    
    func deleteTask(task: ToDoTask, taskType: String) {
        if taskType == "allTasks" {
            if let taskID = task.id {
                self.allTasksRef?.document(taskID).delete()
            }
        }
        else if taskType == "current" {
            if let taskID = task.id {
                self.currentTaskRef?.document(taskID).delete()
            }
        }
        else if taskType == "completed" {
            if let taskID = task.id {
                self.completedTaskRef?.document(taskID).delete()
            }
        }
        
    }
    
//    func getTaskById(_ id: String) -> ToDoTask? {
//        for task in taskList {
//            if task.id == id {
//                return task
//            }
//        }
//
//        return nil
//    }
    
    
    func setupTaskListener() {
        self.allTasksRef = self.usersRef?.document((self.userID)!).collection("allTasks")
        self.currentTaskRef = self.usersRef?.document((self.userID)!).collection("currentTasks")
        self.completedTaskRef = self.usersRef?.document((self.userID)!).collection("completedTasks")
        
        allTasksRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseTaskSnapshot(snapshot: querySnapshot, taskType: "allTasks")
        }
    }

    
    
    func parseTaskSnapshot(snapshot: QuerySnapshot, taskType: String) {
        if taskType == "allTasks" {
            snapshot.documentChanges.forEach { (change) in
                var parsedTask: ToDoTask?
        
                do {
                    parsedTask = try change.document.data(as: ToDoTask.self)
                } catch {
                    print("Unable to decode task")
                    return
                }
                
                guard let task = parsedTask else {
                    print("Document doesn't exist")
                    return
                }
                
                if change.type == .added {
                    allTaskList.insert(task, at: Int(change.newIndex))
                }
                else if change.type == .modified {
                    allTaskList[Int(change.oldIndex)] = task
                }
                else if change.type == .removed {
                    allTaskList.remove(at: Int(change.oldIndex))
                }
                // need to invoke listener to make change appear
                listeners.invoke { (listener) in
                    if listener.listenerType == ListenerType.allTasks || listener.listenerType == ListenerType.all {
                        listener.onTaskChange(change: .update, tasks: allTaskList)
                    }
                }
                
            }
        }
        else if taskType == "current" {
            snapshot.documentChanges.forEach { (change) in
                var parsedTask: ToDoTask?
        
                do {
                    parsedTask = try change.document.data(as: ToDoTask.self)
                } catch {
                    print("Unable to decode task")
                    return
                }
                
                guard let task = parsedTask else {
                    print("Document doesn't exist")
                    return
                }
                
                if change.type == .added {
                    currentTasks.insert(task, at: Int(change.newIndex))
                }
                else if change.type == .modified {
                    currentTasks[Int(change.oldIndex)] = task
                }
                else if change.type == .removed {
                    currentTasks.remove(at: Int(change.oldIndex))
                    }
                }
            // need to invoke listener to make change appear
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.currentTask || listener.listenerType == ListenerType.all {
                    listener.onTaskChange(change: .update, tasks: currentTasks)
                }
            
            }
        }
        else if taskType == "completed" {
            snapshot.documentChanges.forEach { (change) in
                var parsedTask: ToDoTask?
        
                do {
                    parsedTask = try change.document.data(as: ToDoTask.self)
                } catch {
                    print("Unable to decode task")
                    return
                }
                
                guard let task = parsedTask else {
                    print("Document doesn't exist")
                    return
                }
                
                if change.type == .added {
                    completedTasks.insert(task, at: Int(change.newIndex))
                }
                else if change.type == .modified {
                    completedTasks[Int(change.oldIndex)] = task
                }
                else if change.type == .removed {
                    completedTasks.remove(at: Int(change.oldIndex))
                    }
                }
            // need to invoke listener to make change appear
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.currentTask || listener.listenerType == ListenerType.all {
                    listener.onTaskChange(change: .update, tasks: completedTasks)
                }
            }
        }
    
    }
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .currentTask || listener.listenerType == .all {
            listener.onTaskChange(change: .update, tasks: currentTasks )
        }
        else if listener.listenerType == .allTasks || listener.listenerType == .all {
            listener.onTaskChange(change: .update, tasks: allTaskList )
        }
        else if listener.listenerType == .completedTask || listener.listenerType == .all {
            listener.onTaskChange(change: .update, tasks: completedTasks )
        }
        else if listener.listenerType == .auth {
            listener.onAuthChange(change: .update, currentUser: self.currentUser)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func createNewSignIn( email: String, password: String) {
        Task {
            do {
                let authDataResult = try await authController.createUser(withEmail: email ,password: password )
                // The user was logged in, so do something!
                currentUser = authDataResult.user
                guard let userID = Auth.auth().currentUser?.uid else { return }
                self.userID = userID
                self.usersRef = self.database.collection("Users")
                let _ = try await self.usersRef?.document((self.userID)!).setData(["name": (self.userID)!])
                self.setupTaskListener()
                listeners.invoke{ (listener) in
                    if listener.listenerType == ListenerType.auth {
                        listener.onAuthChange(change: .update, currentUser: (self.currentUser)!)
                    }
                }
            }
            catch {
                print("User creation failed with error \(String(describing: error))")
            }
        }
    }
    
    func signIn( email: String, password: String) {
        Task {
            do {
                let authDataResult = try await authController.signIn(withEmail: email,password: password)
                // User is now logged in, so do something!
                currentUser = authDataResult.user
                guard let userID = Auth.auth().currentUser?.uid else { return }
                self.userID = userID
                self.setupTaskListener()
                listeners.invoke{ (listener) in
                    if listener.listenerType == ListenerType.auth {
                        listener.onAuthChange(change: .update, currentUser: (self.currentUser)!)
                    }
                }
            }
            catch {
                print("Authentication failed with error \(String(describing: error))")
            }
        }
    }
}
