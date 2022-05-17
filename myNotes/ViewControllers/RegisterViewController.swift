//
//  RegisterViewController.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // variables
    var email: String = ""
    var pass: String = ""
    
    // singleton
    let userShared = User.sharedInstance
    
    // Assign first responder and delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passTextField.delegate = self
        emailTextField.becomeFirstResponder()
        saveButton.isEnabled = false
    }
    
    // When user is done typing into input, save as email
    @IBAction func emailDidInput(_ sender: UITextField) {
        email = emailTextField.text!
    }
    
    // Assigns password and enables save button
    @IBAction func passDidInput(_ sender: UITextField) {
        pass = passTextField.text!
        if pass == "" {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    // Dismiss view back to Login
    @IBAction func backDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // If suffices requirements, then add user to Firebase. Uses User class' validate email function
    @IBAction func saveDidTapped(_ sender: UIButton) {
        if userShared.isValidEmail(email: email) && pass.count >= 6 {
            // Can add user
            Auth.auth().createUser(withEmail: email, password: pass) { authResult, error in
                if let _eror = error {
                    //has failed
                    print("error")
                    print(_eror.localizedDescription)
                    let alert = UIAlertController(title: "Alert", message: _eror.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    // Clear fields
                    self.emailTextField.text = ""
                    self.passTextField.text = ""
                } else {
                    // user registered successfully, should return back to Login Page
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            // means the requirements are not met. Should alert user.
            let alert = UIAlertController(title: "Alert", message: "Could not register. User exists or requirements not fulfilled. Try again.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            // Clear fields
            emailTextField.text = ""
            passTextField.text = ""
        }
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

