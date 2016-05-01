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
	var statusBarImageView: UIImageView = UIImageView(frame: UIApplication.sharedApplication().statusBarFrame)
	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalInRect: startButton.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.CGPath
		startButton.layer.mask = maskShape
		view.addSubview(statusBarImageView)
		statusBarImageView.hidden = true
	}
	
	@IBAction func tappedStartButton(sender: AnyObject) {
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(false)
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
}
