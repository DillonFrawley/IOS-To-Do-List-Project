//
//  CreateTaskViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreLocation



class CreateTaskViewController: UIViewController, DatabaseListener {

    var listenerType = ListenerType.allTasks
    weak var databaseController: DatabaseProtocol?
    var allTasks:[ToDoTask] = []
    var seconds: Int? = 0
    var minutes: Int? = 1
    var hours: Int? = 0

    @IBOutlet weak var timerOutlet: UIDatePicker!
    
    
    @IBAction func timerValueChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "H:m:s"
        let strTime = dateFormatter.string(from: self.timerOutlet.date)
        let strTimeArr = strTime.components(separatedBy: ":")
        self.hours = Int(strTimeArr[0])
        self.minutes = Int(strTimeArr[1])
        self.seconds = Int(strTimeArr[2])
        
    }
    
    @IBAction func handleSwipeRight(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var taskTitleTextField: UITextField!
    
    @IBOutlet weak var taskDescriptionTextField: UITextField!
    
    var latitude: Double?
    var longitude: Double?
    
    
    @IBAction func createTaskButtonAction(_ sender: Any) {
        guard let taskTitle = taskTitleTextField.text, let taskDescription = taskDescriptionTextField.text else {
            return
        }
        if taskTitle.isEmpty == false && taskDescription.isEmpty == false {
            if whitespaceBool(string: taskTitle) == true && whitespaceBool(string: taskDescription) == true {
                if checkTaskDuplicate(taskTitle: taskTitle) == false {
                    let _ = self.databaseController?.addTask(taskTitle: taskTitle, taskDescription: taskDescription, taskType: "allTasks", coordinate: CLLocationCoordinate2D(latitude: (self.latitude)!, longitude: (self.longitude)!), seconds: self.seconds!, minutes: self.minutes!, hours: self.hours!)
                    navigationController?.popViewController(animated: true)
                }
            }
        }
        
        
        
    }
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        super.viewDidLoad()

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
    
    func displayMessage(title: String, message: String) -> () {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func whitespaceBool(string: String) -> Bool {
        var whitespaceString = " "
        if string.count == 1 {
            return string != whitespaceString
        }
        for _ in 2...string.count {
            whitespaceString.append(" ")
        }
        return string != whitespaceString
    }
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask]) {
        //
    }
    
    func checkTaskDuplicate( taskTitle: String) -> Bool {
        var duplicateBool = false
        allTasks.forEach { newTask in
            if taskTitle == newTask.taskTitle {
                duplicateBool = true
            }
        }
        if duplicateBool == true {
            return true
        }
        return false
    }
    
    func onAuthChange(change: DatabaseChange, currentUser: User?) {
        //
    }
    
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        self.allTasks = allTasks
    }
    
    
    @IBAction func locationButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "locationSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSegue"{
            let destination = segue.destination as! MapViewController
            destination.delegate = self
        }
    }

}

extension CreateTaskViewController: MapViewControllerDelegate {
    func saveLocation(coordinate: CLLocationCoordinate2D) {
        self.longitude = coordinate.longitude
        self.latitude = coordinate.latitude
    }
    
}
