//
//  ViewController.swift
//  My App
//
//  Created by Ugo Besa on 13/02/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField:UITextField!
    @IBOutlet weak var passwordField:UITextField!
    
    private var _fbLoginManager: FBSDKLoginManager?
    
    var fbLoginManager: FBSDKLoginManager {
        get {
            if _fbLoginManager == nil {
                _fbLoginManager = FBSDKLoginManager()
            }
            return _fbLoginManager!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    

    
    //MARK: IBaction
    @IBAction func fbButtonPressed(sender:UIButton!){
        fbLoginManager.logInWithReadPermissions(["email"], fromViewController: self) { (fbResult:FBSDKLoginManagerLoginResult!, fbError:NSError!) -> Void in
            
            if fbError != nil {
                print("FB LOGGIN ERROR  \(fbError)")
            }
            else{
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Sucess log in FB \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        print("Login Failed \(error)")
                    }
                    else{
                        print("Logged In! \(authData)")
                        
                        let user:Dictionary<String,String!>!
                        if let provider = authData.provider {
                            user = ["provider": provider]
                        }
                        else{
                            user = ["provider": "facebook"]
                        }
                        
                        DataService.ds.createFireBaseUser(authData.uid, user: user)
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid , forKey: KEY_UID)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        }
    }
    
    
    @IBAction func attempLogin(sender:UIButton!) {
        
        if let email =  emailField.text where email != "", let password = passwordField.text where password != "" {
            
            // Try to login
            DataService.ds.REF_BASE.authUser(email, password: password, withCompletionBlock: { error, authData in
                if error != nil {
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        
                        //Create an account
                        DataService.ds.REF_BASE.createUser(email, password: password, withValueCompletionBlock: { error, result in
                            if error != nil { // Could handle different types of error like email already used, no internet connection...
                                self.showErrorAlert("Could not create an account", message: "Problem creating an account try something else")
                            }
                            else
                            {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                NSUserDefaults.standardUserDefaults().synchronize() // Not sure if it's necessary
                                
                                // Now Login
                                DataService.ds.REF_BASE.authUser(email, password: password, withCompletionBlock: { error, authData in
                                    if error == nil {
                                        
                                        let user:Dictionary<String,String!>!
                                        if let provider = authData.provider {
                                            user = ["provider": provider]
                                        }
                                        else{
                                            user = ["provider": "password"]
                                        }
                                        
                                        DataService.ds.createFireBaseUser(authData.uid, user: user)
                                        
                                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                    }
                                })
                            }
                        })
                    }
                    else{ // if there is another kind of error
                        self.showErrorAlert("Could not loggin", message: "Please check your username or password")
                    }
                }
                else{
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    NSUserDefaults.standardUserDefaults().synchronize() // Not sure if it's necessary
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
        }
        else{
            showErrorAlert("Email and Password required", message: "You must enter an email and a password")
        }
        
    }
    
    
    //MARK: Helper func
    func showErrorAlert(tile:String!, message:String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true) // STOP all kinf of editing (keyboard) when we touch somewhere
    }
    
    //MARK: textfield func
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true
    }
   


}

