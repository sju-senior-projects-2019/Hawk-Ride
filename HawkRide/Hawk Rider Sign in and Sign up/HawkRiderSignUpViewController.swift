//
//  HawkRiderSignUpViewController.swift
//  Hawk Ride
//
//  Created by Gregory Jones on 2/18/19.
//  Copyright © 2019 Gregory Jones. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields
import FirebaseAuth
import FirebaseDatabase
import Firebase




class HawkRiderSignUpViewController: UIViewController, UITextFieldDelegate {
    
   
    var ref: DatabaseReference! //Create a reference to the database
  
    /* Sign up form variables */
    
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

    FirstNameController = MDCTextInputControllerFilled(textInput: FirstName)
    LastNameController = MDCTextInputControllerFilled(textInput: LastName)
    IDNumberController = MDCTextInputControllerFilled(textInput: IDNumber)
    EmailAddressController = MDCTextInputControllerFilled(textInput: EmailAddress)
    PasswordController = MDCTextInputControllerFilled(textInput: Password)
    PhoneNumberController = MDCTextInputControllerFilled(textInput:PhoneNumber)
   
}
    
    
 /* Submit button function
  * Using Firebase Auth to create users and store their email address, firstName, lastName, ID number and # in the database
  * TODO: if the user's information is already in the database send a warning message
  */
  @IBAction func SubmitButton(_ sender: Any) {
        if let email = EmailAddress.text, let password = Password.text {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error == nil {
                    let user = Auth.auth().currentUser?.uid // get the users UID
                      let emailAddress = self.EmailAddress.text
                      let FirstName = self.FirstName.text
                      let LastName = self.LastName.text
                      let IDNumber = self.IDNumber.text
                      let PhoneNumber = self.PhoneNumber.text
                     
                    self.ref.child("Hawk Riders").child("\(user!)").setValue(["FirstName": "\(FirstName!)", "LastName": "\(LastName!)", "emailAddress": "\(emailAddress!)", "IDNumber": "\(IDNumber!)","PhoneNumber": "\(PhoneNumber!)"])
                        
                       
                     self.performSegue(withIdentifier: "RideSegue", sender: sender)
              }
           }
        }
     }
  }


    

   
    




