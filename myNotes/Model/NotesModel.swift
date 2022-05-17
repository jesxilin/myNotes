//
//  NotesModel.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import Foundation

class NotesModel: NotesDataModel {
    // Properties
    private var notes: Array<Note> = []
    
    // Swift Singleton pattern
    static let sharedInstance = NotesModel()
    
    // returns # of notes
    func numberOfNotes() -> Int {
        return notes.count
    }
    
    // gets note at index
    func note(at index: Int) -> Note? {
        if index < notes.count {
            return notes[index]
        }
        return nil
    }
    
    // Inserts note to notes array
    func insert(title: String, innerText: String, imageURL: String, documentId: String) {
        notes.append(Note(title: title, innerText: innerText, imageURL: imageURL, documentId: documentId))
    }
    
    // Removes a note if want to delete
    func removeNote(at index: Int) {
        if index < notes.count {
            // can remove
            notes.remove(at: index)
        }
    }
    
    // Clears array
    func removeAllNotes() {
        notes.removeAll()
    }
}
