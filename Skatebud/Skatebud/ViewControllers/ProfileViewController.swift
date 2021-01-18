//
//  ProfileViewController.swift
//  Skatebud
//
//  Created by Thursheyco Arreguin on 1/11/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Properties
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var trickName: UILabel!
    
    // Create a variable to hold a reference to Firebase Database
    var ref: DatabaseReference!
    
    // Variable to help take a photo on the device's camera
    var imagePicker: UIImagePickerController!
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: check if user is signed up here
        
        // Load profile pic from logged in user
        ref = Database.database().reference(fromURL: "https://skateboarding-notes-stats-default-rtdb.firebaseio.com/")
        
        // Get current user object from Firebase
        let user = Auth.auth().currentUser
        
        // Get current user's ID
        let uid = Auth.auth().currentUser!.uid
        
        // Create a child reference
        Database.database().reference().child("users").child(uid).observe(.value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let profilePicURL = value!["profileImageURL"] as? String ?? ""
            let url = URL(string: profilePicURL)
            let mostSuccessfulTrick = value!["tName"] as? String ?? ""
            // Set userEmail label
            self.userEmail.text = user?.email
            // Set trickName label
            self.trickName.text = mostSuccessfulTrick
            // Download image
            let data = try? Data(contentsOf: url!)
            
            // Set saved profile pic
            self.userImage.image = UIImage(data: data!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Get current user object from Firebase
        let user = Auth.auth().currentUser
        
        // Set updated email
        userEmail.text = user?.email
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Check if user is logged in
        if Auth.auth().currentUser?.uid != nil {
            // Create a unique String for image uploads
            let imageName = NSUUID().uuidString
            
            // Compress image to save to signed in user's Firebase account
            let imageCompressed = self.userImage.image?.resized(withPercentage: 0.8)
            
            // Create a reference to user's storage in Firebase
            let storageRef = Storage.storage().reference().child(Auth.auth().currentUser!.uid).child("\(imageName).png")
            // Create a binary data of image to upload to Firebase Storage
            if let uploadData = imageCompressed!.pngData() {
                // Upload user's avatar image to Firebase
                storageRef.putData(uploadData, metadata: nil) { (meta, error) in
                    // Print error
                    if error != nil {
                        print(error!)
                        return
                    }
                    // Upload user's avatar image to Firebase
                    storageRef.downloadURL { (url, error) in
                        // Handle err
                        if error != nil {
                            print(error!)
                            return
                        }
                        // Get the absolute string for the image's url
                        if let profileImageURL = url?.absoluteURL.description {
                            // Create a reference to users
                            self.ref = Database.database().reference(fromURL: "https://skateboarding-notes-stats-default-rtdb.firebaseio.com/")
                            // Create a child reference
                            let userReference = self.ref.child("users").child((Auth.auth().currentUser!.uid))
                            // Update user's profile pic
                            userReference.updateChildValues(["profileImageURL":profileImageURL])
                        }
                    }
                }
            }
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destination: EditProfileViewController = segue.destination as! EditProfileViewController
        // Pass the selected object to the new view controller.
        destination.emailAddress = userEmail.text
    }
    
    // MARK: Actions
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        
        
    }
    @IBAction func logoutTapped(_ sender: UIButton) {
        
        // Logout user
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        // Dismiss Profile vc
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePhotoTapped(_ sender: UIButton) {
        // DEBUG: print take photo tap
        print("take photo tap")
        
        // Check if camera is available on the device
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            // Invoke method to show a menu to chose a photo for user image
            showPhotoMenu()
        } else {
            // No camera means they have to chose from photo library on device
            choosePhotoFromLibrary()
        }
    }
    
    // MARK: choosePhotoFromLibrary
    private func choosePhotoFromLibrary() {
        
        // DEBUG: print choose photo tap
        print("choose photo tap")
        
        // Initialize with a source type of Photo Library & it will be presented
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: showPhotoMenu()
    func showPhotoMenu() {
        
        // Create action sheet to let user to chose how they would like to enter a photo
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Cancel button action
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        
        // Action to take photo with device's camera
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.takePhotoWithCamera()})
        alert.addAction(actPhoto)
        
        // Choose from device's photo library
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in self.choosePhotoFromLibrary()})
        alert.addAction(actLibrary)
        
        // Present action sheet
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: takePhotoWithCamera()
    private func takePhotoWithCamera() {
        
        // Initialize with a source type of Camera & it will be presented
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera

        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerController delegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Dismiss UIImagePickerController
        imagePicker.dismiss(animated: true, completion: nil)
        
        // Present the taken photo
        userImage.image = info[.originalImage] as? UIImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
