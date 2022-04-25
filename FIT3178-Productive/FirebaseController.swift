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
    var taskList: [ToDoTask]
    
    lazy var authController: Auth = {
        return Auth.auth()
    }()
    var database: Firestore
    var taskRef: CollectionReference?
    var usersRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    
    var currentEmail: String = ""
    var currentPassword: String = ""
    var userID = ""

    
    override init() {
        FirebaseApp.configure()
        database = Firestore.firestore()
        taskList = [ToDoTask]()
        super.init()
    }
    
    func addTask(taskTitle: String, taskDescription: String) -> ToDoTask {
        let task = ToDoTask()
        task.taskTitle = taskTitle
        task.taskDescription = taskDescription

        do {
            if let taskRef = try taskRef?.addDocument(from: task) {
                task.id = taskRef.documentID
            }
        } catch {
            print("Failed to serialize task")
        }

        return task
    }
    
    func deleteTask(task: ToDoTask) {
        if let taskID = task.id {
            taskRef?.document(taskID).delete()
        }
    }
    
    func getTaskById(_ id: String) -> ToDoTask? {
        for task in taskList {
            if task.id == id {
                return task
            }
        }

        return nil
    }
    
    
    func setupTaskListener() {
        self.taskRef = database.collection("Task")
        taskRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseTaskSnapshot(snapshot: querySnapshot)
        }
    }
    
    
    func parseTaskSnapshot(snapshot: QuerySnapshot) {
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
                taskList.insert(task, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                taskList[Int(change.oldIndex)] = task
            }
            else if change.type == .removed {
                taskList.remove(at: Int(change.oldIndex))
            }
            // need to invoke listener to make change appear
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.currentTask || listener.listenerType == ListenerType.all {
                    listener.onTaskChange(change: .update, tasks: taskList)
                }
            }
            
        }
    
    }
    
    func cleanup() {
        //
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .currentTask || listener.listenerType == .all {
            listener.onTaskChange(change: .update, tasks: taskList )
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
                let _ = try await self.usersRef?.addDocument(data: ["name": self.userID, "currentTasks": []])
                self.currentPassword = password
                self.currentEmail = email
                if self.taskRef == nil {
                    self.setupTaskListener()
                }
                listeners.invoke{ (listener) in
                    if listener.listenerType == ListenerType.auth || listener.listenerType == ListenerType.all {
                        listener.onAuthChange(change: .update, currentUser: self.currentUser!)
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
                self.currentPassword = password
                self.currentEmail = email
                if self.taskRef == nil {
                    self.setupTaskListener()
                }
                listeners.invoke{ (listener) in
                    if listener.listenerType == ListenerType.auth || listener.listenerType == ListenerType.all {
                        listener.onAuthChange(change: .update, currentUser: self.currentUser!)
                    }
                }
            }
            catch {
                print("Authentication failed with error \(String(describing: error))")
            }
        }
    }
}
