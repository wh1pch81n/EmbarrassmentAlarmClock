//
//  EACStartAlarmViewController.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

class EACStartAlarmViewController: UIViewController, EACChildViewControllerProtocol {
	
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
