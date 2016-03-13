//
//  LoginViewController.swift
//  CommunitySpirit
//
//  Created by Robert McBryde on 13/03/2016.
//  Copyright © 2016 Robert McBryde. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgoundParralaxEffect()
    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().valueForKey(firebase_uidKey) != nil {
            self.navigateToLoggedInScene()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func fbButtonPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler: {
            facebookResult, facebookError in
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("facebook login success \(accessToken)")
                
                DataService.ds.refBase.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    // store the Firebase user session
                    if error != nil {
                        print("Firebase login failed")
                    } else {
                        print("Logged into Firebase via Facebook")
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: firebase_uidKey)
                        self.navigateToLoggedInScene()
                    }
                })
            }
            
        })
    }
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailField.text where !email.isEmpty, let pwd = passwordField.text where !pwd.isEmpty {
            
            DataService.ds.refBase.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                if error != nil {
                    if error.code == firebase_account_does_not_exist {
                        DataService.ds.refBase.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Sorry an error occured meaning an account cannot be created at this time")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[firebase_uidKey], forKey: firebase_uidKey)
                                DataService.ds.refBase.authUser(email, password: pwd, withCompletionBlock: nil)
                                self.navigateToLoggedInScene()
                            }
                        })
                    } else {
                        self.showErrorAlert("Could not login", msg: "Please check your username and password")
                    }
                } else {
                    self.navigateToLoggedInScene()
                }
            })
            
        } else {
            showErrorAlert("Email & Password required", msg: "Please ensure you fill in both email and password")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let navVc = segue.destinationViewController as! UINavigationController
        let chatDetailsVc = navVc.viewControllers.first as! ChatDetailViewController
        chatDetailsVc.senderId = DataService.init().refBase.authData.uid
        chatDetailsVc.senderDisplayName = ""
    }
    
    // MARK: Private
    
    func navigateToLoggedInScene() {
        self.performSegueWithIdentifier(segue_loggedIn, sender: nil)
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(alertAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func setupBackgoundParralaxEffect() {
        // Set vertical effect
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
            type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -15
        verticalMotionEffect.maximumRelativeValue = 15
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
            type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -15
        horizontalMotionEffect.maximumRelativeValue = 15
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        backgroundImage.addMotionEffect(group)
    }
    
}

