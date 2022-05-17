//
//  AddNoteViewController.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import UIKit
import Firebase
import WebKit

class AddNoteViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    let BASE_URL: String = "https://pixabay.com/api/"
    let KEY: String = "27150965-e2edd4255230a12c404a270b2"
    
    // Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Variables
    var search: String = ""
    var theTitle: String = ""
    var content: String = ""
    var imageURL: String = ""
    
    let userShared = User.sharedInstance
    let notesShared = NotesModel.sharedInstance
    
    // disable save button, sets delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = true
        titleTextField.delegate = self
        searchTextField.delegate = self
        textView.delegate = self
    }
    
    // Gets BG for the note, set dark/light mode
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBg()
        if userShared.getMode() {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    
    // dismiss keyboard when bg is tapped
    @IBAction func bgDidTapped(_ sender: UITapGestureRecognizer) {
        if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
        if searchTextField.isFirstResponder {
            searchTextField.resignFirstResponder()
        }
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    //When return key is pressed, dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return true
    }
    
    // Change title to user input
    @IBAction func titleDidChange(_ sender: UITextField) {
        theTitle = titleTextField.text!
    }
    
    // Gets user input from text view
    func textViewDidChange(_ textView: UITextView) {
        content = textView.text!
    }
    
    //If user searches something, update bg image
    @IBAction func searchDidInput(_ sender: UITextField) {
        search = "&q=\(searchTextField.text!)"
        getBg() // reload the bg
    }
    
    // Save the note to firestore
    @IBAction func saveDidTapped(_ sender: UIBarButtonItem) {
        Firestore.firestore().collection("notes").addDocument(data: [
            "innerText": content,
            "imageURL": imageURL,
            "title": theTitle,
            "userId": userShared.getUid()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                // Save was successful
                print("Document added.")
                self.saveButton.isEnabled = false
                self.notesShared.removeAllNotes() // reset array
                self.userShared.populate() // re-populate
            }
        }
    }
    
    // HTTP request to get background image, also saves imageURL to current BG
    func getBg(){
        let url = URL(string: "\(BASE_URL)?key=\(KEY)\(search)&image_type=photo&orientation=vertical&safesearch=true")!
        
        var request = URLRequest(url: url)
        //print(request)
        URLSession.shared.dataTask(with: request) { data, response, error in
            // When API comes back, handle response
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
            }
            if let data = data {
                do{
                    let theResponse = try JSONDecoder().decode(Response.self, from: data)
                    for results in theResponse.hits {
                        print(results)
                    }
                    // Get random
                    let randomNum = Int.random(in: 0...theResponse.hits.count-1)
                    // Show on webView
                    let theUrl = URL(string: theResponse.hits[randomNum].largeImageURL)!
                    let request = URLRequest(url: theUrl)
                    DispatchQueue.main.async {
                        self.webView.load(request)
                    }
                    // Change the imageURL to the current image
                    self.imageURL = theResponse.hits[randomNum].largeImageURL
                } catch let error {
                    print(error.localizedDescription)
                    exit(1)
                }
            }
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
                return
            }
        }.resume()
    }
}
