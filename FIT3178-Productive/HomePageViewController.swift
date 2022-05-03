//
//  HomePageViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class HomePageViewController: UITableViewController, DatabaseListener {
        
    var listenerType = ListenerType.currentAndCompletedTasks
    weak var databaseController: DatabaseProtocol?

    let CELL_CURRENT_TASK = "currentTaskCell"
    let CELL_COMPLETED_TASK_LABEL = "completedTaskLabelCell"
    let CELL_COMPLETED_TASK = "completedTaskCell"
    
    let SECTION_CURRENT_TASK = 0
    let SECTION_COMPLETED_TASK_LABEL = 1
    let SECTION_COMPLETED_TASK = 2
    var currentTasks: [ToDoTask] = []
    var completedTasks: [ToDoTask] = []
    var currentDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        self.tableView.separatorColor = UIColor.clear

        // Do any additional setup after loading the view.
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return currentTasks.count
        case 1:
            if completedTasks.count == 0 {
                return 0
            }
            else {
                return 1
            }
        case 2:
            return completedTasks.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return a task cell
        if indexPath.section == SECTION_CURRENT_TASK {
            let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_CURRENT_TASK, for: indexPath)
            var content = taskCell.defaultContentConfiguration()
            let task = currentTasks[indexPath.row]
            content.text = task.taskTitle
            taskCell.contentConfiguration = content
            return taskCell
        }
        else if indexPath.section == SECTION_COMPLETED_TASK_LABEL {
            let labelCell = tableView.dequeueReusableCell(withIdentifier: CELL_COMPLETED_TASK, for: indexPath)
            var content = labelCell.defaultContentConfiguration()
            content.text = "Completed Tasks: " + String(completedTasks.count)
            labelCell.contentConfiguration = content
            return labelCell
        }
        else {
            let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_CURRENT_TASK, for: indexPath)
            var content = taskCell.defaultContentConfiguration()
            let task = completedTasks[indexPath.row]
            content.text = task.taskTitle
            taskCell.contentConfiguration = content
            return taskCell
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_CURRENT_TASK || indexPath.section == SECTION_COMPLETED_TASK{
            return true
        }
        else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_CURRENT_TASK {
            let task = currentTasks[indexPath.row]
            databaseController?.deleteTask(task: task, taskType:"current")
        }
        else if editingStyle == .delete && indexPath.section == SECTION_COMPLETED_TASK{
            let task = completedTasks[indexPath.row]
            databaseController?.deleteTask(task: task, taskType:"completed")
            }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask], currentDate: String, taskType: String) {
        self.currentDate = currentDate
        self.currentTasks = currentTasks
        self.completedTasks = completedTasks
        tableView.reloadData()
    }
    
    func onAuthChange(change: DatabaseChange, currentUser: User?) {
        //
    }
    
    func onDateChange(change: DatabaseChange, allDates: [String]) {
        //
    }
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        //
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
