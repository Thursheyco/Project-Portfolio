//
//  TricksDetailController.swift
//  Skatebud
//
//  Created by JAROD SMITH on 1/5/21.
//

import Foundation
import UIKit
import YoutubePlayer_in_WKWebView
import FirebaseDatabase
import FirebaseAuth

class TricksDetailController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Properties
    @IBOutlet weak var trickNameLbl: UILabel!
    @IBOutlet weak var playerView: WKYTPlayerView!
    @IBOutlet weak var videoNameLbl: UILabel!
    @IBOutlet weak var viewsNumLbl: UILabel!
    @IBOutlet weak var lengthTimeLbl: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    //TRICK DETAIL BAR
    @IBOutlet weak var lev1: UIView!
    @IBOutlet weak var lev2: UIView!
    @IBOutlet weak var lev3: UIView!
    @IBOutlet weak var lev4: UIView!
    @IBOutlet weak var lev5: UIView!
    @IBOutlet weak var levelLbl: UILabel!
    
    
    // Declare a variable to hold the name of Trick from TricksController
    var trickName: String?
    var trickID: String = "jDZhiMMxlgM"
    var creator = ""
    var videoLength = ""
    var videoName = ""
    var notes: String?
    var countLanded = 0
    var countFailed = 0
    
    // Create a variable to hold a reference to Firebase Database
    var ref: DatabaseReference!
    
    // Instace variable to hold image or video to share
    var controller = UIImagePickerController()
    let videoFileName = "/video.mp4"
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set trickNameLbl to trick name
        if let t = trickName {
            trickNameLbl.text = t
            
            // Load skatebarding ollie video from youtube
            playerView.load(withVideoId: "jDZhiMMxlgM")
            
            // Load video details
            videoNameLbl.text = "How to ollie with Tony Hawk"
            viewsNumLbl.text = "1,803,707"
            lengthTimeLbl.text = "4:11"
            
            // Save note to Firebase Database
            ref = Database.database().reference(fromURL: "https://skateboarding-notes-stats-default-rtdb.firebaseio.com/")
            
            // Assign noteTextView delegate
            noteTextView.delegate = self
            
            // Code to help move view above keyboard
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    func loadTrickID(){
        print("loadTrickID")
        Database.database().reference().child("tricks").observe(.value) { (snapshot) in
            print(self.trickName!)
            for trick in snapshot.children.allObjects as! [DataSnapshot] {
                let tricksObject = trick.value as? [String:AnyObject]
                let trick = tricksObject!["name"] as? String
                if trick == self.trickName {
                    self.trickID = tricksObject!["trickID"] as! String
                    self.creator = tricksObject!["creator"] as! String
                    self.videoLength = tricksObject!["videoLength"] as! String
                    self.videoName = tricksObject!["videoName"] as! String
                }
            }
            self.loadTrickDetails()
        }
        
        print("end loadTrickID")
    }
    
    func loadTrickDetails(){
        print("loadTrickDetails")
        print(trickName!)
        trickNameLbl!.text =  trickName!
        // Load skatebarding ollie video from youtube
        
        playerView.load(withVideoId: trickID)
        
        // Load video details
        videoNameLbl.text = videoName
        viewsNumLbl.text = creator
        lengthTimeLbl.text = videoLength
        
        // Save note to Firebase Database
        ref = Database.database().reference(fromURL: "https://skateboarding-notes-stats-default-rtdb.firebaseio.com/")
        
        // Assign noteTextView delegate
        noteTextView.delegate = self
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check if user is logged in here. Also, find out how a note will appear
        checkLogin()
        loadTrickID()
        print(trickID)
        
    }
    
    func checkLogin(){
        let loggedIn = Helper.checkFirebaseLogin()
        if loggedIn == true {
            //getNotes()
            getNoteNew()
        }
    }
    
    func getNoteNew(){
        // Read back the tricks user has saved to Firebase
        print("getNoteNew")
        var failed = 0
        var landed = 0
        let uid = Auth.auth().currentUser!.uid
        Database.database().reference().child("users").child(uid).child("user-tricks").child(trickName!).observe(.value) {(snapshot) in
            //get notes
            print(snapshot)
            var failed = 0
            var landed = 0
            var notes = ""
            print(snapshot.childrenCount)
            if snapshot.childrenCount == 0 {
                return
            }
            
            notes = "\(snapshot.childSnapshot(forPath: "notes").value!)"
            failed = snapshot.childSnapshot(forPath: "tCountFailed").value! as? Int ?? 0
            landed = snapshot.childSnapshot(forPath: "tCountLanded").value! as? Int ?? 0

            
            print(notes)
            print(failed)
            print(landed)
            self.countLanded = failed
            self.countFailed = landed
            self.noteTextView.text = notes
            print("end get notees")
            self.updateLevelBar(trickLands: landed)
            //self.noteTextView.text = notes
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Invoke saveNotes() here when view is about to disappear to save out to Realtime database
        saveNotes()
    }
    
    // MARK: Actions
    @IBAction func clearNoteTapped(_ sender: UIButton) {
        
        noteTextView.text = ""
        let blankNote = ""
        notes = blankNote
        saveNotes()
        
    }
    
    @IBAction func attemptTrickTapped(_ sender: UIButton) {
        
        // Create the alert
        let alert = UIAlertController(title: trickName, message: "Enter attempt result.", preferredStyle: UIAlertController.Style.alert)
        
        // Add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Successful", style: UIAlertAction.Style.default, handler: { (action) in
            
            //update level bar and count
            
            self.countLanded = self.countLanded + 1
            //self.saveNotes()
            self.updateLevelBar(trickLands: self.countLanded)
        }))
        
        // Set up a failed attempt for Trick
        alert.addAction(UIAlertAction(title: "Failed", style: UIAlertAction.Style.default, handler: { (action) in
            
            //update level bar and count
            
            self.countFailed = self.countFailed + 1
            //self.saveNotes()
            self.updateLevelBar(trickLands: self.countFailed)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        // Show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            // Present controller to take a video
            controller.sourceType = .camera
            //controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            
            present(controller, animated: true, completion: nil)
        } else {
            // DEBUG: device does not have camera
            print("No camera")
        }
    }
    
    
    // MARK: UITextViewDelegates
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        notes = noteTextView.text
        saveNotes()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Check if the text is "\n"
        if text == "\n" {
            
            // Hide keyboard
            noteTextView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: updateLevelBar()
    func updateLevelBar(trickLands: Int){
        let trickLevel = Helper.levelsForSpecificTrick(successAttempts: trickLands)
        print("lands ",trickLands)
        print("level ", trickLevel)
        switch trickLevel {
        case 0:
            print("level 0")
            levelLbl.text = "Level 0"
        case 1:
            print("level 1")
            levelLbl.text = "Level 1"
            lev1.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
        case 2:
            print("level 2")
            levelLbl.text = "Level 2"
            lev1.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev2.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
        case 3:
            print("level 3")
            levelLbl.text = "Level 3"
            lev1.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev2.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev3.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
        case 4:
            print("level 4")
            levelLbl.text = "Level 4"
            lev1.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev2.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev3.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev4.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
        case 5:
            print("level 5")
            levelLbl.text = "Level 5"
            lev1.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev2.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev3.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev4.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            lev5.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)

        default:
            print("something went wrong")
        }

    }
    
    // MARK: saveNotes()
    func saveNotes(){
        if Helper.checkFirebaseLogin() == true {
            print("Save Notes RUN")
            var ref: DatabaseReference!
            ref = Database.database().reference(fromURL: "https://skateboarding-notes-stats-default-rtdb.firebaseio.com/")
            self.ref.child("users").child(Auth.auth().currentUser!.uid).child("user-tricks").child(trickName!).child("tCountLanded").setValue(countLanded)
            self.ref.child("users").child(Auth.auth().currentUser!.uid).child("user-tricks").child(trickName!).child("tCountFailed").setValue(countFailed)
            self.ref.child("users").child(Auth.auth().currentUser!.uid).child("user-tricks").child(trickName!).child("notes").setValue(notes)
        }
    }
    
    // MARK: imagePicker delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Extract the URL for video
//        if let selectedVideo:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
//
//            // Save video to the main photo album
//            let selectorToCall = #selector(TrickStatsViewController.videoSaved(_:didFinishSavingWithError:context:))
//
//            // Save the video into the photo album on device
//            UISaveVideoAtPathToSavedPhotosAlbum(selectedVideo.relativePath, self, selectorToCall, nil)
//
//            // Save the video to the app directory
//            let videoData = try? Data(contentsOf: selectedVideo)
//            let paths = NSSearchPathForDirectoriesInDomains(
//            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
//            let dataPath = documentsDirectory.appendingPathComponent(videoFileName)
//            try! videoData?.write(to: dataPath, options: [])
//
//            // Dismiss camera interface controller
//            picker.dismiss(animated: true, completion: nil)
//
//            // Create a URL with Instagram scheme
//            if let urlScheme = URL(string: "instagram-stories://share") {
//
//                // Check if Instagram is on the device
//                if UIApplication.shared.canOpenURL(urlScheme) {
//
//                    // Create paste board
//                    let items = [["com.instagram.sharedSticker.backgroundVideo": selectedVideo]]
//
//                    // Options for paste board expires in 5 minutes
//                    let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60*5)]
//
//                    // Set the items to paste board
//                    UIPasteboard.general.setItems(items, options: pasteboardOptions)
//
//                    // Share video to instagram
//                    UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
//                }
//            }
//        }
        
        // Extract the URL for picture
        let pictureToShare = info[.originalImage] as? UIImage
        
        // Compress image to share to instagram
        let imageCompressed = pictureToShare?.resized(withPercentage: 0.8)
        
        // Get image of SkateBud app icon to share along with image
        let appStickerData = UIImage(named: "AppIconSplash")
        
        // Create a URL with Instagram scheme
        if let urlScheme = URL(string: "instagram-stories://share") {
            
            // Check if Instagram is on the device
            if UIApplication.shared.canOpenURL(urlScheme) {
                
                // Create paste board
                let items = [["com.instagram.sharedSticker.backgroundImage": imageCompressed, "com.instagram.sharedSticker.stickerImage" : appStickerData]]
                
                // Options for paste board expires in 5 minutes
                let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60*5)]
                
                // Set the items to paste board
                UIPasteboard.general.setItems(items, options: pasteboardOptions)
                
                // Share video to instagram
                UIApplication.shared.open(urlScheme, options: [:], completionHandler: nil)
            }
        }
        
        // Dismiss picker view
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
