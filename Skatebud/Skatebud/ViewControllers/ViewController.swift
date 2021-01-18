//
//  ViewController.swift
//  Skatebud
//
//  Created by JAROD SMITH on 1/4/21.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates for text fields
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Change emailTextField keyboard to type email
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        
        // Change the name of the return key to next
        emailTextField.returnKeyType = UIReturnKeyType.next
        
        // Change the name of the return key to done
        passwordTextField.returnKeyType = UIReturnKeyType.done
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check if user is logged in first
        let loggedIn = Helper.checkFirebaseLogin()
        if loggedIn != false {
            let uid = Auth.auth().currentUser?.uid
            if uid!.count > 0 {
                
                // Transition to TricksViewController
                self.performSegue(withIdentifier: "toMainTab", sender: nil)
            }
        }
    }

    // MARK: Actions
    @IBAction func loginTapped(_ sender: UIButton) {
        
        // DEBUG: print login tap
        print("login tap")
        
        // Guard statement to get the values from email and password text fields securely
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        // Sign in user with their email & password in Firebase
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            // Check if we have an error
            if error != nil {
                print(error!)
                return
            }
            
            // Successfully logged in our user, and transition to tricks tab
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarViewController = storyBoard.instantiateViewController(identifier: "tabBarView") as! MainTabViewController
            self.present(tabBarViewController, animated: true, completion: nil)
        }
    }
    
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
}

