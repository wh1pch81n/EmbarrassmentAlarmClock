//
//  EACContextTransitioning.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

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
