//
//  TricksController.swift
//  Skatebud
//
//  Created by JAROD SMITH on 1/5/21.
//

import Foundation
import UIKit
import FirebaseDatabase

class TricksController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Properties
    @IBOutlet weak var tableView: UITableView!
    
    // Array that contains all tricks to choose from
    //var choices = ["Ollies", "Shuv-its", "Kickflips", "Heelflips"]
    var choices:[String] = []
    // Declare a variable to hold the name of trick selected in table view
    var trickToSend: String?
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Change the height of the table view cell
        tableView.rowHeight = 70
        getTricks()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let hasInternet = Helper.checkInternetConnection()
        if hasInternet == false {
            
            // Alert user that the internet is not connected
            let alert = UIAlertController(title: "ALERT", message: "Internet is required", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        } else {
            print("ran")
        }
    }
    
    func getTricks(){
        Database.database().reference().child("tricks").observe(.value) { (snapshot) in
            
            self.choices.removeAll(keepingCapacity: false)
            var nameArray: [String] = []
            for trick in snapshot.children.allObjects as! [DataSnapshot] {
                let tricksObject = trick.value as? [String:AnyObject]
                let trickName = tricksObject!["name"] as? String
                if trickName != nil {
                    nameArray.append(trickName!)
                    print(trickName!)
                }
                nameArray.sort()
                
            }
            self.choices = nameArray
            self.tableView.reloadData()
            print(self.choices.count)
        }
    }
    
    // Segue to send the chosen continents name forward
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Declare destination vc
        let destination: TricksDetailController = segue.destination as! TricksDetailController
        
        // Set the current trick of trickNameLbl
        destination.trickName = trickToSend
    }
    
    // MARK: Actions
    @IBAction func profileTapped(_ sender: UIButton) {
        
        // DEBUG: print user profile tapped
        print("user profile tapped")
        
        // Check if user is logged in here
        let loggedIn = Helper.checkFirebaseLogin()
        if loggedIn != false {
            
            // Transition to ProfileViewController
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let profileController = storyBoard.instantiateViewController(identifier: "profileVC") as! ProfileViewController
            self.present(profileController, animated: true, completion: nil)
        } else {
            // Alert user they are not signed in
            let alert = UIAlertController(title: "Warning!", message: "You must login or sign up first.", preferredStyle: .alert)
            
            // Cancel button
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in print("Canceled")}))
            
            // Add button
            alert.addAction(UIAlertAction(title: "GO SKATE", style: .default, handler: { (action) in
                
                // Present the login view controller
                let loginViewController = self.storyboard?.instantiateViewController(identifier: "loginVC") as! ViewController
                self.present(loginViewController, animated: true, completion: nil)
            }))
            
            // Show alert
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource Protocols Callbacks
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("num of rows")

        return choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        // Guard statement to retrieve custom table view cell or return a default table view cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseID", for: indexPath) as? TrickViewCell
            else { return tableView.dequeueReusableCell(withIdentifier: "reuseID", for: indexPath)}
        
        // Set the labels for trick
        cell.trickNameLbl.text = choices[indexPath.row]
        
        // Return cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        // DEBUG: print chosen trick
        trickToSend = choices[indexPath.row]
        
        // Send chosen trick text to tricks detail vc
        performSegue(withIdentifier: "toTrickDetails", sender: choices[indexPath.row])
    }
}
