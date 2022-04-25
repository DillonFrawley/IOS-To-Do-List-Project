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
    var taskList: [Task]
    
    var authController: Auth
    var database: Firestore
    var taskRef: CollectionReference?
//    var currentUser: FirebaseAuth.User?
    
    
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
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        taskList = [Task]()
        super.init()
        Task {
            do {
                let authDataResult = try await authController.signInAnonymously()
            }
            catch {
                fatalError("Firebase Authentication Failed with Error \(String(describing: error))")
               }
           self.setupTaskListener()
           }

    }
    
    func addTask(taskTitle: String, taskDescription: String) -> Task {
        let task = Task()
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
    
    func deleteTask(task: Task) {
        if let taskID = task.id {
            taskRef?.document(taskID).delete()
        }
    }
    
    func getTaskById(_ id: String) -> Task? {
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
            var parsedTask: Task?
    
            do {
                parsedTask = try change.document.data(as: Task.self)
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
}
