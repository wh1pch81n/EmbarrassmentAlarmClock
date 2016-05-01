//
//  EACCircleAnimator.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

class EACCircleAnimator: NSObject, UIViewControllerAnimatedTransitioning {
	
	var transitionContext: UIViewControllerContextTransitioning!
	var centerPoint = CGPoint.zero
	var centerRadius = CGFloat(0)
	var isPresenting: Bool
	var duration = NSTimeInterval(0.7)
	var didFinishAnimation = { () -> () in }
	
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
		toVC.view.userInteractionEnabled = false
		fromVC.view.userInteractionEnabled = false
		
		if !transitionContext.containerView()!.subviews.contains(toVC.view) {
			transitionContext.containerView()!.addSubview(toVC.view)
		}
		if !transitionContext.containerView()!.subviews.contains(fromVC.view) {
			transitionContext.containerView()!.addSubview(fromVC.view)
		}
		if isPresenting {
			transitionContext.containerView()!.bringSubviewToFront(toVC.view)
		} else {
			transitionContext.containerView()!.bringSubviewToFront(fromVC.view)
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
		toVC.view.userInteractionEnabled = true
		fromVC.view.userInteractionEnabled = true
		if isPresenting {
			toVC.view.layer.mask = nil
		} else {
			fromVC.view.layer.mask = nil
		}
		dispatch_async(dispatch_get_main_queue(), didFinishAnimation)
	}
	
}
