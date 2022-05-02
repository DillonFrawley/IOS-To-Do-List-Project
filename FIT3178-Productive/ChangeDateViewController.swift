//
//  ChangeDateViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 2/5/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ChangeDateViewController: UIViewController, DatabaseListener {
    
    var listenerType = ListenerType.date
    weak var databaseController: DatabaseProtocol?
    
    var currentDate: String?
    var allDates: [String]?
    
    @IBOutlet weak var newDateTextField: UITextField!
    
    @IBOutlet weak var currentDateTextLabel: UILabel!
    
    @IBAction func changeDateButton(_ sender: Any) {
        if newDateTextField != nil {
            if (newDateTextField.text)!.isEmpty == false {
                let newDate = self.newDateTextField.text
                self.databaseController?.currentDate = newDate
                navigationController?.popViewController(animated: true)
            }
        }
        
        
        
    }
    override func viewDidLoad() {
        self.allDates = [String]()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.currentDate = dateFormatter.string(from: date)
        self.currentDateTextLabel.text = " Current Date: " + (self.currentDate)!
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

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
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask], currentDate: String, taskType: String) {
        //
    }
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        //
    }
    
    func onAuthChange(change: DatabaseChange, currentUser: User?) {
        //
    }
    
    func onDateChange(change: DatabaseChange, allDates: [String]) {
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
