//
//  LogInSignUpViewController.swift
//  FIT3178-Productive
//
//  Created by Dillon Frawley on 26/4/2022.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class LogInSignUpViewController: UIViewController, DatabaseListener {
    
    var listenerType = ListenerType.auth
    weak var databaseController: DatabaseProtocol?
    
    var currentEmail:String?
    var currentPassword: String?
    var currentUser: FirebaseAuth.User?

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func logInAction(_ sender: Any) {
        if emailTextField.text != nil && passwordTextField.text != nil {
            if emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false {
                if self.whitespaceBool(string: (emailTextField.text)!) == true && self.whitespaceBool(string: (passwordTextField.text)!) {
                    if (self.emailTextField.text)!.isValidEmail == true && (self.passwordTextField.text)!.count > 5 {
                        guard let email: String = emailTextField.text?.lowercased(), let password: String = passwordTextField.text?.lowercased() else {
                            return
                        }
                        self.currentEmail = email
                        self.currentPassword = password
                        let _ = databaseController?.signIn(email: email, password: password)
                        
                    }
                    else {
                        let errorMsg = "Email is invalid or password is not at least 6 characters"
                        displayMessage(title: "Invalid input", message: errorMsg)
                    }
                    
                }
                else {
                    let errorMsg = "Please ensure inputs are not whitespace bools"
                    displayMessage(title: "Invalid input", message: errorMsg)
                }
            }
            else {
                let errorMsg = "Please an input"
                displayMessage(title: "Invalid input", message: errorMsg)
            }
            
        }
        else if (emailTextField.text!).isEmpty || (passwordTextField.text!).isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if (emailTextField.text!).isEmpty {
                errorMsg += "- Must provide a name\n" }
            if (passwordTextField.text!).isEmpty {
                errorMsg += "- Must provide abilities"
                
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
    }
    
    
    @IBAction func signUpAction(_ sender: Any) {
        if emailTextField.text != nil && passwordTextField.text != nil {
            if emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false {
                if self.whitespaceBool(string: (emailTextField.text)!) == true && self.whitespaceBool(string: (passwordTextField.text)!) {
                    if (self.emailTextField.text)!.isValidEmail == true && (self.passwordTextField.text)!.count > 5 {
                        guard let email: String = emailTextField.text?.lowercased(), let password: String = passwordTextField.text?.lowercased() else {
                            return
                        }
                        self.currentEmail = email
                        self.currentPassword = password
                        let _ = databaseController?.createNewSignIn(email: email, password: password)
                    }
                    else {
                        let errorMsg = "Email is invalid or password is not at least 6 characters"
                        displayMessage(title: "Invalid input", message: errorMsg)
                    }
                    
                }
                else {
                    let errorMsg = "Please ensure inputs are not whitespace bools"
                    displayMessage(title: "Invalid input", message: errorMsg)
                }
            }
            else {
                let errorMsg = "Please an input"
                displayMessage(title: "Invalid input", message: errorMsg)
            }
            
        }
        else if (emailTextField.text!).isEmpty || (passwordTextField.text!).isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if (emailTextField.text!).isEmpty {
                errorMsg += "- Must provide a name\n" }
            if (passwordTextField.text!).isEmpty {
                errorMsg += "- Must provide abilities"
                
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
//        if self.databaseController?.currentUser != nil {
//            self.onAuthChange(change: .update, currentUser: (self.databaseController?.currentUser)!)
//        }
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
    
    func onTaskChange(change: DatabaseChange, tasks: [ToDoTask], taskType: String) {
        //
    }
    
    func onAuthChange(change: DatabaseChange, currentUser: FirebaseAuth.User?) {
        if currentUser != nil {
            self.currentUser = currentUser
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "authSegue", sender: self)
            }
        }
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}

