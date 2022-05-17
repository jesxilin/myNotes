//
//  ProfileViewController.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/3/22.
//

import Foundation
import UIKit
import Firebase

class ProfileViewController: UIViewController {
    // Outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Swift Singleton
    let userShared = User.sharedInstance
    
    // set mode for page
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userShared.getMode() {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    // set the darkmode boolean, set username
    override func viewDidLoad() {
        super.viewDidLoad()
        userShared.setMode(mode: darkModeSwitch.isOn)
        usernameLabel.text = userShared.getEmail()
    }
    
    // change darkmode boolean
    @IBAction func switchDidChange(_ sender: UISwitch) {
        userShared.setMode(mode: darkModeSwitch.isOn)
        if userShared.getMode() {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    // log out user
    @IBAction func logoutDidTapped(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            // Dismiss back to Login
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // alert user
            let alert = UIAlertController(title: "Alert", message: "Error signing out. Try again later.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // Deletes user from firebase auth
    @IBAction func deleteDidTapped(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        let uid = userShared.getUid()
        user?.delete { error in
          if let error = error {
              // An error happened.
              print(error.localizedDescription)
              // alert user
              let alert = UIAlertController(title: "Alert", message: "Could not delete user. Try again later.", preferredStyle: UIAlertController.Style.alert)
              alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
              self.present(alert, animated: true, completion: nil)
          } else {
              // Account deleted.
              // Delete all notes that corresponded to that user
              //Go back to Login Page
              self.userShared.deleteDocs()
              self.dismiss(animated: true, completion: nil)
          }
        }
    }
    
    
    
    
}
