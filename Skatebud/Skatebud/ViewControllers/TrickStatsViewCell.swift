//
//  TrickStatsViewCell.swift
//  Skatebud
//
//  Created by Thursheyco Arreguin on 1/7/21.
//

import UIKit

class TrickStatsViewCell: UITableViewCell {

    // Properties
    @IBOutlet weak var tricksNameLbl: UILabel!
    @IBOutlet weak var numOfAttempts: UILabel!
    
    // Property to hold current Trick to increment or decrement
    var trick: Trick!
    
    // Variable to hold the index of the selected trick
    var trickIndex = 0
    
    // Declare delegate for protocol on stats vc
    var trickSelectionDelegate: TrickSelection?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Actions
    @IBAction func minusTapped(_ sender: UIButton) {
        
        // DEBUG: print minus tap
        print("minus tap")
        
        // Get total attempts
        var attempts = trick.countFailed + trick.countLanded
        
        // DEBUG: print attempts
        print(attempts)
        
        // Check that trick's attempts is not already zero
        if attempts != 0 {
            
            // Decrement land count
            //trick.count -= 1
            
            // Increment countFailed
            trick.countFailed += 1
            attempts = trick.countLanded + trick.countFailed
        }
        
        // Display new trick count
        numOfAttempts.text = "\(attempts)"
        
        // Delegate method
        trickSelectionDelegate?.addTrickLandCount(trick: trick, atIndex: trickIndex)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        
        // DEBUG: print add tap
        print("add tap")
        
        // Update trick's count in array
        //trick.count += 1
        
        // Increment countLanded
        trick.countLanded += 1
        
        // Increment attempts
        //trick.attempts += 1
        let attempts = trick.countFailed + trick.countLanded
        
        // Display new land count
        numOfAttempts.text = "\(attempts)"
        
        // Delegate method
        trickSelectionDelegate?.addTrickLandCount(trick: trick, atIndex: trickIndex)
    }
    
}
