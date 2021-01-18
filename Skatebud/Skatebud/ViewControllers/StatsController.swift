//
//  StatsController.swift
//  Skatebud
//
//  Created by JAROD SMITH on 1/5/21.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

// Protocol to increment or decrement trick land count
protocol TrickSelection {
    func addTrickLandCount(trick: Trick, atIndex: Int)
}

class StatsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, TrickSelection {
    
    // Properties
    @IBOutlet weak var tricksTableView: UITableView!
    
    // Array that contains all tricks to choose from when adding
    var choices = ["Ollies", "Shuv-its", "Kickflips", "Heelflips"]
    
    // The type of data in pickerView
    var typeValue = String()
    
    // Declare an empty array of Trick objects
    var tricks = [Trick]()
    //var trickArray: [String] = []
    
    // Create a variable to hold a reference to Firebase Database
    var ref: DatabaseReference!
    
    // Declare a variable to hold the name of trick selected in table view
    var trickToSend: Trick?
    var trickToSendNew: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register xib file
        let headerNib = UINib.init(nibName: "CustomHeaderView", bundle: nil)
        tricksTableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "header_ID1")
        
        // Change the height of the table view cell
        tricksTableView.rowHeight = 70
        
        // Variable to hold Helper to check internet connection
        let hasInternet = Helper.checkInternetConnection()
        
        // DEBUG: print status of internet
        print(hasInternet)
        
        // Check if internet conection is false
        if hasInternet == false {
            
            // Alert user that the internet is not connected
            let alert = UIAlertController(title: "ALERT", message: "Internet is required", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Save data to Firebase Database
        ref = Database.database().reference(fromURL: "https://skateboarding-notes-stats-default-rtdb.firebaseio.com/")
        
        updateTrickArray()
        
    }
    
    //get a list of tricks for the user to pick
    func updateTrickArray(){
        print("updateTrickArray")
        Database.database().reference().child("tricks").observe(.value) { (snapshot) in
            
            self.choices.removeAll(keepingCapacity: false)
            var nameArray: [String] = []
            for trick in snapshot.children.allObjects as! [DataSnapshot] {
                let tricksObject = trick.value as? [String:AnyObject]
                let trickName = tricksObject!["name"] as? String
                if trickName != nil {
                    nameArray.append(trickName!)
                }
                nameArray.sort()
                
            }
            self.choices = nameArray
            self.tricksTableView.reloadData()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check if user is logged in
        let loggedIn = Helper.checkFirebaseLogin()
        if loggedIn != false {
            
            //getDBfromFB()
            getDBfromFBNew()
        } else {
            // User is not logged in clear tricksTableView
            tricks.removeAll()
            tricksTableView.reloadData()
        }
    }
    
//    func getDBfromFB(){
//        print("getDBfromFB")
//        // Check if user is logged in
//        if Auth.auth().currentUser?.uid != nil  {
//
//            // Variable to hold the latest tricks from database
//            var newTricks = [Trick]()
//
//            // Read back the tricks user has saved to Firebase
//            let uid = Auth.auth().currentUser!.uid
//            Database.database().reference().child("tricks").child(uid).observe(.value) { (snapshot) in
//
//                // Retrieve trick name, count, tCountLanded, tCountFailed
//                for trick in snapshot.children.allObjects as! [DataSnapshot] {
//                    let tricksObject = trick.value as? [String:AnyObject]
//                    let trickName = tricksObject!["name"] as! String
//                    let trickCount = tricksObject!["count"] as! String
//                    let trickCountLanded = tricksObject!["tCountLanded"] as! String
//                    let trickCountFailed = tricksObject!["tCountFailed"] as! String
//                    let attempts = tricksObject!["attempts"] as! String
//
//                    // Add to array
//                    newTricks.append(Trick(name: trickName, count: Int(trickCount)!, countLanded: Int(trickCountLanded)!, countFailed: Int(trickCountFailed)!, attempts: Int(attempts)!))
//                }
//
//                // Add newTricks to tricks on Stats vc
//                self.tricks = newTricks
//                self.tricksTableView.reloadData()
//            }
//        }
//    }
    
    // get an array of tricks the user has
    func getDBfromFBNew(){
        print("getDBfromFBNew")

        let uid = Auth.auth().currentUser!.uid
        
        Database.database().reference().child("users").child(uid).observe(.value) {(snapshot) in
            
            var array:[String] = []
            
            // Variable to hold the latest tricks from database
            var newTricks = [Trick]()
            
            for trick in snapshot.children.allObjects as! [DataSnapshot]{
                
                let trickObj = trick.value as? [String:Any]
                
                let trickKeys = trickObj?.keys
                
                // Get the values for a trick
                let trickValues = trickObj?.values
                
                if trickKeys !=  nil {
                    
                    // Get name of trick
                    for t in trickKeys! {
                        array.append(t)
                    }
                }
                
                // Check if trickValues is not nil
                if trickValues != nil {
                    
                    // Variable to help loop through array for trick name
                    var i = 0
                    
                    // Loop through values
                    for v in trickValues! {
                        
                        // Get trick's stats
                        let statsObj = v as? [String:Any]
                        
                        // DEBUG: print statsObj
                        print(v)
                        // DEBUG: print i
                        print(i)
                        
                        // Cast tCountFailed to Int
                        let countFailed = statsObj!["tCountFailed"] as? Int ?? 0
                        // Cast tCountLanded to Int
                        let countLanded = statsObj!["tCountLanded"] as? Int ?? 0
                        
                        // Get values of trick
                        newTricks.append(Trick(name: array[i], countLanded: countLanded, countFailed: countFailed))
                        
                        // Increment i
                        i += 1
                    }
                }
            }
//            self.trickArray = array
//            print(self.trickArray.count)
            
            // Add newTricks to tricks
            self.tricks = newTricks

            self.tricksTableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //getAddedTricks()
        //getAddedTricksNew()
        // Check if there are any tricks in the table view
        if tricks.count > 0 {
            // Empty dictionary to hold tricks in table view
            var values = [String:Any]()
            // Loop through tricks
            for trick in tricks {
                // A child reference
                let tricksReference = self.ref.child("users").child((Auth.auth().currentUser!.uid)).child("user-tricks").child(trick.name)
                // Save tricks stats to firebase
                values["notes"] = ""
                values["tCountLanded"] = trick.countLanded
                values["tCountFailed"] = trick.countFailed
                // Set values
                tricksReference.setValue(values)
            }
        }
    }

//    func getAddedTricks(){
//        print("getAddedTricks")
//        // Check if there are any tricks in the table view
//        if tricks.count > 0 {
//
//            // Empty dictionary to hold tricks in table view
//            var values = [String:String]()
//
//            // Loop through tricks
//            for trick in tricks {
//
//                // A child reference
//                let tricksReference = self.ref.child("tricks").child((Auth.auth().currentUser!.uid)).child(trick.name.lowercased())
//
//                // Save tricks & their count to firebase
//                values["name"] = trick.name
//                values["count"] = trick.count.description
//                values["tCountLanded"] = trick.countLanded.description
//                values["tCountFailed"] = trick.countFailed.description
//                values["attempts"] = trick.attempts.description
//
//                // Set values
//                tricksReference.setValue(values)
//            }
//        }
//    }
    
//    func getAddedTricksNew(){
//        print("getAddedTricksNew")
//        if trickArray.count > 0 {
//            print("GT")
//        }
//    }
    

    
    // Segue to send the chosen continents name forward
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Declare destination vc
        let destination: TrickStatsViewController = segue.destination as! TrickStatsViewController
        
        // Set the current trick of slectedTrick in TrickStatsViewController
        destination.selectedTrick = trickToSend
    }
    
    // MARK: - Actions
    @IBAction func addTrickTapped(_ sender: UIButton) {
        
        // Check if user is logged in here
        let loggedIn = Helper.checkFirebaseLogin()
        if loggedIn != false {
            // DEBUG: print user tapped add
            print("User tapped add")
            
            // Create  frame for pickerView
            let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
            
            // Use a UIAlertController to add a new Trick to tableView
            let alert = UIAlertController(title: "Add Trick", message: "Select a trick from list below.\n\n\n\n\n\n", preferredStyle: .alert)
            
            // Add pickerView to alert controller
            alert.view.addSubview(pickerFrame)
            
            // Set datasource & delegate for pickerView
            pickerFrame.dataSource = self
            pickerFrame.delegate = self
            
            // Add action buttons
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in print("Canceled")}))
            
            alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
                
                // DEBUG: print selection
                print("You selected: " + self.typeValue)
                
                // TODO: check if user doesn't select anything they must mean "Ollies"
                
                // Create Trick
                let newTrick = self.typeValue
                let trickLands = 0
                let trickFails = 0
                let trick = Trick(name: newTrick, countLanded: trickLands, countFailed: trickFails)
                
                for t in self.tricks{
                    if t.name == newTrick{
                        return
                    }
                }
                
                // DEBUG: print trick
                print(trick.trickInfo)
                
                // Add trick to tricks array
                self.tricks.append(trick)
                //self.trickArray.append(newTrick)
                self.ref.child("users").child(Auth.auth().currentUser!.uid).child("user-tricks").child(newTrick).child("tCountLanded").setValue(0)
                self.ref.child("users").child(Auth.auth().currentUser!.uid).child("user-tricks").child(newTrick).child("tCountFailed").setValue(0)
                self.ref.child("users").child(Auth.auth().currentUser!.uid).child("user-tricks").child(newTrick).child("notes").setValue("")

                
                // Reload tableView
                self.tricksTableView.reloadData()
            }))
            
            // Show alert
            self.present(alert, animated: true)
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
    
    // Method to select a trick to increment or decrement
    func addTrickLandCount(trick: Trick, atIndex: Int) {
        
        // Select the Trick at the passed in index
        tricks[atIndex] = trick
        
        // DEBUG: print trick's name, tCountLanded, tCountFailed
        print(trick.trickInfo)
    }
    
    @IBAction func profileTapped(_ sender: UIButton) {
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
        print("numberOfRowsInSection")
        // Check if user is not logged in or if they have not entered a trick here
//        if tricks.count == 0 {
//            print("tricks empty")
//            // Set empty view for tricksTableView
//            tricksTableView.setUpEmptyView(title: "You don't have tricks yet.", message: "Added tricks appear here.")
//        } else {
//            print("has tricks")
//
//            // Restore tricksTableView
//            tricksTableView.restore()
//        }
        
        if tricks.count == 0 {
            tricksTableView.setUpEmptyView(title: "You don't have tricks yet.", message: "Added tricks appear here.")
            print("tricksarray empty")

        }else {
            print("has tricksarray")

            // Restore tricksTableView
            tricksTableView.restore()
        }
        
        //return tricks.count
        return tricks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        // Guard statement to retrieve custom table view cell or return a default table view cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseID", for: indexPath) as? TrickStatsViewCell
            else { print("guard failed") ; return tableView.dequeueReusableCell(withIdentifier: "reuseID", for: indexPath)}
        print("guard success")
        // Configure cell
        let currentTrick = tricks[indexPath.row]
        //let currentTrick = trickArray[indexPath.row]
        print(indexPath.row)
        print(currentTrick.trickInfo)
        
        // Pass Trick reference in array to increment trick land count
        cell.trick = tricks[indexPath.row]
        //cell.trick = trickArray[indexPath.row]
        
        // Set the labels for trick
        cell.tricksNameLbl.text = currentTrick.name
        
        // Get total attempts
        let attempts = currentTrick.countFailed + currentTrick.countLanded
        cell.numOfAttempts.text = attempts.description
        
        // Pass the index of the currently selected trick
        cell.trickIndex = indexPath.row
        
        // Set delegate for trick selection to increment or decrement
        cell.trickSelectionDelegate = self
        
        // Return cell
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        // Send Trick selected
        trickToSend = tricks[indexPath.row]
        //trickToSendNew = trickArray[indexPath.row]
        // DEBUG: print selectedTrick
        //print(trickToSend!.trickInfo)
        //print(trickToSendNew)
        // Send selected trick to trick's detail vc
        performSegue(withIdentifier: "toStatDetails", sender: trickToSend)
    }
    
    // MARK: - Header Methods
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 118
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create the view
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header_ID1") as? CustomHeaderView
        
        // Configure the view
        header?.numOfTricks.text = tricks.count.description
        
        // Return view
        return header
    }
    
    // MARK: - Picker view's delgates & datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        typeValue = choices[row]
        return choices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
}

// MARK: tricksTableView extension method
extension UITableView {
    
    // Create a method to setup an empty view for when tricksTableView is empty
    func setUpEmptyView(title: String, message: String) {
        print("setUpEmptyView")
        // Create empty view
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        // Create text label for title
        let titleLbl = UILabel()
        
        // Create label for description
        let messageLbl = UILabel()
        
        // Turn translating to auto resizing mask into constaints off for title & message
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        messageLbl.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the color for title text to black
        titleLbl.textColor = UIColor.black
        
        // Set text type for title
        titleLbl.font = UIFont(name: "AvenirNext-Medium", size: 18)
        
        // Set color for message to gray
        messageLbl.textColor = UIColor.lightGray
        messageLbl.font = UIFont(name: "AvenirNext-Medium", size: 17)
        
        // Add text to empty view
        emptyView.addSubview(titleLbl)
        emptyView.addSubview(messageLbl)
        
        // Constrain titleLbl to center of empty view
        titleLbl.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLbl.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        // Constrain messageLbl to center of empty view
        messageLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 20).isActive = true
        messageLbl.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLbl.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        // Set text for empty view text lables
        titleLbl.text = title
        messageLbl.text = message
        
        // Set the number of lines for messageLbl
        messageLbl.numberOfLines = 0
        
        // Center text for message
        messageLbl.textAlignment = .center
        
        // Set backgroundView of tricksTableView as custom view
        self.backgroundView = emptyView
        
        // Set the seperator style to none
        self.separatorStyle = .none
    }
    
    // Method to use this extension
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
    
}
