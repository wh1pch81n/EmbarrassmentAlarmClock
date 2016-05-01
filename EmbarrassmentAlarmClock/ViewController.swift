//
//  ViewController.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/12/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EACChildViewControllerDelegate {

	let facebookLoginVC = viewControllerFromType(EACLoginViewController)
	let startAlarmVC = viewControllerFromType(EACStartAlarmViewController)
	let setAlarmVC = viewControllerFromType(EACSetAlarmViewController)
	let activeAlarmVC = viewControllerFromType(EACActiveAlarmViewController)
	let postFacebookVC = viewControllerFromType(EACPostFacebookViewController)

	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var containerViewButtons: UIView!
	@IBOutlet weak var facebookButton: UIImageView!
	
	/**Returns a UIViewController if there is some presets that user needs to do before the app will work properly*/
	var presetViewController: UIViewController? {
		let accessToken = FBSDKAccessToken.currentAccessToken()
		if accessToken == nil {
			// Needs Facebook login
			return facebookLoginVC
		}
		// volume is too low
		
		// Silent Mode is on
		
		// Notifications disabled
		
		return nil
	}
	
	var currentChildViewController: UIViewController!
	var previousChildViewController: UIViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		let vcs = Array<EACChildViewControllerProtocol>(arrayLiteral:
			facebookLoginVC,
			startAlarmVC,
			setAlarmVC,
			activeAlarmVC,
			postFacebookVC
		)
		
		vcs.forEach({ $0.eacChildViewControllerDelegate = self })
		
		currentChildViewController = presetViewController ?? startAlarmVC
		currentChildViewController.willMoveToParentViewController(self)
		self.addChildViewController(currentChildViewController)
		contentView.addSubview(currentChildViewController.view)
		constrainSubview(currentChildViewController.view, toSuperView: contentView)
		currentChildViewController.didMoveToParentViewController(self)
		
		self.setNeedsStatusBarAppearanceUpdate()
//		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil) { [unowned self] (notification: NSNotification) -> Void in
//
//			if let setUpVCRequired = self.presetViewController where self.currentChildViewController != setUpVCRequired {
//				let context = EACContextTransitioning(fromVC: self.currentChildViewController, toVC: setUpVCRequired, contentView: self.contentView)
//				self.currentChildViewController = setUpVCRequired
//				let animator = EACCircleAnimator(isPresenting: true)
//				context.animatorDelegate = animator
//				animator.animateTransition(context)
//			} else {
//				
//			}
//		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		_ = lightContentStatusBarImage
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
//		let d =  NSUserDefaults.standardUserDefaults()
//			.objectForKey("performFetchWithCompletionHandler") as? NSDate
//		let df = NSDateFormatter()
//		df.dateStyle = .MediumStyle
//		df.timeStyle = .MediumStyle
//		let alert = UIAlertView(
//			title: d != nil ? df.stringFromDate(d!) : ("not set"),
//			message: nil,
//			delegate: nil,
//			cancelButtonTitle: "ok"
//		)
//		alert.show()
	}
	
	func transitionFromViewController(fromViewController: UIViewController, toViewController: UIViewController, animation: ((UIViewControllerAnimatedTransitioning) -> ())? = nil) {
		toViewController.willMoveToParentViewController(self)
		let context = EACContextTransitioning(fromVC: self.currentChildViewController, toVC: toViewController, contentView: self.contentView)
		let toVCEAC = toViewController as? EACChildViewControllerProtocol
		let fromVCEAC = fromViewController as? EACChildViewControllerProtocol
		fromVCEAC?.statusBarImageView.hidden = false
		toVCEAC?.statusBarImageView.hidden = false
		fromVCEAC?.statusBarImageView.image = (fromViewController.preferredStatusBarStyle() == .LightContent) ? lightContentStatusBarImage : darkContentStatusBarImage
		toVCEAC?.statusBarImageView.image = (toViewController.preferredStatusBarStyle() == .LightContent) ? lightContentStatusBarImage : darkContentStatusBarImage
		
		self.previousChildViewController = self.currentChildViewController
		self.currentChildViewController = toViewController
		self.addChildViewController(toViewController)
		let animator = EACCircleAnimator(isPresenting: !true)
		context.animatorDelegate = animator
		UIApplication.sharedApplication().statusBarHidden = true
		self.setNeedsStatusBarAppearanceUpdate()
		animation?(animator)
		self.view.userInteractionEnabled = false
		animator.animateTransition(context)
		toViewController.didMoveToParentViewController(self)
		animator.didFinishAnimation = {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue(), {
				UIApplication.sharedApplication().statusBarHidden = false
				self.setNeedsStatusBarAppearanceUpdate()
				fromVCEAC?.statusBarImageView.hidden = true
				toVCEAC?.statusBarImageView.hidden = true
				self.view.userInteractionEnabled = true
			})
		}
	}
	
	// MARK: Buttons
	@IBAction func tappedFacebookButton(sender: UITapGestureRecognizer) {
		//facebookLoginVC.transitioningDelegate = EACCircleAnimatorManager.sharedInstance
		//presentViewController(facebookLoginVC, animated: true, completion: nil)
		let nextVC: UIViewController
		var animator: (animator: UIViewControllerAnimatedTransitioning) -> ()
		if self.currentChildViewController == facebookLoginVC {
			// dismiss
			nextVC = self.previousChildViewController!
			animator = { (animator: UIViewControllerAnimatedTransitioning) -> () in
				if let _animator = animator as? EACCircleAnimator {
					_animator.centerPoint = self.facebookButton.center
					_animator.isPresenting = false
				}
			}
		} else {
			nextVC = facebookLoginVC
			animator = { (animator: UIViewControllerAnimatedTransitioning) -> () in
				if let _animator = animator as? EACCircleAnimator {
					_animator.centerPoint = self.facebookButton.center
					_animator.isPresenting = true
				}
			}
		}
		transitionFromViewController(currentChildViewController, toViewController: nextVC, animation: animator)
	}
	
	// MARK: EACChildViewControllerDelegate 
	func transitionToNextVC(sender: UIViewController) {
		let nextVC: UIViewController!
		var animator: ((animator: UIViewControllerAnimatedTransitioning) -> ())? = nil
		
		let animatorEACCircle = { (centerPoint: CGPoint, outwardAnimation: Bool) -> (animator: UIViewControllerAnimatedTransitioning) -> () in
			return { (animator: UIViewControllerAnimatedTransitioning) -> () in
				if let _animator = animator as? EACCircleAnimator {
					_animator.centerPoint = centerPoint
					_animator.isPresenting = true
				}
			}
		}
		
		switch sender {
		case facebookLoginVC:
			animator = animatorEACCircle(facebookButton.center, true)
			if let setUpVC = presetViewController {
				nextVC = setUpVC
			} else if let prevVC = self.previousChildViewController {
				nextVC = prevVC
			} else {
				nextVC = startAlarmVC
				startAlarmVC.view.hidden = false
				animator = animatorEACCircle(startAlarmVC.startButton.center, false)
			}
		case startAlarmVC:
			nextVC = setAlarmVC
			animator = animatorEACCircle(startAlarmVC.startButton.center, true)
			
		case setAlarmVC:
			nextVC = activeAlarmVC
			animator = animatorEACCircle(setAlarmVC.alarmTimeButton.center, true)
		case activeAlarmVC:
			switch EACAlarmManager.sharedInstance.alarmState {
			case .Ringing, .Snooze:
				postFacebookVC.snoozeAmount = EACAlarmManager.sharedInstance.numOfSnoozes()
				nextVC = postFacebookVC
				animator = animatorEACCircle(CGPoint(x: activeAlarmVC.view.frame.midX, y: activeAlarmVC.view.frame.maxY), true)
			default:
				nextVC = startAlarmVC
				animator = animatorEACCircle(CGPoint(x: activeAlarmVC.view.frame.midX, y: activeAlarmVC.view.frame.maxY), false)
			}
		case postFacebookVC:
			nextVC = startAlarmVC
			animator = animatorEACCircle(CGPoint(x: activeAlarmVC.view.frame.minX, y: activeAlarmVC.view.frame.maxY), false)
		default:
			return
		}
		
		transitionFromViewController(currentChildViewController, toViewController: nextVC, animation: animator)
	}
	
	func transitionToPrevVC(sender: UIViewController) {
		
	}
	
	func hideButtonBar(hide: Bool) {
		containerViewButtons.hidden = hide
	}
	
	override func childViewControllerForStatusBarStyle() -> UIViewController? {
		return currentChildViewController
	}
	
}
