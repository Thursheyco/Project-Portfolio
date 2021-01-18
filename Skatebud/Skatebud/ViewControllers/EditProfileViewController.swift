//
//  EditProfileViewController.swift
//  Skatebud
//
//  Created by Thursheyco Arreguin on 1/12/21.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UIViewController, UITextFieldDelegate {

    // Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var invalidEmail: UILabel!
    @IBOutlet weak var invalidPassword: UILabel!
    @IBOutlet weak var invalidNewPassword: UILabel!
    
    // Declare a variable to hold the email from ProfileViewController
    var emailAddress: String?
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the email address sent in from ProfileViewController
        if let email = emailAddress {
            emailTextField.text = email
        }
        
        // Set delegates for text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        newPasswordTextField.delegate = self
        
        // Change emailTextField keyboard to type email
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        // Change the name of the return key to next
        emailTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.returnKeyType = UIReturnKeyType.next
        
        // Change the name of the return key to done
        newPasswordTextField.returnKeyType = UIReturnKeyType.done
        
        // Code to help move view above keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: TextField Delegates
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
            // Variable to help test new password
            let validPassword = isValidPasswordString(pwdStr: textField.text!)
            
            // Check if new password is valid
            if validPassword {
                
                // Alert user
                self.invalidNewPassword.isHidden = true
            } else {
                // Hide invalidNewPassword
                self.invalidNewPassword.isHidden = false
            }
        default:
            // DEBUG: print error
            print("Not suppose to happen")
        }
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
    
    // MARK: Actions
    @IBAction func saveTapped(_ sender: UIButton) {
        
        // DEBUG: print save tap
        print("save tap")
        
        // Change logged in user's email & password
        let user = Auth.auth().currentUser
        
        // Re-authentiacte user
        let credential = EmailAuthProvider.credential(withEmail: emailAddress!, password: passwordTextField.text!)
        
        user?.reauthenticate(with: credential, completion: { (result, error) in
            
            // If there is an error print it
            if let err = error {
                print(err)
            } else {
                
                // Change email address
                Auth.auth().currentUser?.updateEmail(to: self.emailTextField.text!, completion: { (error) in
                    
                    // Check if there is an error
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        // DEBUG: print email changed successfully
                        print("email changed successfully")
                    }
                })
                
                // Change password here
                Auth.auth().currentUser?.updatePassword(to: self.newPasswordTextField.text!, completion: { (error) in
                    if let errorPrint = error {
                        print(errorPrint)
                    } else {
                        // DEBUG: print password changed successfully
                        print("password changed successfully")
                    }
                })
                
                // Transition back to ProfileViewController
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        
        // DEBUG: print delete tapped
        print("delete tapped")
        
        // TODO: Alert user if they really want to delete their account
        
        // Delete user currently logged in
        let user = Auth.auth().currentUser

        user?.delete { error in
          if let error = error {
            // An error happened.
            print(error.localizedDescription)
          } else {
            // Account deleted.
            print("Account deleted")
            
            // Dismiss Profile vc
            self.dismiss(animated: true, completion: nil)
          }
        }
    }
}
