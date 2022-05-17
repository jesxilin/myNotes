//
//  EditNoteViewController.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/3/22.
//

import Foundation
import UIKit
import WebKit
import PDFKit
import Firebase

class EditNoteViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    // Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    
    // Var
    var selectedNote: Note!
    
    // Singleton
    let userShared = User.sharedInstance
    let notesShared = NotesModel.sharedInstance
    
    // Load bg before the view loaded, set dark/light mode
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userShared.getMode() {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        loadBg()
    }
    
    // set text fields to corresponding texts, sets delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.text = selectedNote.getTitle()
        contentTextView.text = selectedNote.getText()
        titleTextField.delegate = self
        contentTextView.delegate = self
    }
    
    // dismiss keyboard if bg is tapped
    @IBAction func bgDidTapped(_ sender: UITapGestureRecognizer) {
        if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        }
    }
    
    //When return key is pressed, dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           self.view.endEditing(true)
           return true
    }
    
    // Present different options for saving, pdf and save in general
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        // Save PDF choice
        let pdfAction = UIAlertAction(title: "Save as PDF", style: .default) { UIAlertAction in
            // Call to save pdf
            self.savePDF()
        }
        // Save note changes
        let saveAction = UIAlertAction(title: "Save Note", style: .default) { UIAlertAction in
            self.save()
        }
        // Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
        optionMenu.addAction(pdfAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // Save to firebase and update
    func save() {
        Firestore.firestore().collection("notes").document(selectedNote.getDocuId()).updateData([
            "innerText": contentTextView.text!,
            "title": titleTextField.text!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                // need to repopulate
                self.notesShared.removeAllNotes() // reset array
                self.userShared.populate() // re-populate
            }
        }
    }
    
    // Load BG
    func loadBg () {
        // Show on webView
        let theUrl = URL(string: selectedNote.getImageURL())!
        let request = URLRequest(url: theUrl)
        DispatchQueue.main.async {
            self.webView.load(request)
        }
    }
    
    // Save as PDF
    func savePDF () {
        // CREATE PDF
        let documentFolderPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        var t = titleTextField.text!.replacingOccurrences(of: " ", with: "_")
        // try to get filePath
        if let filePath = URL(string: "\(documentFolderPath.first!)/\(t).pdf"){
            let format = UIGraphicsPDFRendererFormat()
            let pdfMetadata = [
                // The name of the application creating the PDF.
                kCGPDFContextCreator: "myNotes",
                
                // The title of the PDF.
                kCGPDFContextTitle: selectedNote.getTitle()
            ]
            // COMMAND SHIFT G to get to file
            format.documentInfo = pdfMetadata as [String: Any]
            let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect,
                                                 format: format)
            let data = renderer.pdfData { (context) in
                context.beginPage()
                  
                let paragraphStyle = NSMutableParagraphStyle()
                  paragraphStyle.alignment = .center
                let attributes = [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
                    NSAttributedString.Key.paragraphStyle: paragraphStyle
                  ]
                let title = titleTextField.text!
                let titleRect = CGRect(x: 80, // left margin
                                        y: 80, // top margin
                                    width: 200,
                                   height: 20)
                let text = contentTextView.text!
                let textRect = CGRect(x: 80, // left margin
                                        y: 110, // top margin
                                    width: 200,
                                   height: 500)
                title.draw(in: titleRect, withAttributes: attributes)
                text.draw(in: textRect, withAttributes: attributes)
            }
            
            let pdfDocument = PDFDocument(data: data)
            pdfDocument?.write(to: filePath)
            
            // VIEW PDF
            // Create and add a `PDFView` to the view hierarchy.
            let pdfView = PDFView(frame: view.bounds)
            view.addSubview(pdfView)
            // Create a `PDFDocument` object and set it as `PDFView`'s document to load the document in that view.
            let viewpdfDocument = PDFDocument(url: filePath)!
            pdfView.document = viewpdfDocument
        } else {
            // can't get file
            // alert user
            let alert = UIAlertController(title: "Error", message: "Can't convert to PDF. Make sure title is valid for filepath.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
}
