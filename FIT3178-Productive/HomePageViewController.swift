//
//  HomePageViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreLocation


class HomePageViewController: UITableViewController, DatabaseListener, CLLocationManagerDelegate, UISearchResultsUpdating  {
        
    var listenerType = ListenerType.currentAndCompletedTasks
    weak var databaseController: DatabaseProtocol?
    let CELL_ACTIVE_TASK = "activeTaskCell"
    let CELL_CURRENT_TASK = "currentTaskCell"
    let CELL_COMPLETED_TASK = "completedTaskCell"
    
    var currentTasks: [ToDoTask] = []
    var completedTasks: [ToDoTask] = []
    var activeTasks: [ToDoTask] = []
    var filteredCurrentTasks: [ToDoTask] = []
    var filteredCompletedTasks: [ToDoTask] = []
    var filteredActiveTasks: [ToDoTask] = []
    var currentDate: String?
    var task: ToDoTask?
    var tappedTask: Int?
    
    var locationManager: CLLocationManager = CLLocationManager()
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        self.datePickerOutlet.contentHorizontalAlignment = .center
        self.tableView.allowsSelection = false
        self.title = "Home"
        filteredCurrentTasks = currentTasks
        filteredCompletedTasks = completedTasks
        filteredActiveTasks = activeTasks
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Enter a task name"
        self.navigationItem.searchController = searchController
        searchController.searchBar.scopeButtonTitles = ["All", "Active", "Current", "Completed"]
        searchController.searchBar.showsScopeBar = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.determineCurrentLocation()
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 0 {
            return 3
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 0 || self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 1 {
                if filteredActiveTasks.count > 0 {
                    return filteredActiveTasks.count
                }
                else {
                    return 1
                }
                    
            }
            else {
                if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 2 {
                    if filteredCurrentTasks.count > 0 {
                        return filteredCurrentTasks.count
                    }
                    else {
                        return 1
                    }
                    
                }
                else {
                    if filteredCompletedTasks.count > 0 {
                        return filteredCompletedTasks.count
                    }
                    else {
                        return 1
                    }
                }
            }
        case 1:
            if filteredCurrentTasks.count > 0 {
                return filteredCurrentTasks.count
            }
            else {
                return 1
            }
        case 2:
            if filteredCompletedTasks.count > 0 {
                return filteredCompletedTasks.count
            }
            else {
                return 1
            }
        default:
            return 0
        }

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 0  {
            if indexPath.section == 0 {
                if self.activeTasks.count == 0 {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    taskCell.taskTitleOutlet.text = "No active tasks"
                    taskCell.imageViewOutlet.isHidden = true
                    taskCell.taskDescriptionOutlet.isHidden = true
                    taskCell.timeLabelOutlet.isHidden = true
                    taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
                    return taskCell
                } else {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    if filteredActiveTasks.count > 0 {
                        let task = filteredActiveTasks[indexPath.row]
                        taskCell.imageViewOutlet.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        
                        taskCell.taskTitleOutlet.text = task.taskTitle
                        taskCell.taskDescriptionOutlet.text = task.taskDescription
                        if task.hours! == 0 {
                            if task.minutes! == 0 {
                                taskCell.timeLabelOutlet.text = String(task.seconds!) + "s"
                            }
                            else {
                                taskCell.timeLabelOutlet.text = String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                            }
                        }
                        else {
                            taskCell.timeLabelOutlet.text = String(task.hours!) + "h :" + String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                        }
                    }
                    else {
                        taskCell.taskTitleOutlet.text = "No search results found"
                        taskCell.imageViewOutlet.isHidden = true
                        taskCell.taskDescriptionOutlet.isHidden = true
                        taskCell.timeLabelOutlet.isHidden = true
                    }
                    return taskCell
                }
            }
            else if indexPath.section == 1 {
                if self.currentTasks.count == 0 {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    taskCell.taskTitleOutlet.text = "No current tasks, tap the + to add a task"
                    taskCell.imageViewOutlet.isHidden = true
                    taskCell.taskDescriptionOutlet.isHidden = true
                    taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
                    return taskCell
                } else {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    if filteredCurrentTasks.count > 0 {
                        let task = filteredCurrentTasks[indexPath.row]
                        taskCell.imageViewOutlet.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        taskCell.taskTitleOutlet.text = task.taskTitle
                        taskCell.taskDescriptionOutlet.text = task.taskDescription
                        if task.hours! == 0 {
                            if task.minutes! == 0 {
                                taskCell.timeLabelOutlet.text = String(task.seconds!) + "s"
                            }
                            else {
                                taskCell.timeLabelOutlet.text = String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                            }
                        }
                        else {
                            taskCell.timeLabelOutlet.text = String(task.hours!) + "h :" + String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                        }
                } else {
                    taskCell.taskTitleOutlet.text = "No search results found"
                    taskCell.imageViewOutlet.isHidden = true
                    taskCell.taskDescriptionOutlet.isHidden = true
                    taskCell.timeLabelOutlet.isHidden = true
                    }
                return taskCell
                }
            }
            else {
                if self.completedTasks.count == 0 {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    taskCell.taskTitleOutlet.text = "No completed tasks, swipe right on a task to complete a task"
                    taskCell.imageViewOutlet.isHidden = true
                    taskCell.taskDescriptionOutlet.isHidden = true
                    taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
                    return taskCell
                    
                }
                else {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
                    var content = taskCell.defaultContentConfiguration()
                    if filteredCompletedTasks.count > 0 {
                        let task = filteredCompletedTasks[indexPath.row]
                        content.text = task.taskTitle
                        content.secondaryText = task.taskDescription
                    }
                    else {
                        content.text = "No search results found"
                    }
                    taskCell.contentConfiguration = content
                    return taskCell
                }
            }
        }
        else {
            if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 1 {
                if self.activeTasks.count == 0 {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    taskCell.taskTitleOutlet.text = "No active tasks"
                    taskCell.imageViewOutlet.isHidden = true
                    taskCell.taskDescriptionOutlet.isHidden = true
                    taskCell.timeLabelOutlet.isHidden = true
                    taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
                    return taskCell
                } else {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    if filteredActiveTasks.count > 0 {
                        let task = filteredActiveTasks[indexPath.row]
                        taskCell.imageViewOutlet.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        
                        taskCell.taskTitleOutlet.text = task.taskTitle
                        taskCell.taskDescriptionOutlet.text = task.taskDescription
                        if task.hours! == 0 {
                            if task.minutes! == 0 {
                                taskCell.timeLabelOutlet.text = String(task.seconds!) + "s"
                            }
                            else {
                                taskCell.timeLabelOutlet.text = String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                            }
                        }
                        else {
                            taskCell.timeLabelOutlet.text = String(task.hours!) + "h :" + String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                        }
                    }
                    else {
                        taskCell.taskTitleOutlet.text = "No search results found"
                        taskCell.imageViewOutlet.isHidden = true
                        taskCell.taskDescriptionOutlet.isHidden = true
                        taskCell.timeLabelOutlet.isHidden = true
                    }
                    return taskCell
                }
            }
            else if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 2 {
                if self.currentTasks.count == 0 {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    taskCell.taskTitleOutlet.text = "No current tasks, tap the + to add a task"
                    taskCell.imageViewOutlet.isHidden = true
                    taskCell.taskDescriptionOutlet.isHidden = true
                    taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
                    return taskCell
                } else {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    if filteredCompletedTasks.count > 0 {
                        let task = filteredCompletedTasks[indexPath.row]
                        taskCell.imageViewOutlet.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        
                        taskCell.taskTitleOutlet.text = task.taskTitle
                        taskCell.taskDescriptionOutlet.text = task.taskDescription
                        if task.hours! == 0 {
                            if task.minutes! == 0 {
                                taskCell.timeLabelOutlet.text = String(task.seconds!) + "s"
                            }
                            else {
                                taskCell.timeLabelOutlet.text = String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                            }
                        }
                        else {
                            taskCell.timeLabelOutlet.text = String(task.hours!) + "h :" + String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                        }
                    }
                    else {
                        taskCell.taskTitleOutlet.text = "No search results found"
                        taskCell.imageViewOutlet.isHidden = true
                        taskCell.taskDescriptionOutlet.isHidden = true
                        taskCell.timeLabelOutlet.isHidden = true
                    }
                    return taskCell
                }
            }
            else {
                if self.completedTasks.count == 0 {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    taskCell.taskTitleOutlet.text = "No completed tasks, swipe right on a task to complete a task"
                    taskCell.imageViewOutlet.isHidden = true
                    taskCell.taskDescriptionOutlet.isHidden = true
                    taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
                    return taskCell
                }
                else {
                    let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
                    if filteredActiveTasks.count > 0 {
                        let task = filteredActiveTasks[indexPath.row]
                        taskCell.imageViewOutlet.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        
                        taskCell.taskTitleOutlet.text = task.taskTitle
                        taskCell.taskDescriptionOutlet.text = task.taskDescription
                        if task.hours! == 0 {
                            if task.minutes! == 0 {
                                taskCell.timeLabelOutlet.text = String(task.seconds!) + "s"
                            }
                            else {
                                taskCell.timeLabelOutlet.text = String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                            }
                        }
                        else {
                            taskCell.timeLabelOutlet.text = String(task.hours!) + "h :" + String(task.minutes!) + "m :" + String(task.seconds!) + "s"
                        }
                    }
                    else {
                        taskCell.taskTitleOutlet.text = "No search results found"
                        taskCell.imageViewOutlet.isHidden = true
                        taskCell.taskDescriptionOutlet.isHidden = true
                        taskCell.timeLabelOutlet.isHidden = true
                    }
                    return taskCell
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 0 {
            if indexPath.section == 0 && filteredActiveTasks.count > 0 {
                return true
            }
            else if indexPath.section == 1 && filteredCurrentTasks.count > 0 {
                return true
            }
            else if indexPath.section == 2 && filteredCompletedTasks.count > 0 {
                return true
            }
            else {
                return false
            }
        }
        else if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 1 {
            if filteredActiveTasks.count > 0 {
                return true
            }
            else {
                return false
            }
        }
        else if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 2 {
            if filteredCurrentTasks.count > 0 {
                return true
            }
            else {
                return false
            }
        }
        else {
            if filteredCompletedTasks.count > 0 {
                return true
            }
            else {
                return false
            }
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 0  {
            if indexPath.section == 0 && filteredActiveTasks.count > 0 {
                let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                    let task = self.filteredActiveTasks[indexPath.row]
                    self.databaseController?.deleteTask(task: task, taskType: "active")
                    completionHandler(true)
                }
                action.backgroundColor = .systemRed
                return UISwipeActionsConfiguration(actions: [action])
            }
            else if indexPath.section == 1 && filteredCurrentTasks.count > 0 {
                let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                    let task = self.filteredCurrentTasks[indexPath.row]
                    self.databaseController?.deleteTask(task: task, taskType: "current")
                    completionHandler(true)
                }
                action.backgroundColor = .systemRed
                return UISwipeActionsConfiguration(actions: [action])
            }
            else if indexPath.section == 2 && filteredCompletedTasks.count > 0 {
                let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                    let task = self.filteredCompletedTasks[indexPath.row]
                    self.databaseController?.deleteTask(task: task, taskType: "completed")
                    completionHandler(true)
                }
                action.backgroundColor = .systemRed
                return UISwipeActionsConfiguration(actions: [action])
            }
        }
        else if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 1 {
                if filteredActiveTasks.count > 0 {
                    let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                        let task = self.filteredActiveTasks[indexPath.row]
                        self.databaseController?.deleteTask(task: task, taskType: "active")
                        completionHandler(true)
                    }
                    action.backgroundColor = .systemRed
                    return UISwipeActionsConfiguration(actions: [action])
                }
            }
        else if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 2{
            if filteredCurrentTasks.count > 0 {
                let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                    let task = self.filteredCurrentTasks[indexPath.row]
                    self.databaseController?.deleteTask(task: task, taskType: "current")
                    completionHandler(true)
                }
                action.backgroundColor = .systemRed
                return UISwipeActionsConfiguration(actions: [action])
            }
        }
        else {
            if filteredCompletedTasks.count > 0 {
                let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                    let task = self.filteredCompletedTasks[indexPath.row]
                    self.databaseController?.deleteTask(task: task, taskType: "completed")
                    completionHandler(true)
                }
                action.backgroundColor = .systemRed
                return UISwipeActionsConfiguration(actions: [action])
            }
        }
        return nil
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        switch section {
        case 0:
            if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 0 || self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 1 {
                    return "Active Tasks:" + String(self.filteredActiveTasks.count)

            }
            else {
                if self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex == 2 {
                    return "Current Tasks:" + String(self.filteredCurrentTasks.count)
                }
                else {
                    return "Completed Tasks:" + String(self.filteredCompletedTasks.count)
                }
            }
        case 1:
            return "Current Tasks:" + String(self.filteredCurrentTasks.count)
        case 2:
            return "Completed Tasks:" + String(self.filteredCompletedTasks.count)
        default:
            return ""
        }

    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), searchText.trimmingCharacters(in: .whitespaces).isEmpty == false else {
                filteredActiveTasks = activeTasks
                filteredCurrentTasks = currentTasks
                filteredCompletedTasks = completedTasks
                tableView.reloadData()
                return
            }
        let searchIndex = searchController.searchBar.selectedScopeButtonIndex
        switch searchIndex{
        case 0:
            filteredActiveTasks = activeTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
            filteredCurrentTasks = currentTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
            filteredCompletedTasks = completedTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
        case 1:
            filteredActiveTasks = activeTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
            filteredCurrentTasks = []
            filteredCompletedTasks = []
        case 2:
            filteredActiveTasks = []
            filteredCurrentTasks = currentTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
            filteredCompletedTasks = []
        case 3:
            filteredActiveTasks = []
            filteredCurrentTasks = []
            filteredCompletedTasks = completedTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
        default:
            return
        }
        tableView.reloadData()
        }
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask], activeTasks: [ToDoTask]) {
        self.activeTasks = activeTasks
        self.currentTasks = currentTasks
        self.completedTasks = completedTasks
        filteredCurrentTasks = currentTasks
        filteredCompletedTasks = completedTasks
        filteredActiveTasks = activeTasks
        tableView.reloadData()
    }
    
    func onAuthChange(change: DatabaseChange, currentUser: User?) {
        //
    }
    
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        //
    }
    
    func determineCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        else if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            databaseController?.currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    @IBAction func datePickerChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: self.datePickerOutlet.date)
        self.currentDate = strDate.replacingOccurrences(of: "/", with: "-")
        self.databaseController?.currentDate = self.currentDate
        self.databaseController?.setupTaskListener()
        
    }
    
    @IBAction func handleDoubleTap(_ sender: Any) {
        guard let recognizer = sender as? UITapGestureRecognizer else {
            return
        }
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                switch tapIndexPath.section {
                case 0:
                    self.tappedTask = 0
                    let isIndexValid = filteredActiveTasks.indices.contains(tapIndexPath.row)
                    if isIndexValid == true {
                        self.task = filteredActiveTasks[tapIndexPath.row]
                        performSegue(withIdentifier: "previewTaskSegue", sender: self)
                        
                    }
                case 1:
                    self.tappedTask = 1
                    let isIndexValid = filteredCurrentTasks.indices.contains(tapIndexPath.row)
                    if isIndexValid == true {
                        self.task = filteredCurrentTasks[tapIndexPath.row]
                        performSegue(withIdentifier: "previewTaskSegue", sender: self)
                        
                    }
                case 2:
                    self.tappedTask = 2
                    let isIndexValid = filteredCompletedTasks.indices.contains(tapIndexPath.row)
                    if isIndexValid == true {
                        self.task = filteredCompletedTasks[tapIndexPath.row]
                        performSegue(withIdentifier: "previewTaskSegue", sender: self)
                    }
                default:
                    return
                }
                
            }
        }
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewTaskSegue"{
            let destination = segue.destination as! PreviewTaskViewController
            destination.task = self.task
            if self.tappedTask == 0 {
                destination.buttonType = "active"
            }
            else if self.tappedTask == 1 {
                destination.buttonType = "current"
            } else {
                destination.buttonType = "complete"
            }
            if task?.latitude != nil && task?.longitude != nil {
                destination.coordinate = CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!)
            }
        }
    }

}
