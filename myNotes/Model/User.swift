//
//  User.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import UIKit
import Firebase

class User {
    // Properties
    private var uid: String = ""
    private var darkMode: Bool = false
    private var email: String = ""
    
    // Swift Singleton
    static let sharedInstance = User()
    let noteShared = NotesModel.sharedInstance
    
    // set dark mode to user preference
    func setMode(mode: Bool){
        darkMode = mode
    }
    
    // get darkmode boolean
    func getMode() -> Bool {
        return darkMode
    }
    
    // set uid
    func setUid(id: String) {
        uid = id
    }
    
    // get uid
    func getUid()-> String {
        return uid
    }
    
    // set email
    func setEmail(theEmail: String) {
        email = theEmail
    }
    
    // get email
    func getEmail() -> String {
        return email
    }
    
    // Check if email is valid
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
    
    // Populate the notes and get notes from firestore that correspond to this user
    func populate(){
        let results = Firestore.firestore().collection("notes").whereField("userId", isEqualTo: uid)
        results.getDocuments { snapshot, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    print(data)
                    self.noteShared.insert(title: data["title"] as! String, innerText: data["innerText"] as! String, imageURL: data["imageURL"] as! String, documentId: document.documentID)
                }
            }
        }
    }
    
    // Delete all documents that correspond to this uid
    func deleteDocs() {
        let results = Firestore.firestore().collection("notes").whereField("userId", isEqualTo: uid)
        results.getDocuments { snapshot, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for document in snapshot!.documents {
                    Firestore.firestore().collection("notes").document(document.documentID).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }
            }
        }
    }
}
