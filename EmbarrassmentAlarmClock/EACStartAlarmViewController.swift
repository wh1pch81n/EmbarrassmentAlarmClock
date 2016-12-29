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
	var statusBarImageView: UIImageView = UIImageView(frame: UIApplication.shared.statusBarFrame)
	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalIn: startButton.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.cgPath
		startButton.layer.mask = maskShape
		view.addSubview(statusBarImageView)
		statusBarImageView.isHidden = true
	}
	
	@IBAction func tappedStartButton(_ sender: AnyObject) {
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(false)
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
	
}
