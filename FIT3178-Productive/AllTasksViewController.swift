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
    
    let SECTION_ALL_TASKS_COUNT: Int = 0
    let SECTION_ALL_TASKS: Int = 1
    
    let CELL_ALL_TASKS_COUNT: String = "allTasksCountCell"
    let CELL_ALL_TASKS: String = "allTasksCell"
    
    var allTasks: [ToDoTask] = []
    
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return self.allTasks.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return a task cell
        if indexPath.section == SECTION_ALL_TASKS_COUNT {
            let labelCell = tableView.dequeueReusableCell(withIdentifier: CELL_ALL_TASKS_COUNT, for: indexPath)
            var content = labelCell.defaultContentConfiguration()
            content.text = "Number Of Tasks Stored: " + String(allTasks.count)
            labelCell.contentConfiguration = content
            return labelCell
        }
        else {
            let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_ALL_TASKS, for: indexPath)
            var content = taskCell.defaultContentConfiguration()
            let task = allTasks[indexPath.row]
            content.text = task.taskTitle
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
        let action = UIContextualAction(style: .normal, title: "Add") { (action, view, completionHandler) in
            let task = self.allTasks[indexPath.row]
            let _ = self.databaseController?.addTask(taskTitle: (task.taskTitle)!, taskDescription: (task.taskDescription)!, taskType: "current")
            completionHandler(true)
        }
        action.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
    

    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask], currentDate: String, taskType: String) {
        //
    }
    
    func onDateChange(change: DatabaseChange, allDates: [String]) {
        //
    }
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        self.allTasks = allTasks
        tableView.reloadData()
    }
    
    func onAuthChange(change: DatabaseChange, currentUser: User?) {
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

