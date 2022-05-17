//
//  NotesDataModel.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import Foundation

// Potocol for methods Notes should have
protocol NotesDataModel {
    func numberOfNotes() -> Int
    func note(at index: Int) -> Note?
    func insert(title: String, innerText: String, imageURL: String, documentId: String)
    func removeNote(at index: Int)
    func removeAllNotes()
}
