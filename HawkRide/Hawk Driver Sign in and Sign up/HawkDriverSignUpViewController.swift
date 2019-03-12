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
        

        /** Customizing the navigation controller bar */
        self.navigationItem.backBarButtonItem?.title = ""  // Changing the title of the navigation item
        self.navigationItem.backBarButtonItem = UIBarButtonItem()  // Enabling the back button
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //Allowing the background image to display over the navigation bar
        self.navigationController?.navigationBar.shadowImage = UIImage() // Shadowing the navigation bar under the image
        self.navigationController?.navigationBar.isTranslucent = true  // Navigation bar becomes transparent
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white // Changing the color of the navigation item
        
        
        FirstNameController = MDCTextInputControllerFilled(textInput: FirstName)
        LastNameController = MDCTextInputControllerFilled(textInput: LastName)
        IDNumberController = MDCTextInputControllerFilled(textInput: IDNumber)
        EmailAddressController = MDCTextInputControllerFilled(textInput: EmailAddress)
        PasswordController = MDCTextInputControllerFilled(textInput: Password)
        PhoneNumberController = MDCTextInputControllerFilled(textInput: PhoneNumber)
    
        
        
    }
 
    
    @IBAction func SubmitButtonPressed(_ sender: Any) {
        if let email = EmailAddress.text {
            if let password = Password.text {
                
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error == nil {
                        
                        let user = Auth.auth().currentUser?.uid // get the users UID
                        let emailAddress = self.EmailAddress.text
                        let FirstName = self.FirstName.text
                        let LastName = self.LastName.text
                        let IDNumber = self.IDNumber.text
                        let PhoneNumber = self.PhoneNumber.text
                        
                        self.ref.child("Hawk Drivers").child("\(user!)").setValue(["FirstName": "\(FirstName!)", "LastName": "\(LastName!)", "emailAddress": "\(emailAddress!)", "IDNumber": "\(IDNumber!)","PhoneNumber": "\(PhoneNumber!)"])
                        
                        self.performSegue(withIdentifier: "goToDriverMap", sender: sender)
                    } else {
                    }
                }
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
