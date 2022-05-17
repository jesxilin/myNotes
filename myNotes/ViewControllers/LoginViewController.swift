//
//  LoginViewController.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    // Variables
    var email: String = ""
    var pass: String = ""
    
    // Singleton
    let userShared = User.sharedInstance
    
    // diables login button, so cannot submit empty fields, sets delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.isEnabled = false
        emailTextField.delegate = self
        passTextField.delegate = self
    }
    // set email to input
    @IBAction func emailDidInput(_ sender: UITextField) {
        email = emailTextField.text!
    }
    // set pass to input, enable login button
    @IBAction func passDidInput(_ sender: UITextField) {
        pass = passTextField.text!
        if pass == "" {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
        }
    }
    
    // When tapped, should see if the user exists and allow login or not
    @IBAction func loginDidTapped(_ sender: Any) {
        if userShared.isValidEmail(email: email) && pass.count >= 6 {
            // Can sign in user
            Auth.auth().signIn(withEmail: email, password: pass) {(user, error) in
                    if user != nil {
                        print("User Has Sign In")
                        // Set user fields
                        self.userShared.setUid(id: Auth.auth().currentUser!.uid)
                        self.userShared.setEmail(theEmail: (Auth.auth().currentUser?.email)!)
                        print(self.userShared.getUid())
                        self.userShared.populate()
                        // Clear fields
                        self.emailTextField.text = ""
                        self.passTextField.text = ""
                        self.performSegue(withIdentifier: "toTabBar", sender: self)
                    }
                    if error != nil {
                        print(error)
                        // Clear fields
                        let alert = UIAlertController(title: "Alert", message: "Email or Password is incorrect.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.emailTextField.text = ""
                        self.passTextField.text = ""
                        //reset first responder
                        self.emailTextField.becomeFirstResponder()
                    }
            }
        } else {
            // means the requirements are not met. Should alert user.
            let alert = UIAlertController(title: "Alert", message: "Email or Password is incorrect.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            // Clear fields
            emailTextField.text = ""
            passTextField.text = ""
            //reset first responder
            self.emailTextField.becomeFirstResponder()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "toTabBar" {
            return false
        }
        return true
    }
    
    //When return key is pressed, dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return true
    }
    
    // When BG is tapped, dismiss keyboard
    @IBAction func bgDidTapped(_ sender: UITapGestureRecognizer) {
        if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
        }
        if passTextField.isFirstResponder {
            passTextField.resignFirstResponder()
        }
    }
}
