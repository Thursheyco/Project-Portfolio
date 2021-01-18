//
//  SignUpViewController.swift
//  Skatebud
//
//  Created by Thursheyco Arreguin on 1/5/21.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var invalidEmail: UILabel!
    @IBOutlet weak var invalidPassword: UILabel!
    @IBOutlet weak var invalidConfirmPassword: UILabel!
    
    // Create a variable to hold a reference to Firebase Database
    var ref: DatabaseReference?
    
    // Variable to help take a photo on the device's camera
    var imagePicker: UIImagePickerController!
    
    // MARK: - Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        
        // Initialize Realtime Database
        self.ref =  Database.database().reference()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegates for text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        // Change emailTextField keyboard to type email
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        // Change the name of the return key to next
        emailTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.returnKeyType = UIReturnKeyType.next
        
        // Change the name of the return key to done
        confirmPasswordTextField.returnKeyType = UIReturnKeyType.done
        
        // Code to help move view above keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions
    @IBAction func saveTapped(_ sender: UIButton) {
        // DEBUG: print save tap
        print("Save tap.")
        
        // Guard statement to get the values from email, password, confirm password text fields securely
        guard let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text,
              !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            
            // DEBUG: print invalid form
            print("Form is not valid")
            
            // Alert user incomplete form
            let alert = UIAlertController(title: "Sign-up Form Incomplete", message: "All fields required. Please retry.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                print("Canceled")
            }))
            // Show alert
            self.present(alert, animated: true)
            
            // Return execution
            return
        }
        
        // Check if password is the same as confirm password
        if password == confirmPassword {
            
            // Authenticate a new user with their email and password
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                
                // Check if error is not equal to nil to print out error
                if error != nil {
                    print(error!)
                    return
                }
                
                // Guard statement to give me access to uid for use to save user image
                guard let uid = authResult?.user.uid else {
                    return
                }
                
                // Create a unique String for image uploads
                let imageName = NSUUID().uuidString
                
                // Get image to compress
                let imageCompressed = self.userImageView.image?.resized(withPercentage: 0.8)
                
                // Create a reference to user's storage in Firebase
                let storageRef = Storage.storage().reference().child(uid).child("\(imageName).png")
                
                // Create a binary data of image to upload to Firebase Storage
                if let uploadData = imageCompressed!.pngData() {
                    
                    // Upload user's avatar image to Firebase
                    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                        
                        // Check if there was an error
                        if error != nil {
                            print(error!)
                            return
                        }
                        
                        // Get the url for the image
                        storageRef.downloadURL { (url, err) in
                            
                            // Handle err
                            if err != nil {
                                print(err!)
                                return
                            }
                            
                            // Get the absolute string for the image's url
                            if let profileImageURL = url?.absoluteURL.description {
                                
                                // Save a couple values
                                let values = ["email":email,"profileImageURL":profileImageURL,"level":0,"tName":"none","tCountLanded":0,"tCountFailed":0] as [String : Any]
                                
                                // Invoke registerUser method
                                self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                                
                                // Transition to TricksViewController
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let tabBarViewController = storyBoard.instantiateViewController(identifier: "tabBarView") as! MainTabViewController
                                self.present(tabBarViewController, animated: true, completion: nil)
                            }
                        }
                    }
                }
                
            }
            
        } else {
            // Alert user their password is not confirmed
            let alert = UIAlertController(title: "Password Not Confirmed", message: "Password and confirmed password do NOT match. Please retry.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                print("Canceled")
            }))
            // Show alert
            self.present(alert, animated: true)
        }
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
    
    // MARK: UITextfield delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Declare a variable to hold the tag property of text field
        let nextTag = textField.tag + 1
        
        // Go to the next text field
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            textField.returnKeyType = UIReturnKeyType.next
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Check if the text field is for email
        switch textField.tag {
        case 0:
            // Variable to help test email
            let validEmail = isValidEmail(textField.text!)
            
            // Check if email address is valid
            if validEmail {
                // DEBUG: print that email was valid
                print("Valid Email!")
                
                // Hide invalid email label
                self.invalidEmail.isHidden = true
            } else {
                // DEBUG: print invalid email
                print("invalid email")
                
                // Alert user of invalid email address
                self.invalidEmail.isHidden = false
            }
        case 1:
            // Variable to help test password
            let validPassword = isValidPasswordString(pwdStr: textField.text!)
            
            // Check if password is valid
            if validPassword {
                // DEBUG: print valid password
                print("valid password")
                
                // Hide invalid password label
                self.invalidPassword.isHidden = true
            } else {
                // DEBUG: print invalid password
                print("invalid password")
                
                // Alert user that password is invalid
                self.invalidPassword.isHidden = false
            }
        case 2:
            // Check confirm password matches password
            if passwordTextField.text != textField.text {
                
                // Alert user
                self.invalidConfirmPassword.isHidden = false
            } else {
                // Hide invalidConfirmPassword
                self.invalidConfirmPassword.isHidden = true
            }
        default:
            // DEBUG: print error
            print("Not suppose to happen")
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Register User
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String:AnyObject]) {

        // Successfully authenticated user, save the user, and save data to Firebase Database
        self.ref = Database.database().reference(fromURL: "https://skateboarding-notes-stats-default-rtdb.firebaseio.com/")
        
        // Create a child reference
        let userReference = self.ref!.child("users").child((uid))
        
        // Update using userReference
        userReference.updateChildValues(values) { (err, ref) in
            
            // Check if error is not equal to nil to print out err
            if err != nil {
                print(err!)
            }
            
            // DEBUG: print success
            print("Saved User in Firebase db!")
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
    
    // Method to check for valid email address
    func isValidEmail(_ email: String) -> Bool {
        
        // Create the regex formula
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        // Variable to hold value of test
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        // Return evaluation value
        return emailPred.evaluate(with: email)
    }
    
    // Method to check for valid password must be 6 characters long, max 15 characters, & one capital letter
    func isValidPasswordString(pwdStr:String) -> Bool {

        let pwdRegEx = "(?:(?:(?=.*?[0-9])(?=.*?[-!@#$%&*ˆ+=_])|(?:(?=.*?[0-9])|(?=.*?[A-Z])|(?=.*?[-!@#$%&*ˆ+=_])))|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[-!@#$%&*ˆ+=_]))[A-Za-z0-9-!@#$%&*ˆ+=_]{6,15}"

        let pwdTest = NSPredicate(format:"SELF MATCHES %@", pwdRegEx)
        return pwdTest.evaluate(with: pwdStr)
    }
    
    // MARK: - UIImagePickerController delegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Dismiss UIImagePickerController
        imagePicker.dismiss(animated: true, completion: nil)
        
        // Present the taken photo
        userImageView.image = info[.originalImage] as? UIImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIImage extension
extension UIImage {
    
    // Method to help reduce the size of the image before uploading it to Firebase using a percentage
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        
        // UIGraphicsImageRenderer is used to compress the image
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    // Method to help reduce the size of the image before uploading it to Firebase using a width
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
