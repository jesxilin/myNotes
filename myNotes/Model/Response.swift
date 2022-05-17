//
//  Response.swift
//  myNotes
//
//  Created by JESSICA CHEUNG cheungje@usc.edu on 5/2/22.
//

import UIKit
// For decoding API response
struct Response: Decodable{
    let total: Int
    let totalHits: Int
    let hits: [Hit]
    
    enum CodingKeys: String, CodingKey {
        case total, totalHits, hits
      }
}
