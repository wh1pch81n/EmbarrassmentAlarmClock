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
		let d =  NSUserDefaults.standardUserDefaults()
			.objectForKey("performFetchWithCompletionHandler") as? NSDate
		let df = NSDateFormatter()
		df.dateStyle = .MediumStyle
		df.timeStyle = .MediumStyle
		let alert = UIAlertView(
			title: d != nil ? df.stringFromDate(d!) : ("not set"),
			message: nil,
			delegate: nil,
			cancelButtonTitle: "ok"
		)
		alert.show()
	}
	
	func transitionFromViewController(fromViewController: UIViewController, toViewController: UIViewController, animation: ((UIViewControllerAnimatedTransitioning) -> ())? = nil) {
		toViewController.willMoveToParentViewController(self)
		let context = EACContextTransitioning(fromVC: self.currentChildViewController, toVC: toViewController, contentView: self.contentView)
		let toVCEAC = toViewController as? EACChildViewControllerProtocol
		let fromVCEAC = fromViewController as? EACChildViewControllerProtocol
		fromVCEAC?.statusBarImageView?.hidden = false
		toVCEAC?.statusBarImageView?.hidden = false
		
		if case let (loginView?, setAlarm?) = ((fromViewController as? EACLoginViewController)?.statusBarImageView,
		                                       (toViewController as? EACSetAlarmViewController)?.statusBarImageView) {
			loginView.image = lightContentStatusBarImage
			setAlarm.image = darkContentStatusBarImage
		} else if case let (setAlarm?, loginView?) = ((fromViewController as? EACSetAlarmViewController)?.statusBarImageView,
		                                              (toViewController as? EACLoginViewController)?.statusBarImageView) {
			setAlarm.image = darkContentStatusBarImage
			loginView.image = lightContentStatusBarImage
		}
		else if case let (loginView?, start?) = ((fromViewController as? EACLoginViewController)?.statusBarImageView,
		                                              (toViewController as? EACStartAlarmViewController)?.statusBarImageView) {
			loginView.image = darkContentStatusBarImage
			start.image = darkContentStatusBarImage
		} else if case let (start?, loginView?) = ((fromViewController as? EACStartAlarmViewController)?.statusBarImageView,
		                                              (toViewController as? EACLoginViewController)?.statusBarImageView) {
			start.image = darkContentStatusBarImage
			loginView.image = darkContentStatusBarImage
		}
		else if case let (loginView?, active?) = ((fromViewController as? EACActiveAlarmViewController)?.statusBarImageView,
		                                              (toViewController as? EACSetAlarmViewController)?.statusBarImageView) {
			loginView.image = darkContentStatusBarImage
			active.image = darkContentStatusBarImage
		} else if case let (active?, loginView?) = ((fromViewController as? EACActiveAlarmViewController)?.statusBarImageView,
		                                              (toViewController as? EACLoginViewController)?.statusBarImageView) {
			active.image = darkContentStatusBarImage
			loginView.image = darkContentStatusBarImage
		}
		else if case let (start?, setAlarm?) = ((fromViewController as? EACStartAlarmViewController)?.statusBarImageView,
		                                       (toViewController as? EACSetAlarmViewController)?.statusBarImageView) {
			start.image = lightContentStatusBarImage
			setAlarm.image = darkContentStatusBarImage
		} else if case let (setAlarm?, start?) = ((fromViewController as? EACSetAlarmViewController)?.statusBarImageView,
		                                              (toViewController as? EACStartAlarmViewController)?.statusBarImageView) {
			setAlarm.image = darkContentStatusBarImage
			start.image = lightContentStatusBarImage
		}
		else if case let (active?, setAlarm?) = ((fromViewController as? EACActiveAlarmViewController)?.statusBarImageView,
		                                        (toViewController as? EACSetAlarmViewController)?.statusBarImageView) {
			active.image = darkContentStatusBarImage
			setAlarm.image = lightContentStatusBarImage
		} else if case let (setAlarm?, active?) = ((fromViewController as? EACSetAlarmViewController)?.statusBarImageView,
		                                          (toViewController as? EACActiveAlarmViewController)?.statusBarImageView) {
			setAlarm.image = lightContentStatusBarImage
			active.image = darkContentStatusBarImage
		}
		else if case let (active?, post?) = ((fromViewController as? EACActiveAlarmViewController)?.statusBarImageView,
		                                         (toViewController as? EACPostFacebookViewController)?.statusBarImageView) {
			active.image = darkContentStatusBarImage
			post.image = darkContentStatusBarImage
		} else if case let (post?, active?) = ((fromViewController as? EACPostFacebookViewController)?.statusBarImageView,
		                                           (toViewController as? EACActiveAlarmViewController)?.statusBarImageView) {
			post.image = darkContentStatusBarImage
			active.image = darkContentStatusBarImage
		}
		
		self.previousChildViewController = self.currentChildViewController
		self.currentChildViewController = toViewController
		self.addChildViewController(toViewController)
		let animator = EACCircleAnimator(isPresenting: true)
		context.animatorDelegate = animator
		UIApplication.statusBarView.hidden = true
		animation?(animator)
		self.view.userInteractionEnabled = false
		animator.animateTransition(context)
		toViewController.didMoveToParentViewController(self)
		animator.didFinishAnimation = {
			fromVCEAC?.statusBarImageView?.hidden = true
			toVCEAC?.statusBarImageView?.hidden = true
			UIApplication.statusBarView.hidden = false
			self.view.userInteractionEnabled = true
		}
	}
	
	// MARK: Buttons
	@IBAction func tappedFacebookButton(sender: UITapGestureRecognizer) {
		//facebookLoginVC.transitioningDelegate = EACCircleAnimatorManager.sharedInstance
		//presentViewController(facebookLoginVC, animated: true, completion: nil)
				let nextVC: UIViewController
		if self.currentChildViewController == facebookLoginVC {
			// dismiss
			nextVC = self.previousChildViewController!
		} else {
			nextVC = facebookLoginVC
		}
		transitionFromViewController(currentChildViewController, toViewController: nextVC)
	}
	
	// MARK: EACChildViewControllerDelegate 
	func transitionToNextVC(sender: UIViewController) {
		let nextVC: UIViewController!
		var animator: ((animator: UIViewControllerAnimatedTransitioning) -> ())? = nil
		
		let animatorEACCircle = { (centerPoint: CGPoint) -> (animator: UIViewControllerAnimatedTransitioning) -> () in
			return { (animator: UIViewControllerAnimatedTransitioning) -> () in
				if let _animator = animator as? EACCircleAnimator {
					_animator.centerPoint = centerPoint
				}
			}
		}
		
		switch sender {
		case facebookLoginVC:
			if let setUpVC = presetViewController {
				nextVC = setUpVC
			} else if let prevVC = self.previousChildViewController {
				nextVC = prevVC
			} else {
				nextVC = startAlarmVC
			}
		case startAlarmVC:
			nextVC = setAlarmVC
			animator = animatorEACCircle(startAlarmVC.startButton.center)
		case setAlarmVC:
			nextVC = activeAlarmVC
			animator = animatorEACCircle(setAlarmVC.alarmTimeButton.center)
		case activeAlarmVC:
			switch EACAlarmManager.sharedInstance.alarmState {
			case .Ringing, .Snooze:
				postFacebookVC.snoozeAmount = EACAlarmManager.sharedInstance.numOfSnoozes()
				nextVC = postFacebookVC
			default:
				nextVC = startAlarmVC
			}
			animator = animatorEACCircle(CGPoint(x: activeAlarmVC.view.frame.midX, y: activeAlarmVC.view.frame.maxY))
		case postFacebookVC:
			nextVC = startAlarmVC
			animator = animatorEACCircle(CGPoint(x: activeAlarmVC.view.frame.minX, y: activeAlarmVC.view.frame.maxY))
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
