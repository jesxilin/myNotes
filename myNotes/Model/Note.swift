//
//  Note.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import UIKit

struct Note {
    // Properties
    private var innerText: String;
    private var title: String;
    private var documentId: String;
    private var imageURL: String
    
    // initializer
    init(title: String, innerText: String, imageURL: String, documentId: String) {
        self.title = title
        self.innerText = innerText
        self.documentId = documentId
        self.imageURL = imageURL
    }
    
    // gets title
    func getTitle() -> String {
        return title
    }
    
    // gets text
    func getText() -> String {
        return innerText
    }
    
    // gets documentId
    func getDocuId() -> String {
        return documentId
    }
    
    // gets image url
    func getImageURL() -> String {
        return imageURL
    }
}

