//
//  EACLoginViewController.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

class EACLoginViewController: UIViewController, FBSDKLoginButtonDelegate, EACChildViewControllerProtocol {
	
	@IBOutlet weak var viewFBButton: UIView!
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate!
	
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let loginButton = FBSDKLoginButton()
		
		loginButton.delegate = self
		loginButton.publishPermissions = [
			FB_PUBLISH_ACTIONS
		]
		self.viewFBButton.addSubview(loginButton)
		loginButton.translatesAutoresizingMaskIntoConstraints = false
		loginButton.leftAnchor.constraintEqualToAnchor(viewFBButton.leftAnchor).active = true
		loginButton.rightAnchor.constraintEqualToAnchor(viewFBButton.rightAnchor).active = true
		loginButton.topAnchor.constraintEqualToAnchor(viewFBButton.topAnchor).active = true
		loginButton.bottomAnchor.constraintEqualToAnchor(viewFBButton.bottomAnchor).active = true
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(FBSDKAccessToken.currentAccessToken() == nil)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		//if FBSDKAccessToken.currentAccessToken() != nil {
		//			//presentingViewController!.transitioningDelegate = EACCircleAnimatorManager.sharedInstance
		//			dismissViewControllerAnimated(true, completion: nil)
		//			eacChildViewControllerDelegate.transitionToNextVC(self)
		//}
		
	}
	
	func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
		
		if let result = result {
			if result.isCancelled {
				
			} else if let permissions = result.grantedPermissions
			//	where permissions.contains(FB_PUBLISH_ACTIONS)
			{
				print("granted permissions ", permissions)
				eacChildViewControllerDelegate.transitionToNextVC(self)
			} else {
				let alert = UIAlertView(title: "Login Error", message: "Please try logging in again.  If that doesn't work, go to safari and log out of facebook", delegate: nil, cancelButtonTitle: "Ok")
				alert.show()
			}
		}
	}
	
	func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
		eacChildViewControllerDelegate.hideButtonBar(FBSDKAccessToken.currentAccessToken() == nil)
	}
	
	//	override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
	//		parentViewController?.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
	//	}
	//	
}