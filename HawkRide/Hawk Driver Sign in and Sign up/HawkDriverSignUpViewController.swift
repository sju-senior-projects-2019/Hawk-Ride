//
//  HawkDriverSignUpViewController.swift
//  HawkRide
//
//  Created by Gregory Jones on 2/11/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields
import FirebaseDatabase
import FirebaseAuth
import Firebase


class HawkDriverSignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    var ref: DatabaseReference! //Create a reference to the database
    

    @IBOutlet weak var FirstName: MDCTextField!
    @IBOutlet weak var LastName: MDCTextField!
    @IBOutlet weak var IDNumber: MDCTextField!
    @IBOutlet weak var EmailAddress: MDCTextField!
    @IBOutlet weak var Password: MDCTextField!
    @IBOutlet weak var PhoneNumber: MDCTextField!
    @IBOutlet weak var SubmitButton: SAButton!
   
    var FirstNameController: MDCTextInputControllerFilled?
    var LastNameController: MDCTextInputControllerFilled?
    var IDNumberController: MDCTextInputControllerFilled?
    var EmailAddressController: MDCTextInputControllerFilled?
    var PasswordController: MDCTextInputControllerFilled?
    var PhoneNumberController: MDCTextInputControllerFilled?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        FirstName.delegate = self
        LastName.delegate = self
        IDNumber.delegate = self
        EmailAddress.delegate = self
        Password.delegate = self
        PhoneNumber.delegate = self
        
        
        FirstNameController = MDCTextInputControllerFilled(textInput: FirstName)
        LastNameController = MDCTextInputControllerFilled(textInput: LastName)
        IDNumberController = MDCTextInputControllerFilled(textInput: IDNumber)
        EmailAddressController = MDCTextInputControllerFilled(textInput: EmailAddress)
        PasswordController = MDCTextInputControllerFilled(textInput: Password)
        PhoneNumberController = MDCTextInputControllerFilled(textInput: PhoneNumber)
        
        
        

        
      
}
 
    /* Submit button function
     * Using Firebase Auth to create users and store their email address, firstName, lastName, ID number and # in the database
     * TODO: if the user's information is already in the database send a warning message
     */
    @IBAction func SubmitButtonPressed(_ sender: Any) {
        guard let email = EmailAddress.text else {return}
        guard let password = Password.text else {return}
        guard let firstName = FirstName.text else {return}
        guard let lastName = LastName.text else {return}
        guard let idNumber = IDNumber.text else {return}
        guard let phoneNumber = PhoneNumber.text else {return}
        
        createUser(withEmail: email, password: password, firstName: firstName, lastName: lastName, idNumber: idNumber, phoneNumber: phoneNumber)
        
        self.performSegue(withIdentifier: "DriverSegue", sender: sender)
        
    
    }
    /* Forgot Password
     * User's are able to forget their password
     * Firebase handles this feature -
     * If user clicks forgot password, there will be a warning sign that pops saying enter your email
     * Once user enters email, then they should receive a notification in their email to rese their password
     */
    
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
    func createUser(withEmail email: String, password: String, firstName: String, lastName: String, idNumber: String, phoneNumber: String) {
        // user doesn't exist
        Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
            
            if error == nil {
                // sign up sucessful
                if let user = result?.user {
                    
                    self.updateDatabase(user)
                    
                }
                print("sign Up successful")
                self.dismiss(animated: true, completion: nil)
                
            } else {
                //sign Up failed
                if let errorCode = AuthErrorCode(rawValue: error!._code){
                    
                    switch errorCode {
                    case .invalidEmail:
                        print("invalid email address")
                    case .emailAlreadyInUse:
                        print("email already exist")
                    default:
                        print("unexpected error please try again")
                        
                    }
                }
            }
        })
    }
    func updateDatabase(_ user: User) {
        
        // user is a driver
        let userData = [kPROVIDER: user.providerID,
                        kISDRIVER : true,
                        kIS_PICKUP_MODE_ENABLED : false,
                        kDRIVER_IS_ON_TRIP: false] as [String: Any]
        
        DataService.instance.createFirebaseDBUser(uID: user.uid, userData: userData, isDriver: true)
        
    }
    
}
