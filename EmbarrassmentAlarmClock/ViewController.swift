//
//  ViewController.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/12/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

func typeAsString<T>(type: T.Type) -> String {
	return "\(type)".componentsSeparatedByString(".").last!
}

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) { [unowned self] (notification: NSNotification) -> Void in
			let accessToken = FBSDKAccessToken.currentAccessToken()
			if accessToken == nil {
				var topVC: UIViewController = self
				while topVC.presentedViewController != nil {
					topVC = topVC.presentedViewController!
				}
				
				guard let _storyboard = topVC.storyboard else {
					return
				}

				let destinationViewController = _storyboard.instantiateViewControllerWithIdentifier(typeAsString(EACLoginViewController))
				destinationViewController.transitioningDelegate = EACCircleAnimatorManager.sharedInstance
				topVC.presentViewController(destinationViewController, animated: true, completion: nil)
			}
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		let accessToken = FBSDKAccessToken.currentAccessToken()
		if accessToken != nil {
			print("Already Logged in")
//			if accessToken.hasGranted(FB_PUBLISH_ACTIONS) {
//				let req = FBSDKGraphRequest(graphPath: FB_GRAPHPATH_FEED, parameters: [
//					FB_GRAPHPATH_FEED_MESSAGE_KEY : "Hi"
//					], HTTPMethod: POST)
//				req.startWithCompletionHandler({ (gReq: FBSDKGraphRequestConnection!, data: AnyObject!, err: NSError!) -> Void in
//					if err == nil {
//						print("Post id", data)
//					}
//				})
//			}
			let destinationViewController = storyboard!.instantiateViewControllerWithIdentifier(typeAsString(EACStartAlarmViewController))
			destinationViewController.transitioningDelegate = EACCircleAnimatorManager.sharedInstance
			presentViewController(destinationViewController, animated: true, completion: nil)
		} else {
			print("Not logged in")
			
			let destinationViewController = storyboard!.instantiateViewControllerWithIdentifier(typeAsString(EACLoginViewController))
			destinationViewController.transitioningDelegate = EACCircleAnimatorManager.sharedInstance
			presentViewController(destinationViewController, animated: true, completion: nil)
		}
	}
	
}

class EACLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
	
	@IBOutlet weak var viewFBButton: UIView!
	
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
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if FBSDKAccessToken.currentAccessToken() != nil {
			//presentingViewController!.transitioningDelegate = EACCircleAnimatorManager.sharedInstance
			dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
		
		if let result = result, permissions = result.grantedPermissions
		where permissions.contains(FB_PUBLISH_ACTIONS)
		{
			print("granted permissions ", permissions)
		} else {
			let alert = UIAlertView(title: "Login Error", message: "Please try logging in again.  If that doesn't work, go to safari and log out of facebook", delegate: nil, cancelButtonTitle: "Ok")
			alert.show()
		}
	}
	
	func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
		
	}

}

class EACStartAlarmViewController: UIViewController {
	
}

class EACSetAlarmViewController: UIViewController {
	
}

class EACActiveAlarmViewController: UIViewController {
	
}

class EACCircleAnimatorManager: NSObject, UIViewControllerTransitioningDelegate {
	
	static let sharedInstance = EACCircleAnimatorManager()
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animator = EACCircleAnimator(isPresenting: true)
		
		if let _ = presenting as? ViewController, let _ = presented as? EACLoginViewController {
			animator.centerPoint = presenting.view.center
		} else if let _ = presenting as? ViewController, let _ = presented as? EACStartAlarmViewController {
			animator.centerPoint = presenting.view.center
		} else {
			return nil
		}
		return animator
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animator = EACCircleAnimator(isPresenting: false)

		if let _dismissed = dismissed as? EACLoginViewController {
			animator.centerPoint = _dismissed.viewFBButton.center
		} else {
			return nil
		}
		return animator
	}
	
}

class EACCircleAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	var transitionContext: UIViewControllerContextTransitioning!
	var centerPoint = CGPoint.zero
	var centerRadius = CGFloat(0)
	var isPresenting: Bool
	
	init(isPresenting: Bool) {
		self.isPresenting = isPresenting
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 2
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		
		let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		transitionContext.containerView()!.addSubview(toVC.view)
		
		let startMask: UIBezierPath
		let endMask: UIBezierPath
		
		if isPresenting {
			var startRect = CGRect(origin: centerPoint, size: CGSize.zero)
			startRect.size = CGSize(width: centerRadius * 2, height: centerRadius * 2)
			startRect.offsetInPlace(dx: -centerRadius, dy: -centerRadius)
			startMask = UIBezierPath(ovalInRect: startRect)
			
			var endRect = CGRect(origin: centerPoint, size: CGSize.zero)
			let endRadius = max(
				max(
					centerPoint.distance(CGPoint(x: toVC.view.frame.minX, y: toVC.view.frame.minY)),
					centerPoint.distance(CGPoint(x: toVC.view.frame.minX, y: toVC.view.frame.maxY))
				),
				max(
					centerPoint.distance(CGPoint(x: toVC.view.frame.maxX, y: toVC.view.frame.minY)),
					centerPoint.distance(CGPoint(x: toVC.view.frame.maxX, y: toVC.view.frame.maxY))
				)
			)
			endRect.size = CGSize(width: endRadius * 2, height: endRadius * 2)
			endRect.offsetInPlace(dx: -endRadius, dy: -endRadius)
			endMask = UIBezierPath(ovalInRect: endRect)
		} else {
			var startRect = CGRect(origin: centerPoint, size: CGSize.zero)
			let startRadius = max(
				max(
					centerPoint.distance(CGPoint(x: fromVC.view.frame.minX, y: fromVC.view.frame.minY)),
					centerPoint.distance(CGPoint(x: fromVC.view.frame.minX, y: fromVC.view.frame.maxY))
				),
				max(
					centerPoint.distance(CGPoint(x: fromVC.view.frame.maxX, y: fromVC.view.frame.minY)),
					centerPoint.distance(CGPoint(x: fromVC.view.frame.maxX, y: fromVC.view.frame.maxY))
				)
			)
			startRect.size = CGSize(width: startRadius * 2, height: startRadius * 2)
			startRect.offsetInPlace(dx: -startRadius, dy: -startRadius)
			startMask = UIBezierPath(ovalInRect: startRect)
			
			var endRect = CGRect(origin: centerPoint, size: CGSize.zero)
			endRect.size = CGSize(width: centerRadius * 2, height: centerRadius * 2)
			endRect.offsetInPlace(dx: -centerRadius, dy: -centerRadius)
			endMask = UIBezierPath(ovalInRect: endRect)
		}
		
		let maskLayer = CAShapeLayer()
		maskLayer.path = startMask.CGPath
		if isPresenting {
			toVC.view.layer.mask = maskLayer
		} else {
			fromVC.view.layer.mask = maskLayer
		}
		
		let maskLayerAnimation = CABasicAnimation(keyPath: "path")
		maskLayerAnimation.fromValue = startMask.CGPath
		maskLayerAnimation.toValue = endMask.CGPath
		maskLayerAnimation.duration = transitionDuration(transitionContext)
		maskLayerAnimation.delegate = self
		maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
	}
	
	override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
		transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
		if isPresenting {
			transitionContext
				.viewControllerForKey(UITransitionContextToViewControllerKey)?
				.view.layer.mask = nil
		} else {
			transitionContext
				.viewControllerForKey(UITransitionContextFromViewControllerKey)?
				.view.layer.mask = nil
		}
	}
	
}

enum ImageAsset: String {
	case Facebook_F_icon = "Facebook-F-icon"
	
	func image(bundle: NSBundle = NSBundle.mainBundle()) -> UIImage {
		return UIImage(named: self.rawValue, inBundle: bundle, compatibleWithTraitCollection: nil)!
	}
}

extension CGPoint {
	func distance(p: CGPoint) -> CGFloat {
		return sqrt(pow(self.x - p.x, 2) + pow(self.y - p.y, 2))
	}
}
