//
//  FirebaseController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreLocation


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
    var dateRef: CollectionReference?
    var allTasksRef: CollectionReference?
    var currentTaskRef: CollectionReference?
    var completedTaskRef: CollectionReference?
    var taskRef: CollectionReference?
    var currentUser: FirebaseAuth.User?
    var currentDate: String?
    var userID: String?

    
    override init() {
        FirebaseApp.configure()
        database = Firestore.firestore()
        allTaskList = [ToDoTask]()
        currentTasks = [ToDoTask]()
        completedTasks = [ToDoTask]()
        if self.currentDate == nil {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.short
            let strDate = dateFormatter.string(from: date)
            self.currentDate = strDate.replacingOccurrences(of: "/", with: "-")
        }
        
        super.init()
        if authController.currentUser != nil {
            self.currentUser = authController.currentUser
            guard let userID = authController.currentUser?.uid else { return }
            self.userID = userID
            self.usersRef = self.database.collection("Users")
            self.setupAllTasksListener()
            self.setupTaskListener()
        }
        
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.currentAndCompletedTasks{
            listener.onTaskChange(change: .update, currentTasks: self.currentTasks, completedTasks: self.completedTasks)
        }
        else if listener.listenerType == .allTasks {
            listener.onAllTaskChange(change: .update, allTasks: allTaskList)
        }
        else if listener.listenerType == .auth {
            listener.onAuthChange(change: .update, currentUser: self.currentUser)
        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }

    
    func addTask(taskTitle: String, taskDescription: String, taskType: String, coordinate: CLLocationCoordinate2D?) -> ToDoTask {
        let task = ToDoTask()
        task.taskTitle = taskTitle
        task.taskDescription = taskDescription
        if coordinate != nil {
            task.longitude = coordinate?.longitude
            task.latitude = coordinate?.latitude
        }
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
    

    func setupAllTasksListener() {
        allTaskList = [ToDoTask]()
        self.allTasksRef = self.usersRef?.document((self.userID)!).collection("allTasks")
        allTasksRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseAllTaskSnapshot(snapshot: querySnapshot)
        }
    }
    
    func parseAllTaskSnapshot(snapshot: QuerySnapshot) {
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
                    listener.onAllTaskChange(change: .update, allTasks: self.allTaskList)
                }
            }
            
        }
    }
    
    func setupTaskListener() {
        currentTasks = [ToDoTask]()
        completedTasks = [ToDoTask]()
        self.dateRef = self.usersRef?.document((self.userID)!).collection("SelectedDate")
        self.currentTaskRef = self.dateRef?.document((self.currentDate)!).collection("currentTasks")
        self.completedTaskRef = self.dateRef?.document((self.currentDate)!).collection("completedTasks")
        
        currentTaskRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseTaskSnapshot(snapshot: querySnapshot, taskType: "current")
        }
        completedTaskRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseTaskSnapshot(snapshot: querySnapshot, taskType: "completed")
        }
    }

    
    
    func parseTaskSnapshot(snapshot: QuerySnapshot, taskType: String) {
        if taskType == "current" {
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
        }
        // need to invoke listener to make change appear
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.currentAndCompletedTasks{
                listener.onTaskChange(change: .update, currentTasks: self.currentTasks, completedTasks: self.completedTasks) 
            }
        }
    }
    
    func createNewSignIn( email: String, password: String) {
        Task {
            do {
                let authDataResult = try await authController.createUser(withEmail: email ,password: password )
                // The user was logged in, so do something!
                currentUser = authDataResult.user
                guard let userID = Auth.auth().currentUser?.uid else { return }
                self.userID = userID
//                if self.currentUser != nil {
//                    allTaskList = [ToDoTask]()
//                    currentTasks = [ToDoTask]()
//                    completedTasks = [ToDoTask]()
//                }
                self.usersRef = self.database.collection("Users")
                let _ = try await self.usersRef?.document((self.userID)!).setData(["name": (self.userID)!])
                self.setupAllTasksListener()
                self.setupTaskListener()
                listeners.invoke{ (listener) in
                    if listener.listenerType == ListenerType.auth {
                        listener.onAuthChange(change: .update, currentUser: self.currentUser)
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
                self.setupAllTasksListener()
                self.setupTaskListener()
                listeners.invoke{ (listener) in
                    if listener.listenerType == ListenerType.auth {
                        listener.onAuthChange(change: .update, currentUser: self.currentUser)
                    }
                }
            }
            catch {
                print("Authentication failed with error \(String(describing: error))")
            }
        }
    }
}
