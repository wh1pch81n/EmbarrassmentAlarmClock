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
	
	var containerView: UIView {
		return contentView
	}
	
	var isAnimated: Bool {
		return true
	}
	
	var isInteractive: Bool {
		return false
	}
	
	var transitionWasCancelled: Bool {
		return false
	}
	
	var presentationStyle: UIModalPresentationStyle {
		return UIModalPresentationStyle.fullScreen
	}
	
	func updateInteractiveTransition(_ percentComplete: CGFloat) {
		
	}
	
	func finishInteractiveTransition() {
		
	}
	
	func cancelInteractiveTransition() {
		
	}
	
	func completeTransition(_ didComplete: Bool) {
		contentView.subviews
			.filter({ $0 != toVC.view })
			.forEach({ $0.removeFromSuperview() })
		constrainSubview(toVC.view, toSuperView: contentView)
		animatorDelegate?.animationEnded?(true)
	}
	
	func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
		switch key {
		case UITransitionContextViewControllerKey.to:
			return toVC
		case UITransitionContextViewControllerKey.from:
			return fromVC
		default:
			return nil
		}
	}
	
	func view(forKey key: UITransitionContextViewKey) -> UIView? {
		switch key {
		case UITransitionContextViewKey.to:
			return toVC.view
		case UITransitionContextViewKey.from:
			return fromVC.view
		default:
			return nil
		}
	}
	
	var targetTransform: CGAffineTransform {
		return CGAffineTransform()
	}
	
	func initialFrame(for vc: UIViewController) -> CGRect {
		return contentView.bounds
	}
	
	func finalFrame(for vc: UIViewController) -> CGRect {
		return contentView.bounds
	}
	
	func pauseInteractiveTransition() {
		
	}
	
}
