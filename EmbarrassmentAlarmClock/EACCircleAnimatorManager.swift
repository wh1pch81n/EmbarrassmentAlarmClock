//
//  EACCircleAnimatorManager.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

class EACCircleAnimatorManager: NSObject, UIViewControllerTransitioningDelegate {
	
	static let sharedInstance = EACCircleAnimatorManager()
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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
