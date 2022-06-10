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
import AVKit


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
    var myInt: Int?
    var activeTasksConstant: [ToDoTask] = []
    
    var timer: Timer = Timer()
    let systemSoundID: SystemSoundID = 1005
    
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
        self.activeTasksConstant = activeTasks
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.determineCurrentLocation()
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        // using current date and time as an example

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
        timer.invalidate()
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
        let sectionFilteredDict = [0:[0:filteredActiveTasks,1:filteredCurrentTasks,2:filteredCompletedTasks],1:[0:filteredActiveTasks],2:[0:filteredCurrentTasks], 3:[0:filteredCompletedTasks]]
        let sectionDict = [0: [0:activeTasks,1:currentTasks, 2:completedTasks], 1:[0:activeTasks] ,2:[0:currentTasks], 3:[0:completedTasks]]
        let textDict = [0:[0: "No active tasks",1: "No current tasks, tap the + to add a task",2: "No completed tasks, swipe right on a task to complete a task"], 1: [0: "No active tasks"], 2:[0:"No current tasks, tap the + to add a task"] ,3: [0:"No completed tasks, swipe right on a task to complete a task"]]
        
        let originalArray = sectionDict[(self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex)!]![indexPath.section]!
        let originalText = textDict[(self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex)!]![indexPath.section]!
        let filteredArray = sectionFilteredDict[(self.navigationItem.searchController?.searchBar.selectedScopeButtonIndex)!]![indexPath.section]!
       
        
        if originalArray.count == 0 {
            let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
            taskCell.contentView.backgroundColor = UIColor.clear
            taskCell.taskTitleOutlet.text = originalText
            taskCell.taskDescriptionOutlet.isHidden = true
            taskCell.timeLabelOutlet.isHidden = true
            taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
            return taskCell
        } else {
            let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! ToDoTaskCell
            taskCell.contentView.backgroundColor = UIColor.clear
            taskCell.taskDescriptionOutlet.isHidden = false
            taskCell.timeLabelOutlet.isHidden = false
            if filteredArray.count > 0 {
                let task = filteredArray[indexPath.row]
                var hours = task.hours!
                var minutes = task.minutes!
                var seconds = task.seconds!
                if filteredArray == activeTasks {
                    let someDate = Date()
                    // convert Date to TimeInterval (typealias for Double)
                    let timeInterval = someDate.timeIntervalSince1970
                    // convert to Integer
                    self.myInt = Int(timeInterval)
                    if task.startTime != 0 {
                        let timeDifference = self.myInt! - task.startTime!
                        task.elapsedTime = timeDifference
                        let timedifferenceHours = timeDifference/3600
                        let timedifferenceMinutes = (timeDifference - (timedifferenceHours*3600))/60
                        let timedifferenceSeconds = timeDifference - (timedifferenceHours*3600) - (timedifferenceMinutes*60)
                        hours = task.hours! - timedifferenceHours
                        minutes = task.minutes! - timedifferenceMinutes
                        seconds = task.seconds! - timedifferenceSeconds
                        if seconds <= 0 {
                            if seconds <= 0 && minutes <= 0 {
                                if hours <= 0 && minutes <= 0 && seconds <= 0 {
                                    hours = 0
                                    minutes = 0
                                    seconds = 0
                                }
                                else {
                                    hours -= 1
                                    minutes = 59 + minutes
                                    seconds = 59 + seconds

                                }
                            }
                            else {
                                minutes -= 1
                                seconds = 59 + seconds

                            }
                        }
                        else {
                            seconds = 0
                        }
                    }
                }
                
                taskCell.taskTitleOutlet.text = task.taskTitle
                taskCell.taskDescriptionOutlet.text = task.taskDescription
                if task.startTime! == 0 && filteredArray == activeTasks {
                    taskCell.timeLabelOutlet.text = "Paused"
                }
                else if hours == 0 {
                    if minutes == 0 {
                        taskCell.timeLabelOutlet.text = String(seconds) + "s"
                        if seconds == 0 && filteredArray == activeTasks {
                            taskCell.contentView.backgroundColor = UIColor.red
                        }
                    }
                    else {
                        taskCell.timeLabelOutlet.text = String(minutes) + "m :" + String(seconds) + "s"
                    }
                }
                else {
                    taskCell.timeLabelOutlet.text = String(hours) + "h :" + String(minutes) + "m :" + String(seconds) + "s"
                }
            }
            else {
                taskCell.taskTitleOutlet.text = "No search results found"
                taskCell.taskDescriptionOutlet.isHidden = true
                taskCell.timeLabelOutlet.isHidden = true
            }
            return taskCell
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
        filteredActiveTasks = activeTasks
        activeTasksConstant = activeTasks
        if self.currentTasks != currentTasks {
            self.currentTasks = currentTasks
            filteredCurrentTasks = currentTasks
        }
        if self.completedTasks != completedTasks {
            self.completedTasks = completedTasks
            filteredCompletedTasks = completedTasks
        }
    
        UIView.setAnimationsEnabled(false)
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
    
    @objc func counter() {
//        for task in activeTasks {
//            if task.seconds! <= 0 {
//                task.seconds! = 0
//                if task.minutes! <= 0 {
//                    task.minutes! = 0
//                    if task.hours! <= 0 {
//                            task.hours = 0
//                        //
//                    }
//                    else {
//                        task.hours! -= 1
//                        task.minutes! = 59
//                        task.seconds! = 59
//                        task.elapsedTime! += 1
//                    }
//                }
//                else {
//                    task.minutes! -= 1
//                    task.seconds! = 59
//                    task.elapsedTime! += 1
//                }
//            }
//            else {
//                task.seconds! -= 1
//                task.elapsedTime! += 1
//                }
        UIView.setAnimationsEnabled(false)
        self.tableView.beginUpdates()
        self.tableView.reloadSections(NSIndexSet(index: 0) as IndexSet, with: UITableView.RowAnimation.none)
        self.tableView.endUpdates()
    }
    
//    self.databaseController?.updateTask(taskId: (task.id!),taskTitle: (task.taskTitle)!, taskDescription: (task.taskDescription)!, taskType: "active" , coordinate: CLLocationCoordinate2D(latitude: (task.latitude!), longitude: (task.longitude!)), seconds: (task.seconds!), minutes: (task.minutes!), hours: (task.hours!), startTime: (task.startTime!), elapsedTime: (task.elapsedTime!))

    
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

