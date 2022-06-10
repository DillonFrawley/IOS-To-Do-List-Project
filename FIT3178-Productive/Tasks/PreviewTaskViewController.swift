//
//  PreviewTaskViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 4/5/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreLocation
import AVKit

class PreviewTaskViewController: UIViewController{
    
    weak var databaseController: DatabaseProtocol?
    var coordinate: CLLocationCoordinate2D?
    var buttonType: String?
    var task: ToDoTask?
    var seconds : Int?
    var minutes: Int?
    var hours: Int?
    var timer: Timer = Timer()
    let systemSoundID: SystemSoundID = 1005
    var editVC: CreateTaskViewController?
    var startCurrenttask: Bool?
    var elapsedTime: Int?

    
    @IBOutlet weak var realTaskTitleLabel: UILabel!
    @IBOutlet weak var realTaskDescriptionLabel: UILabel!
    @IBOutlet weak var stackViewOutlet: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var completeAddButtonOutlet: UIButton!
    @IBOutlet weak var showLocationButton: UIButton!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var editButtonOutlet: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        super.viewDidLoad()

        self.realTaskTitleLabel.text = self.task?.taskTitle
        self.realTaskDescriptionLabel.text = self.task?.taskDescription
        self.seconds = task?.seconds
        self.minutes = task?.minutes
        self.hours = task?.hours
        self.elapsedTime = task?.elapsedTime
        
        if self.buttonType == "complete" {
            self.stackViewOutlet.isHidden = true
            self.completeAddButtonOutlet.isHidden = true
            if self.hours! == 0 {
                if self.minutes! == 0 {
                    self.timeLabel.text = String(self.seconds!) + "s"
                }
                else {
                    self.timeLabel.text = String(self.minutes!) + "m :" + String(self.seconds!) + "s"
                }
            }
            else {
                self.timeLabel.text = String(self.hours!) + "h :" + String(self.minutes!) + "m :" + String(self.seconds!) + "s"
            }

            self.timeLabel.text = "Time required: " + self.timeLabel.text!
            self.navigationController?.navigationItem.rightBarButtonItem = nil
        }
         else if self.buttonType == "active" {
            self.completeAddButtonOutlet.setTitle("Complete task", for: .normal)
             if self.hours! == 0 {
                 if self.minutes! == 0 {
                     self.timeLabel.text = String(self.seconds!) + "s"
                 }
                 else {
                     self.timeLabel.text = String(self.minutes!) + "m :" + String(self.seconds!) + "s"
                 }
             }
             else {
                 self.timeLabel.text = String(self.hours!) + "h :" + String(self.minutes!) + "m :" + String(self.seconds!) + "s"
             }
        }
        else if self.buttonType == "add" {
            self.completeAddButtonOutlet.setTitle("Add task to current day", for: .normal)
            self.stackViewOutlet.isHidden = true
            if self.hours! == 0 {
                if self.minutes! == 0 {
                    self.timeLabel.text = String(self.seconds!) + "s"
                }
                else {
                    self.timeLabel.text = String(self.minutes!) + "m :" + String(self.seconds!) + "s"
                }
            }
            else {
                self.timeLabel.text = String(self.hours!) + "h :" + String(self.minutes!) + "m :" + String(self.seconds!) + "s"
            }
            self.timeLabel.text = "Time required: " + self.timeLabel.text!
        }
        else if self.buttonType == "current" {
            self.completeAddButtonOutlet.setTitle("Start this task", for: .normal)
            self.stackViewOutlet.isHidden = true
            if self.hours! == 0 {
                if self.minutes! == 0 {
                    self.timeLabel.text = String(self.seconds!) + "s"
                }
                else {
                    self.timeLabel.text = String(self.minutes!) + "m :" + String(self.seconds!) + "s"
                }
            }
            else {
                self.timeLabel.text = String(self.hours!) + "h :" + String(self.minutes!) + "m :" + String(self.seconds!) + "s"
            }
            self.timeLabel.text = "Time required: " + self.timeLabel.text!
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    @objc func counter() {
        if seconds == 0 {
            if self.minutes == 0 && self.seconds == 0 {
                if self.hours == 0 && self.minutes == 0 && self.seconds == 0 {
                    self.timer.invalidate()
                    AudioServicesPlayAlertSound(self.systemSoundID)
                }
                else {
                    self.hours! -= 1
                    self.minutes! = 59
                    self.seconds! = 59
                    self.elapsedTime! += 1
                    
                }
            }
            else {
                self.minutes! -= 1
                self.seconds! = 59
                self.elapsedTime! += 1
            }
        }
        else {
            self.seconds! -= 1
            self.elapsedTime! += 1
        }
        self.updateTimerOutlet()
    }
    
    func updateTimerOutlet() {
        if self.hours! == 0 {
            if self.minutes! == 0 {
                self.timeLabel.text = String(self.seconds!) + "s"
            }
            else {
                self.timeLabel.text = String(self.minutes!) + "m :" + String(self.seconds!) + "s"
            }
        }
        else {
            self.timeLabel.text = String(self.hours!) + "h :" + String(self.minutes!) + "m :" + String(self.seconds!) + "s"
        }
    }
    
    
    @IBAction func editButtonAction(_ sender: Any) {
        if self.editButtonOutlet.title == "Edit" {
            self.editVC = storyboard!.instantiateViewController(withIdentifier: "createTaskViewController") as? CreateTaskViewController
            self.addChild(editVC!)
            editVC!.view.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - view.safeAreaInsets.top)
            view.addSubview(editVC!.view)
            editVC!.taskTitleTextField.text = task?.taskTitle
            editVC!.taskDescriptionTextField.text = task?.taskDescription
            editVC!.longitude = task?.longitude
            editVC!.latitude = task?.latitude
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short
            dateFormatter.dateFormat = "H:m:s"
            editVC!.timerOutlet.date = dateFormatter.date(from: String(self.hours!) + ":" + String(self.minutes!) + ":" + String(self.seconds!))!
            self.editButtonOutlet.title = "Save"
            view.layoutSubviews()
        }
        else if self.editButtonOutlet.title == "Save" {
            guard let taskTitle = editVC!.taskTitleTextField.text, let taskDescription = editVC!.taskDescriptionTextField.text, taskTitle.trimmingCharacters(in: .whitespaces).isEmpty == false && taskDescription.trimmingCharacters(in: .whitespaces).isEmpty == false else {
                return
            }
            var taskType: String
            switch buttonType {
            case "active":
                taskType = "active"
            case "add":
                taskType = "allTasks"
            case "current":
                taskType = "current"
            default:
                return
            }
            task?.taskTitle = taskTitle
            task?.taskDescription = taskDescription
            task?.latitude = (editVC!.latitude)!
            task?.longitude = (editVC!.longitude)!
            task?.seconds = editVC!.seconds!
            task?.minutes = editVC!.minutes!
            task?.hours = editVC!.hours!
            self.databaseController?.updateTask(taskId: (self.task?.id)!,taskTitle: taskTitle, taskDescription: taskDescription, taskType: taskType, coordinate: CLLocationCoordinate2D(latitude: (editVC!.latitude)!, longitude: (editVC!.longitude)!), seconds: editVC!.seconds!, minutes: editVC!.minutes!, hours: editVC!.hours!, startTime: (self.task?.startTime)!, elapsedTime: (self.task?.elapsedTime)!)
            editVC!.view.removeFromSuperview()
            editVC!.removeFromParent()
            self.editButtonOutlet.title = "Edit"
            self.viewDidLoad()
        }
    }
    
    @IBAction func handlePlay(_ sender: Any) {
        // using current date and time as an example
        let someDate = Date()

        // convert Date to TimeInterval (typealias for Double)
        let timeInterval = someDate.timeIntervalSince1970

        // convert to Integer
        let myInt = Int(timeInterval)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        self.databaseController?.updateTask(taskId: (self.task?.id)!,taskTitle: (self.task?.taskTitle)!, taskDescription: (self.task?.taskDescription)!, taskType: (self.buttonType)! , coordinate: CLLocationCoordinate2D(latitude: (self.task?.latitude)!, longitude: (self.task?.longitude)!), seconds: (self.seconds)!, minutes: (self.minutes)!, hours: (self.hours)!, startTime: myInt, elapsedTime: (self.task?.elapsedTime)!)
    }
    
    @IBAction func handlePause(_ sender: Any) {
        self.timer.invalidate()
        self.task!.startTime = 0
        self.databaseController?.updateTask(taskId: (self.task?.id)!,taskTitle: (self.task?.taskTitle)!, taskDescription: (self.task?.taskDescription)!, taskType: (self.buttonType)! , coordinate: CLLocationCoordinate2D(latitude: (self.task?.latitude)!, longitude: (self.task?.longitude)!), seconds: (self.seconds)!, minutes: (self.minutes)!, hours: (self.hours)!, startTime: (self.task?.startTime)!, elapsedTime: (self.elapsedTime)!)
        
    }
    
    @IBAction func handleStop(_ sender: Any) {
        self.timer.invalidate()
        self.seconds = task?.seconds
        self.minutes = task?.minutes
        self.hours = task?.hours
        self.updateTimerOutlet()
        
    }
    
    @IBAction func handleSwipeRight(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func locationButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "locationSegue", sender: self)
    }
    
    @IBAction func completeaddTaskButton(_ sender: Any) {
        if self.buttonType == "current" {
            // using current date and time as an example
            let someDate = Date()

            // convert Date to TimeInterval (typealias for Double)
            let timeInterval = someDate.timeIntervalSince1970

            // convert to Integer
            let myInt = Int(timeInterval)
            
            self.databaseController?.addTask(taskTitle: (task!.taskTitle)!, taskDescription: (task!.taskDescription)!, taskType: "active", coordinate: CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!), seconds: self.seconds!, minutes: self.minutes!, hours: self.hours!, startTime: myInt, elapsedTime: 0)
            self.databaseController?.deleteTask(task: task!, taskType: "current")
            
            navigationController?.popViewController(animated: true)
        }
        else if self.buttonType == "add" {
            self.databaseController?.addTask(taskTitle: (task!.taskTitle)!, taskDescription: (task!.taskDescription)!, taskType: "current", coordinate: CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!), seconds: self.seconds!, minutes: self.minutes!, hours: self.hours!, startTime: (task?.startTime)!, elapsedTime: (task?.elapsedTime)!)
            navigationController?.popViewController(animated: true)
        }
        else if self.buttonType == "active" {
            self.databaseController?.addTask(taskTitle: (task!.taskTitle)!, taskDescription: (task!.taskDescription)!, taskType: "completed", coordinate: CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!), seconds: self.seconds!, minutes: self.minutes!, hours: self.hours!, startTime: (task?.startTime)!, elapsedTime: (task?.elapsedTime)!)
            self.databaseController?.deleteTask(task: task!, taskType: "active")
            navigationController?.popViewController(animated: true)

        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if self.buttonType == "active" {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer.invalidate()
        self.databaseController?.updateTask(taskId: (self.task?.id)!,taskTitle: (self.task?.taskTitle)!, taskDescription: (self.task?.taskDescription)!, taskType: (self.buttonType)! , coordinate: CLLocationCoordinate2D(latitude: (self.task?.latitude)!, longitude: (self.task?.longitude)!), seconds: (self.seconds)!, minutes: (self.minutes)!, hours: (self.hours)!, startTime: (self.task?.startTime)!, elapsedTime: (self.task?.elapsedTime)!)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSegue" {
            let destination = segue.destination as! MapViewController
            destination.coordinate = self.coordinate

        }
    }
    
    

}

