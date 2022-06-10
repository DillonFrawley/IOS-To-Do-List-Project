//
//  AllTasksViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 2/5/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreLocation

class AllTasksViewController: UITableViewController, DatabaseListener, UISearchResultsUpdating {
    
    var listenerType = ListenerType.allTasks
    weak var databaseController: DatabaseProtocol?
    
    let SECTION_ALL_TASKS: Int = 0
    let CELL_ALL_TASKS: String = "allTasksCell"
    
    var allTasks: [ToDoTask] = []
    var filteredTasks: [ToDoTask] = []
    var task: ToDoTask?
    var selectedRows :[Int]?
    

    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = true
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Enter a task name"
        self.navigationItem.searchController = searchController
        filteredTasks = allTasks
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            if filteredTasks.count == 0 {
                return 1
            }
            else {
                return self.filteredTasks.count
            }
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return a task cell
        if allTasks.count == 0 {
            let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_ALL_TASKS, for: indexPath)
            var content = taskCell.defaultContentConfiguration()
            content.text = "No saved tasks, tap + to create a task"
            taskCell.contentConfiguration = content
            return taskCell
        } else {
            let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_ALL_TASKS, for: indexPath)
            var content = taskCell.defaultContentConfiguration()
            if filteredTasks.count > 0 {
                let task = filteredTasks[indexPath.row]
                content.text = task.taskTitle
                content.secondaryText = task.taskDescription
            }
            taskCell.contentConfiguration = content
            return taskCell
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_ALL_TASKS{
            return true
        }
        else {
            return false
        }
    }
    
    
    override func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
            let task = self.filteredTasks[indexPath.row]
            self.databaseController?.deleteTask(task: task, taskType: "allTasks")
            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }
    

    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        switch section {
        case 0:
            return "Number of Tasks Saved:" + String(self.filteredTasks.count)
        default:
            return ""
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRows?[indexPath.row] = 1
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedRows?[indexPath.row] = 0
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), searchText.trimmingCharacters(in: .whitespaces).isEmpty == false else {
                filteredTasks = allTasks
                tableView.reloadData()
                return
            }
        if searchText.count > 0 {
            filteredTasks = allTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })

        } else {
            filteredTasks = allTasks

        }
        self.tableView.reloadData()
        }


    
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask], activeTasks: [ToDoTask]) {
        //
    }
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        self.allTasks = allTasks
        self.selectedRows = []
        for _ in 0 ... self.allTasks.count {
            self.selectedRows?.append(0)
        }
        filteredTasks = allTasks
        tableView.reloadData()
    }
    
    func onAuthChange(change: DatabaseChange, currentUser: User?) {
        //
    }
    
    
    @IBAction func saveSelectedTasks(_ sender: Any) {
        if self.selectedRows != nil {
            if self.selectedRows!.contains(1) == true {
                for i in 0 ... self.selectedRows!.count - 1 {
                    if selectedRows![i] == 1 {
                        let task = self.filteredTasks[i]
                        self.databaseController?.addTask(taskTitle: task.taskTitle!, taskDescription: task.taskDescription!, taskType: "current", coordinate: CLLocationCoordinate2D(latitude: (task.latitude)!, longitude: (task.longitude)!), seconds: task.seconds!, minutes: task.minutes!, hours: task.hours!, startTime:  (task.startTime)!, elapsedTime: (task.elapsedTime)!)
                    }
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func handleDoubleTap(_ sender: Any) {
        guard let recognizer = sender as? UITapGestureRecognizer else {
            return
        }
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                let isIndexValid = filteredTasks.indices.contains(tapIndexPath.row)
                if isIndexValid == true {
                    self.task = self.filteredTasks[tapIndexPath.row]
                    performSegue(withIdentifier: "previewTaskSegue", sender: self)
                }
            }
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewTaskSegue"{
            let destination = segue.destination as! PreviewTaskViewController
            destination.task = self.task
            destination.buttonType = "add"
            if task?.latitude != nil && task?.longitude != nil {
                destination.coordinate = CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!)
           
            }
        }
    }


}

