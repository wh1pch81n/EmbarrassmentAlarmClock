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

func viewControllerFromType<T>(vc: T.Type) -> UIViewController {
	return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(typeAsString(vc))
}

let facebookLoginVC = viewControllerFromType(EACLoginViewController) as! EACLoginViewController
let startAlarmVC = viewControllerFromType(EACStartAlarmViewController) as!EACStartAlarmViewController
let setAlarmVC = viewControllerFromType(EACSetAlarmViewController) as! EACSetAlarmViewController
let activeAlarmVC = viewControllerFromType(EACActiveAlarmViewController) as! EACActiveAlarmViewController

protocol EACChildViewControllerDelegate: class {
	func transitionToNextVC(sender: UIViewController)
	
	func transitionToPrevVC(sender: UIViewController)
	func hideButtonBar(hide: Bool)
}

protocol EACChildViewController: class {
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate! { get set }
}

class ViewController: UIViewController, EACChildViewControllerDelegate {
	
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
		
		let vcs = Array<EACChildViewController>(arrayLiteral:
			facebookLoginVC,
			startAlarmVC,
			setAlarmVC,
			activeAlarmVC
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
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	func transitionFromViewController(fromViewController: UIViewController, toViewController: UIViewController, animation: ((UIViewControllerAnimatedTransitioning) -> ())? = nil) {
		toViewController.willMoveToParentViewController(self)
		let context = EACContextTransitioning(fromVC: self.currentChildViewController, toVC: toViewController, contentView: self.contentView)
		self.previousChildViewController = self.currentChildViewController
		self.currentChildViewController = toViewController
		self.addChildViewController(toViewController)
		let animator = EACCircleAnimator(isPresenting: true)
		context.animatorDelegate = animator
		animation?(animator)
		animator.animateTransition(context)
		toViewController.didMoveToParentViewController(self)
		
		self.setNeedsStatusBarAppearanceUpdate()
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
		
		let animatorEACCircle = { (centerPoint centerPoint: CGPoint) -> (animator: UIViewControllerAnimatedTransitioning) -> () in
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
			animator = animatorEACCircle(centerPoint: startAlarmVC.startButton.center)
		case setAlarmVC:
			nextVC = activeAlarmVC
			animator = animatorEACCircle(centerPoint: setAlarmVC.alarmTimeButton.center)
		case activeAlarmVC:
			nextVC = startAlarmVC
			animator = animatorEACCircle(centerPoint: CGPoint(x: activeAlarmVC.view.frame.minX, y: activeAlarmVC.view.frame.maxY))
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

class EACLoginViewController: UIViewController, FBSDKLoginButtonDelegate, EACChildViewController {
	
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
				where permissions.contains(FB_PUBLISH_ACTIONS)
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

class EACStartAlarmViewController: UIViewController, EACChildViewController {
	
	@IBOutlet weak var startButton: UIButton!
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate!

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalInRect: startButton.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.CGPath
		startButton.layer.mask = maskShape
	}
	
	@IBAction func tappedStartButton(sender: AnyObject) {
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(false)
	}
	
}

class EACSetAlarmViewController: UIViewController, EACChildViewController {
	@IBOutlet weak var alarmTimeButton: UIButton!
	@IBOutlet weak var datePicker: UIDatePicker!
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate!

	let chosenDateKey = "chosen_date_key"
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.Default
	}
	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalInRect: alarmTimeButton.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.CGPath
		alarmTimeButton.layer.mask = maskShape
	}
	
	@IBAction func tappedAlarmTimeButton(sender: AnyObject) {
		// save the time somewhere
		EACAlarmManager.sharedInstance.alarmFireDate = datePicker.date
		EACAlarmManager.sharedInstance.armAlarm()
		
		NSUserDefaults.standardUserDefaults().setObject(datePicker.date, forKey: chosenDateKey)
		// transition to next view
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(false)
		
		if let object = NSUserDefaults.standardUserDefaults().objectForKey(chosenDateKey) {
			if let dateObject = object as? NSDate {
				datePicker.setDate(dateObject, animated: true)
			}
		}
	}
	
}

class EACActiveAlarmViewController: UIViewController, EACChildViewController, EACAlarmManagerDelegate {
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate!

	@IBOutlet weak var alarmSetLabel: UILabel!
	
	@IBOutlet weak var snoozeCount: UIButton!
	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalInRect: snoozeCount.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.CGPath
		snoozeCount.layer.mask = maskShape
		
		self.view.addGestureRecognizer({
			let g = UISwipeGestureRecognizer(target: self, action: "stopAlarm:")
			g.direction = UISwipeGestureRecognizerDirection.Right
			return g
		}())
		view.userInteractionEnabled = true
	}
	
	func alarmStateDidChange(alarmState: EACAlarmState) {
		updateSnoozeButton()
	}
	
	func updateSnoozeButton() {
		switch EACAlarmManager.sharedInstance.alarmState {
		case .Initial:
			snoozeCount.setTitle("Won't ring", forState: UIControlState.Normal)
		case .Armed:
			snoozeCount.setTitle("Disable Alarm", forState: UIControlState.Normal)
		case .Ringing:
			snoozeCount.setTitle("Snooze Me!", forState: UIControlState.Normal)
		case .Snooze:
			let numSnoozes = EACAlarmManager.sharedInstance.numOfSnoozes()
			let text = numSnoozes == 1 ? "\(numSnoozes)\nSnooze": "\(numSnoozes)\nSnoozes"
			snoozeCount.setTitle(text, forState: UIControlState.Normal)
		}
		snoozeCount.titleLabel!.numberOfLines = 0
		snoozeCount.titleLabel!.setNeedsLayout()
		snoozeCount.titleLabel!.textAlignment = NSTextAlignment.Center
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateSnoozeButton()
		EACAlarmManager.sharedInstance.eacAlarmManagerDelegate = self
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (n: NSNotification) -> Void in
			self.updateSnoozeButton()
		}
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.LightContent
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(false)
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		alarmSetLabel.text = dateFormatter.stringFromDate(EACAlarmManager.sharedInstance.alarmFireDate!)
		
		updateSnoozeButton()
	}
	
	@IBAction func tappedSnooze(sender: AnyObject) {
		switch EACAlarmManager.sharedInstance.alarmState {
		case .Initial: fallthrough
		case .Armed:
			stopAlarm(self)
		case .Ringing:
			EACAlarmManager.sharedInstance.snoozeAlarm()
		case .Snooze:
			() // Probably add some useless animation
		}
	}
	
	@IBAction func stopAlarm(sender: AnyObject) {
		EACAlarmManager.sharedInstance.stopAlarm()
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
}

enum EACAlarmState {
	case Initial
	case Armed
	case Ringing
	case Snooze
}

protocol EACAlarmManagerDelegate: class {
	func alarmStateDidChange(alarmState: EACAlarmState)
}

class EACAlarmManager: NSObject {
	
	static let sharedInstance = EACAlarmManager()
	weak var eacAlarmManagerDelegate: EACAlarmManagerDelegate?
	var snoozeAmount = 0
	var alarmFireDate: NSDate?
	private var timer: NSTimer?
	var alarmState = EACAlarmState.Initial {
		didSet {
			self.eacAlarmManagerDelegate?.alarmStateDidChange(alarmState)
		}
	}
	
	func alarmAction(timer: NSTimer) {
		alarmState = .Ringing
		EACAudioManager.sharedInstance.playSong()
	}
	
	func numOfSnoozes() -> Int {
		return snoozeAmount
	}
	
	func armAlarm() {
		alarmState = .Armed
		let cal = NSCalendar.currentCalendar()
		let nowDate = NSDate()
		let nextDateComponent = cal.components([NSCalendarUnit.Hour, .Minute, .Second], fromDate: alarmFireDate!)

		let nextDate = cal.nextDateAfterDate(nowDate,
			matchingHour: nextDateComponent.hour,
			minute: nextDateComponent.minute,
			second: 0, options: NSCalendarOptions.MatchNextTime)
		
		print("Now Date", nowDate)
		let nowDF = NSDateFormatter()
		nowDF.dateFormat = "HH:mm:ss"
		print(nowDF.stringFromDate(nowDate))
		
		timer = NSTimer(fireDate: nextDate!, interval: 600, target: self, selector: "alarmAction:", userInfo: nil, repeats: true)
		NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
		
		EACAudioManager.AudioPlayerManager.sharedInstance.stoppedPlaying = { (stoppedBecauseAutoSnooze: Bool) -> () in
			if stoppedBecauseAutoSnooze {
				self.snoozeAlarm()
			}
		}
	}
	
	func stopAlarm() {
		snoozeAmount = 0
		switch EACAlarmManager.sharedInstance.alarmState {
		case .Ringing, .Snooze: submitToFacebook()
		default:()
		}
		alarmState = .Initial
		EACAudioManager.AudioPlayerManager.sharedInstance.stop()
		timer?.invalidate()
		timer = nil
	}
	
	func snoozeAlarm() {
		snoozeAmount += 1
		alarmState = .Snooze
		EACAudioManager.AudioPlayerManager.sharedInstance.snooze()
	}
	
	func submitToFacebook() {
		let df = NSDateFormatter()
		df.dateFormat = "MMM dd, yyyy @ hh:mm:ss"
		var message: String = ""//"[\(df.stringFromDate(NSDate()))] "
		switch numOfSnoozes() {
		case 0:
			message += "I woke up without snoozing my alarm!"
		case 1:
			message += "I snoozed my alarm Just once."
		default:
			message += "I snoozed my ass \(numOfSnoozes()) times"
		}
		
//		let accessToken = FBSDKAccessToken.currentAccessToken()
//		if accessToken.hasGranted(FB_PUBLISH_ACTIONS) {
//			let req = FBSDKGraphRequest(graphPath: FB_GRAPHPATH_FEED, parameters: [
//				FB_GRAPHPATH_FEED_MESSAGE_KEY : message
//				], HTTPMethod: POST)
//			req.startWithCompletionHandler({ (gReq: FBSDKGraphRequestConnection!, data: AnyObject!, err: NSError!) -> Void in
//				if err == nil {
//					print("Post id", data)
//				}
//			})
//		}
		let components = NSURLComponents(string: "http://derrickho.co.nf/skills.html")!
		components.queryItems = [
			NSURLQueryItem(name: "snoozeMSG", value: message)
		]
		let content = FBSDKShareLinkContent()
		content.contentURL = NSURL(string: "https://www.facebook.com")//components.URL!
		content.contentDescription = message
		FBSDKShareDialog.showFromViewController(activeAlarmVC, withContent: content, delegate: activeAlarmVC)
		print(message)
		print(components)
	}
	
}

extension EACActiveAlarmViewController: FBSDKSharingDelegate {
	
	func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
		
	}
	
	func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
		
	}
	
	func sharerDidCancel(sharer: FBSDKSharing!) {
		
	}
	
}

class EACCircleAnimatorManager: NSObject, UIViewControllerTransitioningDelegate {
	
	static let sharedInstance = EACCircleAnimatorManager()
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animator = EACCircleAnimator(isPresenting: true)
		
		if let _ = presenting as? ViewController,
			let _ = presented as? EACLoginViewController
		{
			animator.centerPoint = presenting.view.center
		} else if let _ = presenting as? ViewController,
			let _ = presented as? EACStartAlarmViewController
		{
			animator.centerPoint = presenting.view.center
		} else if let _presenting = presenting as? EACStartAlarmViewController,
			let _ = presented as? EACSetAlarmViewController
		{
			animator.centerPoint = _presenting.startButton.center
		}
		else {
			return nil
		}
		return animator
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animator = EACCircleAnimator(isPresenting: false)

		if let _dismissed = dismissed as? EACLoginViewController {
			animator.centerPoint = _dismissed.viewFBButton.center
		} else if let _dismissed = dismissed as? EACStartAlarmViewController {
			animator.centerPoint = _dismissed.startButton.center
		}
		else {
			return nil
		}
		return animator
	}
	
}

// presenting and dismissing a viewcontroller creates a context for you but in the case of using child view controllers you need to create your own context.
class EACContextTransitioning: NSObject, UIViewControllerContextTransitioning {
	
	var fromVC: UIViewController
	var toVC: UIViewController
	var contentView: UIView
	weak var animatorDelegate: UIViewControllerAnimatedTransitioning?
	
	init(fromVC: UIViewController, toVC: UIViewController, contentView: UIView) {
		self.fromVC = fromVC
		self.toVC = toVC
		self.contentView = contentView
		
		// temporarily disable autolayer while animation takes place
		fromVC.view.translatesAutoresizingMaskIntoConstraints = true
		toVC.view.translatesAutoresizingMaskIntoConstraints = true
		
		fromVC.view.frame = contentView.bounds
		fromVC.view.bounds = contentView.bounds
		
		toVC.view.frame = contentView.bounds
		toVC.view.bounds = contentView.bounds
	}
	
	func containerView() -> UIView? {
		return contentView
	}
	
	func isAnimated() -> Bool {
		return true
	}
	
	func isInteractive() -> Bool {
		return false
	}
	
	func transitionWasCancelled() -> Bool {
		return false
	}
	
	func presentationStyle() -> UIModalPresentationStyle {
		return UIModalPresentationStyle.FullScreen
	}
	
	func updateInteractiveTransition(percentComplete: CGFloat) {
		
	}
	
	func finishInteractiveTransition() {
		
	}
	
	func cancelInteractiveTransition() {
		
	}
	
	func completeTransition(didComplete: Bool) {
		contentView.subviews
			.filter({ $0 != toVC.view })
			.forEach({ $0.removeFromSuperview() })
		constrainSubview(toVC.view, toSuperView: contentView)
		animatorDelegate?.animationEnded?(true)
	}
	
	func viewControllerForKey(key: String) -> UIViewController? {
		switch key {
		case UITransitionContextToViewControllerKey:
			return toVC
		case UITransitionContextFromViewControllerKey:
			return fromVC
		default:
			return nil
		}
	}
	
	func viewForKey(key: String) -> UIView? {
		switch key {
		case UITransitionContextToViewKey:
			return toVC.view
		case UITransitionContextFromViewKey:
			return fromVC.view
		default:
			return nil
		}
	}
	
	func targetTransform() -> CGAffineTransform {
		return CGAffineTransform()
	}
	
	func initialFrameForViewController(vc: UIViewController) -> CGRect {
		return contentView.bounds
	}
	
	func finalFrameForViewController(vc: UIViewController) -> CGRect {
		return contentView.bounds
	}
	
}

class EACCircleAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	var transitionContext: UIViewControllerContextTransitioning!
	var centerPoint = CGPoint.zero
	var centerRadius = CGFloat(0)
	var isPresenting: Bool
	var duration = NSTimeInterval(0.7)
	
	init(isPresenting: Bool) {
		self.isPresenting = isPresenting
	}
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return duration
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		
		let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		
		if isPresenting {
			transitionContext.containerView()!.addSubview(toVC.view)
		}
		
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
		maskLayerAnimation.fillMode = kCAFillModeForwards // Prevents flickering
		maskLayerAnimation.removedOnCompletion = false // prevents flickering
		maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
	}

	override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
		transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
	}
	
	func animationEnded(transitionCompleted: Bool) {
		let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		if isPresenting {
			toVC.view.layer.mask = nil
		} else {
			fromVC.view.layer.mask = nil
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

extension UIViewController {
	
	func viewToImage() -> UIImage {
		var viewImage: UIImage
		UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
		self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
		
		viewImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return viewImage
	}
	
}

enum EACAudioFile: String {
	case Glass
	case Ping
	case Sosumi
	
	func audio(bundle: NSBundle = NSBundle.mainBundle()) -> AVAudioPlayer {
		return try! AVAudioPlayer(data: NSDataAsset(name: self.rawValue, bundle: bundle)!.data)
	}
}

class EACAudioManager: NSObject, AVAudioPlayerDelegate {
	static let sharedInstance = EACAudioManager()
	var volumeDidChange = { (newVolume: Float) -> () in }
	var currentVolume: Float { return AVAudioSession.sharedInstance().outputVolume }
	
	class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
		static var sharedInstance = AudioPlayerManager()
		
		var audioPlayer = AVAudioPlayer()
		var repeats = 0
		var isPlaying = false
		var stoppedPlaying = { (becauseAutoSnooze: Bool) -> () in }
		// MARK: AVAudioPlayerDelegate
		func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
			playAudio()
		}
		
		func playAudio() {
			if repeats > 0 {
				repeats -= 1
				isPlaying = self.audioPlayer.play()
			} else {
				isPlaying = false
				if repeats == 0 {
					stoppedPlaying(true)
				} else if repeats == -1 {
					stoppedPlaying(false)
				}
			}
		}
		
		func snooze() {
			repeats = -1
			if isPlaying {
				self.audioPlayer.stop()
			}
		}
		
		func stop() {
			repeats = -1
			if isPlaying {
				self.audioPlayer.stop()
			}
		}
	}
	
	override init() {
		super.init()
		
		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		
		try! AVAudioSession.sharedInstance().setActive(true)
		AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.New, context: nil)
	}
	
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if let keyPath = keyPath {
			switch keyPath {
			case "outputVolume":
				volumeDidChange(object!.valueForKeyPath(keyPath) as! Float)
			default:()
			}
		}
	}
	
	func playSong(duration: NSTimeInterval = 60.0) {
		let audioPlayer = EACAudioFile.Glass.audio()
		audioPlayer.delegate = AudioPlayerManager.sharedInstance
		AudioPlayerManager.sharedInstance.audioPlayer = audioPlayer
		AudioPlayerManager.sharedInstance.repeats = Int(ceil(duration / audioPlayer.duration))
		AudioPlayerManager.sharedInstance.playAudio()
		
	}

}


func constrainSubview(view: UIView, toSuperView superView: UIView) {
	view.translatesAutoresizingMaskIntoConstraints = false
	view.topAnchor.constraintEqualToAnchor(superView.topAnchor).active = true
	view.bottomAnchor.constraintEqualToAnchor(superView.bottomAnchor).active = true
	view.leadingAnchor.constraintEqualToAnchor(superView.leadingAnchor).active = true
	view.trailingAnchor.constraintEqualToAnchor(superView.trailingAnchor).active = true
}