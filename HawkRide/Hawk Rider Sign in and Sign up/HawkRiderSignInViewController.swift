//
//  HawkRiderSignInViewController.swift
//  HawkRide
//
//  Created by Gregory Jones on 2/15/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import MaterialComponents
import Firebase
import FirebaseAuth



class HawkRiderSignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ValidationMessage: UILabel!
    @IBOutlet weak var EmailAddress: MDCTextField!
    @IBOutlet weak var Password: MDCTextField!
    @IBOutlet weak var SubmitButton: MDCButton!
    let buttonScheme = MDCButtonScheme()
    
    var emailController: MDCTextInputControllerOutlined?
    var passwordController: MDCTextInputControllerOutlined?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    /*    Auth.auth().addStateDidChangeListener { (Auth, user) in
            if user != nil {
                //User is signed in. Show home screen
                self.performSegue(withIdentifier: "goToRiderMap", sender: nil)
                print("Signed In")
            } else {
                //No user is signed in. Show user the login screen
                print("Not Signed In")
            }
        } */
        
        EmailAddress.delegate = self
        Password.delegate = self
        ValidationMessage.isHidden = true
 
        emailController = MDCTextInputControllerOutlined(textInput:EmailAddress)
        passwordController = MDCTextInputControllerOutlined(textInput: Password)
        MDCContainedButtonThemer.applyScheme(buttonScheme, to: SubmitButton)
 }
    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        SubmitButton.hitAreaInsets = UIEdgeInsets(top: (48 - self.SubmitButton.bounds.size.height) / -2,
                                                  left: 0,
                                                  bottom: (48 - self.SubmitButton.bounds.size.height) / -2,
                                                  right: 0)
    }
    
      @IBAction func SubmitButton(_ sender: Any) {
        if EmailAddress.text == "" || Password.text == "" {
           } else {
            if let email = EmailAddress.text {
                if let password = Password.text {
                      // Login
                        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            print(error!._code)
                            self.handleError(error!)
                            return
                        }
                        self.performSegue(withIdentifier: "goToRiderMap", sender: sender) // After user logins with the correct credentials, then it would send the user to the Rider Map View
                    }
                    
                }
                
            }
            
        }
        
    }



    @IBAction func ForgotPassword(_ sender: Any) {
        let forgotPasswordAlert = UIAlertController(title: "Forgot Password?", message: "Enter Email Address", preferredStyle: .alert)
         forgotPasswordAlert.addTextField {(textField) in
            textField.placeholder = "Enter Email Address"
        }
       
        forgotPasswordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        forgotPasswordAlert.addAction(UIAlertAction(title: "Reset Password", style: .default, handler: {(action) in
            let resetEmail = forgotPasswordAlert.textFields?.first?.text
            Auth.auth().sendPasswordReset(withEmail: resetEmail!, completion: { (error) in
                if error != nil {
                    let resetFailedAlert = UIAlertController(title:"Reset Failed", message: "Error: \(String(describing: error?.localizedDescription))", preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                }else {
                    let resetEmailSentAlert = UIAlertController(title: "Reset email sent successfully", message: "Check your email", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                    
                }
                
            })
    }))
    // Present Alert:
    self.present(forgotPasswordAlert, animated: true, completion: nil)
  }
   
}

