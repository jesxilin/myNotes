//
//  TableViewController.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import UIKit
import Firebase
class TableViewController: UITableViewController {
    //Properties
    let userShared = User.sharedInstance
    let notesShared = NotesModel.sharedInstance
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // Set up for before view appears, reload data and set dark/light mode
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userShared.getMode() {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
        tableView.reloadData()
    }
    
    // For loading view
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Num of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // Limit of how many cells for table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesShared.numberOfNotes()
    }
    
    // Populate tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")!

        // Get Question and Answer
        let theNote = notesShared.note(at: indexPath.row)
        
        cell.textLabel?.text = theNote?.getTitle()
        return cell
    }
    
    // Pass data to get current edit note
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditNoteViewController {
            let index = tableView.indexPathForSelectedRow!.row
            vc.selectedNote = notesShared.note(at: index)
        }
    }
    
    // Toggle edit
    @IBAction func editDidTapped(_ sender: UIBarButtonItem) {
        if tableView.isEditing{
            tableView.isEditing = false
            editButton.title = "Edit"
        }
        else{
            tableView.isEditing = true
            editButton.title = "Done"
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete from notes in firestore
            Firestore.firestore().collection("notes").document((notesShared.note(at: indexPath.row)?.getDocuId())!).delete(){ err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    // Then delete notes array and re-populate
                    self.notesShared.removeNote(at: indexPath.row)
                    // Delete table cell
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    //self.userShared.populate() // re-populate
                    self.tableView.reloadData()
                }
            }
        }
    }
}
