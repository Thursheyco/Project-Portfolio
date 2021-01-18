//
//  Trick.swift
//  Skatebud
//
//  Created by Thursheyco Arreguin on 1/8/21.
//

import Foundation

// Class to represent a skateboarding trick
class Trick {
    
    // Stored Properties
    var name: String
    var countLanded: Int
    var countFailed: Int
    
    // Computed Properties
    var trickInfo: String {
        get {
            return "Trick name: " + name + ", landed: " + countLanded.description + ", failed: " + countFailed.description
        }
    }
    
    // Initializers
    init(name: String, countLanded: Int, countFailed: Int) {
        self.name = name
        self.countLanded = countLanded
        self.countFailed = countFailed
    }
}
