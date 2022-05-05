//
//  AllTasksViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 2/5/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AllTasksViewController: UITableViewController, DatabaseListener {
    
    var listenerType = ListenerType.allTasks
    weak var databaseController: DatabaseProtocol?
    
    let SECTION_ALL_TASKS: Int = 0
    let CELL_ALL_TASKS: String = "allTasksCell"
    
    var allTasks: [ToDoTask] = []
    var task: ToDoTask?
    
    @IBAction func handleDoubleTap(_ sender: Any) {
        guard let recognizer = sender as? UITapGestureRecognizer else {
            return
        }
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                let isIndexValid = allTasks.indices.contains(tapIndexPath.row)
                if isIndexValid == true {
                    self.task = self.allTasks[tapIndexPath.row]
                    performSegue(withIdentifier: "previewTaskSegue", sender: self)
                }
            }
        }
        
        
    }
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        super.viewDidLoad()
        self.tableView.separatorColor = UIColor.clear

        // Do any additional setup after loading the view.
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
            return self.allTasks.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return a task cell
        let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_ALL_TASKS, for: indexPath)
        var content = taskCell.defaultContentConfiguration()
        let task = allTasks[indexPath.row]
        content.text = task.taskTitle
        taskCell.contentConfiguration = content
        return taskCell
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Add") { (action, view, completionHandler) in
            let task = self.allTasks[indexPath.row]
            let _ = self.databaseController?.addTask(taskTitle: (task.taskTitle)!, taskDescription: (task.taskDescription)!, taskType: "current")
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
            let task = self.allTasks[indexPath.row]
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
            if self.allTasks.count > 0 {
                return "Number of Tasks Saved:" + String(self.allTasks.count)
            } else {
                return ""
            }
        default:
            return ""
        }

    }
    

    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask]) {
        //
    }
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        self.allTasks = allTasks
        tableView.reloadData()
    }
    
    func onAuthChange(change: DatabaseChange, currentUser: User?) {
        //
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewTaskSegue"{
            let destination = segue.destination as! PreviewTaskViewController
            destination.task = self.task
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

