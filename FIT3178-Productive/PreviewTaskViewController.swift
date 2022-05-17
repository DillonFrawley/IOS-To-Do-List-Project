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
    
    @IBOutlet weak var realTaskTitleLabel: UILabel!
    @IBOutlet weak var realTaskDescriptionLabel: UILabel!
    @IBOutlet weak var stackViewOutlet: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var completeAddButtonOutlet: UIButton!
    @IBOutlet weak var showLocationButton: UIButton!
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBAction func handlePlay(_ sender: Any) {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
    }
    
    @IBAction func handlePause(_ sender: Any) {
        self.timer.invalidate()
    }
    
    @IBAction func handleStop(_ sender: Any) {
        self.timer.invalidate()
        self.seconds = task?.seconds
        self.minutes = task?.minutes
        self.hours = task?.hours
        self.timeLabel.text = String(self.hours!) + ":" + String(self.minutes!) + ":" + String(self.seconds!)
        
    }
    
    @IBAction func handleSwipeRight(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func locationButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "locationSegue", sender: self)
    }
    
    @IBAction func completeaddTaskButton(_ sender: Any) {
        if self.buttonType == "complete" {
            self.databaseController?.addTask(taskTitle: (task!.taskTitle)!, taskDescription: (task!.taskDescription)!, taskType: "completed", coordinate: CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!), seconds: self.seconds!, minutes: self.minutes!, hours: self.hours!)
            self.databaseController?.deleteTask(task: task!, taskType: "current")
            navigationController?.popViewController(animated: true)
        }
        else if self.buttonType == "add" {
            self.databaseController?.addTask(taskTitle: (task!.taskTitle)!, taskDescription: (task!.taskDescription)!, taskType: "current", coordinate: CLLocationCoordinate2D(latitude: (task!.latitude)!, longitude: (task!.longitude)!), seconds: self.seconds!, minutes: self.minutes!, hours: self.hours!)
            navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        super.viewDidLoad()
        self.realTaskTitleLabel.text = self.task?.taskTitle
        self.realTaskDescriptionLabel.text = self.task?.taskDescription
        self.seconds = task?.seconds
        self.minutes = task?.minutes
        self.hours = task?.hours
        if self.buttonType == nil {
            self.completeAddButtonOutlet.isHidden = true
            self.stackViewOutlet.isHidden = true
            self.realTaskTitleLabel.isHidden = true
            self.realTaskDescriptionLabel.isHidden = true
            self.completeAddButtonOutlet.isHidden = true
            self.showLocationButton.isHidden = true
            self.taskDescriptionLabel.isHidden = true
            self.taskNameLabel.text = "No current task, please add a task to start"
        }
         else if self.buttonType == "complete" {
            self.completeAddButtonOutlet.isHidden = true
            self.stackViewOutlet.isHidden = true
            self.updateTimerOutlet()
            self.timeLabel.text = "Time required: " + self.timeLabel.text!
            
        }
        else if self.buttonType == "add" {
            self.completeAddButtonOutlet.setTitle("Add task to current day", for: .normal)
            self.stackViewOutlet.isHidden = true
            self.updateTimerOutlet()
            self.timeLabel.text = "Time required: " + self.timeLabel.text!
        }
        else if self.buttonType == "complete" {
            self.completeAddButtonOutlet.setTitle("Complete task", for: .normal)
        }

        // Do any additional setup after loading the view.
    }
        
    @objc func counter() {
        if seconds == 0 {
            if self.minutes == 0 && self.seconds == 0 {
                if self.hours == 0 && self.minutes == 0 && self.seconds == 0 {
                    self.timer.invalidate()
                    AudioServicesPlaySystemSound(self.systemSoundID)
                }
                else {
                    self.hours! -= 1
                    self.minutes! = 59
                    self.seconds! = 59
                }
            }
            else {
                self.minutes! -= 1
                self.seconds! = 59
            }
        }
        else {
            self.seconds! -= 1
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSegue" {
            let destination = segue.destination as! MapViewController
            destination.coordinate = self.coordinate

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
