//
//  CreateTaskViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 22/4/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class CreateTaskViewController: UIViewController, DatabaseListener {

    var listenerType = ListenerType.currentTask
    weak var databaseController: DatabaseProtocol?
    var allTasks:[ToDoTask] = []

    
    @IBOutlet weak var taskTitleTextField: UITextField!
    
    @IBOutlet weak var taskDescriptionTextField: UITextField!
    
    @IBAction func createTaskButtonAction(_ sender: Any) {
        guard let taskTitle = taskTitleTextField.text, let taskDescription = taskDescriptionTextField.text else {
            return
        }
        if taskTitle.isEmpty == false && taskDescription.isEmpty == false {
            if whitespaceBool(string: taskTitle) == true && whitespaceBool(string: taskDescription) == true {
                if checkTaskDuplicate(taskTitle: taskTitle) == false {
                    let _ = databaseController?.addTask(taskTitle: taskTitle, taskDescription: taskDescription, taskType: "current")
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
    
    func onTaskChange(change: DatabaseChange, tasks: [ToDoTask], taskType: String) {
        allTasks = tasks
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
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
