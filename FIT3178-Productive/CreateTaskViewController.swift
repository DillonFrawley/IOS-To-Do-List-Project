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
    var latitude: Double?
    var longitude: Double?

    @IBOutlet weak var timerOutlet: UIDatePicker!
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextField: UITextField!
    
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


    
    @IBAction func saveButtonAction(_ sender: Any) {
        guard let taskTitle = taskTitleTextField.text, let taskDescription = taskDescriptionTextField.text, taskTitle.trimmingCharacters(in: .whitespaces).isEmpty == false && taskDescription.trimmingCharacters(in: .whitespaces).isEmpty == false else {
            return
        }
        self.databaseController?.addTask(taskTitle: taskTitle, taskDescription: taskDescription, taskType: "allTasks", coordinate: CLLocationCoordinate2D(latitude: (self.latitude)!, longitude: (self.longitude)!), seconds: self.seconds!, minutes: self.minutes!, hours: self.hours!)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func locationButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "locationSegue", sender: self)
    }
    
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        if self.longitude == nil && self.latitude == nil {
            self.latitude = databaseController?.currentLocation?.latitude
            self.longitude = databaseController?.currentLocation?.longitude
        }
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
    
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask]) {
        //
    }
    
    
    func onAuthChange(change: DatabaseChange, currentUser: User?) {
        //
    }
    
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        self.allTasks = allTasks
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
