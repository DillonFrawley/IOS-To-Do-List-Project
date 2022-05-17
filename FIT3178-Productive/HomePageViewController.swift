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

class HomePageViewController: UITableViewController, DatabaseListener, CLLocationManagerDelegate  {
        
    var listenerType = ListenerType.currentAndCompletedTasks
    weak var databaseController: DatabaseProtocol?

    let CELL_CURRENT_TASK = "currentTaskCell"
    let CELL_COMPLETED_TASK = "completedTaskCell"
    
    let SECTION_CURRENT_TASK = 0
    let SECTION_COMPLETED_TASK = 1
    var currentTasks: [ToDoTask] = []
    var completedTasks: [ToDoTask] = []
    var currentDate: String?
    var task: ToDoTask?
    
    var locationManager: CLLocationManager = CLLocationManager()

    
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
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
                    let isIndexValid = currentTasks.indices.contains(tapIndexPath.row)
                    if isIndexValid == true {
                        self.task = currentTasks[tapIndexPath.row]
                        performSegue(withIdentifier: "previewTaskSegue", sender: self)
                    }
                case 1:
                    let isIndexValid = completedTasks.indices.contains(tapIndexPath.row)
                    if isIndexValid == true {
                        self.task = completedTasks[tapIndexPath.row]
                        performSegue(withIdentifier: "previewTaskSegue", sender: self)
                    }
                default:
                    return
                }
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        self.datePickerOutlet.contentHorizontalAlignment = .center
        self.tableView.allowsSelection = false

    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            if currentTasks.count == 0 {
                return 1
            }
            else {
                return currentTasks.count
            }
        case 1:
            if completedTasks.count == 0 {
                return 1
            }
            else {
                return completedTasks.count
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
                let task = currentTasks[indexPath.row]
                content.text = task.taskTitle
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
                let task = completedTasks[indexPath.row]
                content.text = task.taskTitle
                taskCell.contentConfiguration = content
                return taskCell
            }
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_CURRENT_TASK && currentTasks.count > 0 {
            return true
        }
        if indexPath.section == SECTION_COMPLETED_TASK && completedTasks.count > 0 {
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
        if indexPath.section == SECTION_CURRENT_TASK && currentTasks.count > 0 {
            let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                let task = self.currentTasks[indexPath.row]
                self.databaseController?.deleteTask(task: task, taskType: "current")
                completionHandler(true)
            }
            action.backgroundColor = .systemRed
            return UISwipeActionsConfiguration(actions: [action])
        }
        else {
            if indexPath.section == SECTION_COMPLETED_TASK && completedTasks.count > 0{
                let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completionHandler) in
                    let task = self.completedTasks[indexPath.row]
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
            return "Current Tasks:" + String(self.currentTasks.count)
        case 1:
            return "Completed Tasks:" + String(self.completedTasks.count)
        default:
            return ""
        }

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.determineCurrentLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        locationManager.stopUpdatingLocation()
    }
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask]) {
        self.currentTasks = currentTasks
        self.completedTasks = completedTasks
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewTaskSegue"{
            let destination = segue.destination as! PreviewTaskViewController
            destination.task = self.task
            destination.buttonType = "complete"
            if task?.latitude != nil && task?.longitude != nil {
                destination.coordinate = CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!)
                
            }
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
