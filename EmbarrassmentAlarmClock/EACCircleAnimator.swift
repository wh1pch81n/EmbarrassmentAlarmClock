//
//  EACCircleAnimator.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

class EACCircleAnimator: NSObject, UIViewControllerAnimatedTransitioning, CAAnimationDelegate {
	
	var transitionContext: UIViewControllerContextTransitioning!
	var centerPoint = CGPoint.zero
	var centerRadius = CGFloat(0)
	var isPresenting: Bool
	var duration = TimeInterval(0.7)
	var didFinishAnimation = { () -> () in }
	
	init(isPresenting: Bool) {
		self.isPresenting = isPresenting
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext
		
		let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
		let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
		toVC.view.isUserInteractionEnabled = false
		fromVC.view.isUserInteractionEnabled = false
		
		if !transitionContext.containerView.subviews.contains(toVC.view) {
			transitionContext.containerView.addSubview(toVC.view)
		}
		if !transitionContext.containerView.subviews.contains(fromVC.view) {
			transitionContext.containerView.addSubview(fromVC.view)
		}
		if isPresenting {
			transitionContext.containerView.bringSubview(toFront: toVC.view)
		} else {
			transitionContext.containerView.bringSubview(toFront: fromVC.view)
		}
		
		let startMask: UIBezierPath
		let endMask: UIBezierPath
		
		if isPresenting {
			var startRect = CGRect(origin: centerPoint, size: CGSize.zero)
			startRect.size = CGSize(width: centerRadius * 2, height: centerRadius * 2)
			startRect = startRect.offsetBy(dx: -centerRadius, dy: -centerRadius)
			startMask = UIBezierPath(ovalIn: startRect)
			
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
			endRect = endRect.offsetBy(dx: -endRadius, dy: -endRadius)
			endMask = UIBezierPath(ovalIn: endRect)
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
			startRect = startRect.offsetBy(dx: -startRadius, dy: -startRadius)
			startMask = UIBezierPath(ovalIn: startRect)
			
			var endRect = CGRect(origin: centerPoint, size: CGSize.zero)
			endRect.size = CGSize(width: centerRadius * 2, height: centerRadius * 2)
			endRect = endRect.offsetBy(dx: -centerRadius, dy: -centerRadius)
			endMask = UIBezierPath(ovalIn: endRect)
		}
		
		let maskLayer = CAShapeLayer()
		maskLayer.path = startMask.cgPath
		if isPresenting {
			toVC.view.layer.mask = maskLayer
		} else {
			fromVC.view.layer.mask = maskLayer
		}
		
		let maskLayerAnimation = CABasicAnimation(keyPath: "path")
		maskLayerAnimation.fromValue = startMask.cgPath
		maskLayerAnimation.toValue = endMask.cgPath
		maskLayerAnimation.duration = transitionDuration(using: transitionContext)
		maskLayerAnimation.delegate = self
		maskLayerAnimation.fillMode = kCAFillModeForwards // Prevents flickering
		maskLayerAnimation.isRemovedOnCompletion = false // prevents flickering
		maskLayer.add(maskLayerAnimation, forKey: "path")
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
	}
	
	func animationEnded(_ transitionCompleted: Bool) {
		let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
		let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
		toVC.view.isUserInteractionEnabled = true
		fromVC.view.isUserInteractionEnabled = true
		if isPresenting {
			toVC.view.layer.mask = nil
		} else {
			fromVC.view.layer.mask = nil
		}
		DispatchQueue.main.async(execute: didFinishAnimation)
	}
	
}
