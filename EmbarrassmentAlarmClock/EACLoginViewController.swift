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
	var statusBarImageView: UIImageView = UIImageView(frame: UIApplication.shared.statusBarFrame)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let loginButton = FBSDKLoginButton()
		
		loginButton.delegate = self
		loginButton.publishPermissions = [
			FB_PUBLISH_ACTIONS
		]
		self.viewFBButton.addSubview(loginButton)
		loginButton.translatesAutoresizingMaskIntoConstraints = false
		loginButton.leftAnchor.constraint(equalTo: viewFBButton.leftAnchor).isActive = true
		loginButton.rightAnchor.constraint(equalTo: viewFBButton.rightAnchor).isActive = true
		loginButton.topAnchor.constraint(equalTo: viewFBButton.topAnchor).isActive = true
		loginButton.bottomAnchor.constraint(equalTo: viewFBButton.bottomAnchor).isActive = true
		
		view.addSubview(statusBarImageView)
		statusBarImageView.isHidden = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let accessToken = FBSDKAccessToken.current()
		eacChildViewControllerDelegate.hideButtonBar(accessToken == nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		//if FBSDKAccessToken.currentAccessToken() != nil {
		//			//presentingViewController!.transitioningDelegate = EACCircleAnimatorManager.sharedInstance
		//			dismissViewControllerAnimated(true, completion: nil)
		//			eacChildViewControllerDelegate.transitionToNextVC(self)
		//}
		
	}
	
	func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
		
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
	
	func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
		eacChildViewControllerDelegate.hideButtonBar(FBSDKAccessToken.current() == nil)
	}
	
	//	override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
	//		parentViewController?.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
	//	}
	//	
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
}
