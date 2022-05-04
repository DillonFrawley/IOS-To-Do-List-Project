//
//  PreviewTaskViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 4/5/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class PreviewTaskViewController: UIViewController, DatabaseListener {

    var listenerType = ListenerType.allTasks
    weak var databaseController: DatabaseProtocol?
    
    var allTasks: [ToDoTask] = []
    
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
    
    func onTaskChange(change: DatabaseChange, currentTasks: [ToDoTask], completedTasks: [ToDoTask], currentDate: String, taskType: String) {
        //
    }
    
    func onDateChange(change: DatabaseChange, allDates: [String]) {
        //
    }
    
    func onAllTaskChange(change: DatabaseChange, allTasks: [ToDoTask]) {
        self.allTasks = allTasks
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
