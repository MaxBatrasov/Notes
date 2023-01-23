//
//  Note.swift
//  Notes
//
//  Created by Максим Батрасов on 27.12.2022.
//

import Foundation

class Note {
    var name: String?
    var text: String?
    var image: String?
    
    init(name: String, text: String, image: String) {
        self.name = name
        self.text = text
        self.image = image
    }
}
