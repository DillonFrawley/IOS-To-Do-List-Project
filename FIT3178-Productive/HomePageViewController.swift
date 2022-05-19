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
    let CELL_CURRENT_TASK = "currentTaskCell"
    let CELL_COMPLETED_TASK = "completedTaskCell"
    
    let SECTION_CURRENT_TASK = 0
    let SECTION_COMPLETED_TASK = 1
    var currentTasks: [ToDoTask] = []
    var completedTasks: [ToDoTask] = []
    var filteredCurrentTasks: [ToDoTask] = []
    var filteredCompletedTasks: [ToDoTask] = []
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
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: true)
        self.tabBarController?.title = "Home"
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = "Enter a task name"
        self.tabBarController?.navigationItem.searchController = searchController
        searchController.searchBar.scopeButtonTitles = ["All", "Current", "Completed"]
        searchController.searchBar.showsScopeBar = true
        filteredCurrentTasks = currentTasks
        filteredCompletedTasks = completedTasks
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.determineCurrentLocation()
        self.tabBarController?.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.navigationItem.hidesSearchBarWhenScrolling = true
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            if filteredCurrentTasks.count == 0 {
                return 1
            }
            else {
                return filteredCurrentTasks.count
            }
        case 1:
            if filteredCompletedTasks.count == 0 {
                return 1
            }
            else {
                return filteredCompletedTasks.count
            }
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return a task cell
        if indexPath.section == SECTION_CURRENT_TASK {
            if self.currentTasks.count == 0 {
                let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_CURRENT_TASK, for: indexPath)
                var content = taskCell.defaultContentConfiguration()
                content.text = "No current tasks, tap the + icon to add a task"
                taskCell.contentConfiguration = content
                taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
                return taskCell
            } else {
                
                let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_CURRENT_TASK, for: indexPath)
                var content = taskCell.defaultContentConfiguration()
                if filteredCurrentTasks.count > 0 {
                    let task = filteredCurrentTasks[indexPath.row]
                    content.text = task.taskTitle
                    content.secondaryText = task.taskDescription
                }
                taskCell.contentConfiguration = content
                return taskCell
            }
        }
        else {
            if self.completedTasks.count == 0 {
                let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_COMPLETED_TASK, for: indexPath)
                var content = taskCell.defaultContentConfiguration()
                content.text = "No completed tasks, swipe right on a task to complete a task"
                taskCell.contentConfiguration = content
                taskCell.selectionStyle = UITableViewCell.SelectionStyle.none
                return taskCell
            }
            else {
                let taskCell = tableView.dequeueReusableCell(withIdentifier: CELL_COMPLETED_TASK, for: indexPath)
                var content = taskCell.defaultContentConfiguration()
                if filteredCompletedTasks.count > 0 {
                    let task = filteredCompletedTasks[indexPath.row]
                    content.text = task.taskTitle
                    content.secondaryText = task.taskDescription
                }
                taskCell.contentConfiguration = content
                return taskCell
            }
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_CURRENT_TASK && filteredCurrentTasks.count > 0 {
            return true
        }
        if indexPath.section == SECTION_COMPLETED_TASK && filteredCompletedTasks.count > 0 {
            return true
        }
        else {
            return false
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == SECTION_CURRENT_TASK && filteredCurrentTasks.count > 0 {
            let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                let task = self.filteredCurrentTasks[indexPath.row]
                self.databaseController?.deleteTask(task: task, taskType: "current")
                completionHandler(true)
            }
            action.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [action])
        }
        else {
            if indexPath.section == SECTION_COMPLETED_TASK && filteredCompletedTasks.count > 0{
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
            return "Current Tasks:" + String(self.filteredCurrentTasks.count)
        case 1:
            return "Completed Tasks:" + String(self.filteredCompletedTasks.count)
        default:
            return ""
        }

    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(), searchText.trimmingCharacters(in: .whitespaces).isEmpty == false else {
                filteredCurrentTasks = currentTasks
                filteredCompletedTasks = completedTasks
                return
            }
        let searchIndex = searchController.searchBar.selectedScopeButtonIndex
        switch searchIndex{
        case 0:
            filteredCurrentTasks = currentTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
            filteredCompletedTasks = completedTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
        case 1:
            filteredCurrentTasks = currentTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
            filteredCompletedTasks = []
        case 2:
            filteredCurrentTasks = []
            filteredCompletedTasks = completedTasks.filter({ (task: ToDoTask) -> Bool in
                return (task.taskTitle?.lowercased().contains(searchText) ?? false) })
        default:
            return
        }
        tableView.reloadData()
        self.navigationItem.searchController?.resignFirstResponder()
        }
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask]) {
        self.currentTasks = currentTasks
        self.completedTasks = completedTasks
        filteredCurrentTasks = currentTasks
        filteredCompletedTasks = completedTasks
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
                    let isIndexValid = filteredCurrentTasks.indices.contains(tapIndexPath.row)
                    if isIndexValid == true {
                        self.task = filteredCurrentTasks[tapIndexPath.row]
                        if self.task?.id != self.databaseController?.currentTask?.id {
                            performSegue(withIdentifier: "previewTaskSegue", sender: self)
                        }
                        else {
                            self.tabBarController?.selectedIndex = 1
                        }
                        
                    }
                case 1:
                    self.tappedTask = 1
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
        if self.task != self.databaseController?.currentTask {
            if segue.identifier == "previewTaskSegue"{
                let destination = segue.destination as! PreviewTaskViewController
                destination.task = self.task
                destination.delegate = self
                if self.tappedTask == 1 {
                    destination.buttonType = "complete"
                }
                else {
                    destination.buttonType = "start"
                }
                if task?.latitude != nil && task?.longitude != nil {
                    destination.coordinate = CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!)
                    
                }
            }
        }
    }



}

extension HomePageViewController: previewTaskControllerDelegate {
    func setCurrentTask(task: ToDoTask) {
        self.databaseController?.currentTask = task
        self.tabBarController?.viewDidLoad()
    }
}
