//
//  EACActiveAlarmViewController.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

class EACActiveAlarmViewController: UIViewController, EACChildViewControllerProtocol, EACAlarmManagerDelegate {
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate!
	
	@IBOutlet weak var alarmSetLabel: UILabel!
	@IBOutlet weak var snoozeCount: UIButton!
	var statusBarImageView: UIImageView = UIImageView(frame: UIApplication.shared.statusBarFrame)

	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalIn: snoozeCount.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.cgPath
		snoozeCount.layer.mask = maskShape
		
		self.view.addGestureRecognizer({
			let g = UISwipeGestureRecognizer(target: self, action: #selector(EACActiveAlarmViewController.stopAlarm(_:)))
			g.direction = UISwipeGestureRecognizerDirection.right
			return g
			}())
		view.isUserInteractionEnabled = true
		view.addSubview(statusBarImageView)
		statusBarImageView.isHidden = true
	}
	
	func alarmStateDidChange(_ alarmState: EACAlarmState) {
		updateSnoozeButton()
	}
	
	func updateSnoozeButton() {
		switch EACAlarmManager.sharedInstance.alarmState {
		case .initial:
			snoozeCount.setTitle("Won't ring", for: UIControlState())
		case .armed:
			snoozeCount.setTitle("Disable Alarm", for: UIControlState())
		case .ringing:
			snoozeCount.setTitle("Snooze Me!", for: UIControlState())
		case .snooze:
			let numSnoozes = EACAlarmManager.sharedInstance.numOfSnoozes()
			let text = numSnoozes == 1 ? "\(numSnoozes)\nSnooze": "\(numSnoozes)\nSnoozes"
			snoozeCount.setTitle(text, for: UIControlState())
		}
		snoozeCount.titleLabel!.numberOfLines = 0
		snoozeCount.titleLabel!.setNeedsLayout()
		snoozeCount.titleLabel!.textAlignment = NSTextAlignment.center
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateSnoozeButton()
		EACAlarmManager.sharedInstance.eacAlarmManagerDelegate = self
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { (n: Notification) -> Void in
			self.updateSnoozeButton()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(false)
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		alarmSetLabel.text = dateFormatter.string(from: EACAlarmManager.sharedInstance.alarmFireDate!)
		
		updateSnoozeButton()
	}
	
	@IBAction func tappedSnooze(_ sender: AnyObject) {
		switch EACAlarmManager.sharedInstance.alarmState {
		case .initial: fallthrough
		case .armed:
			stopAlarm(self)
		case .ringing:
			EACAlarmManager.sharedInstance.snoozeAlarm()
		case .snooze:
			() // Probably add some useless animation
		}
	}
	
	@IBAction func stopAlarm(_ sender: AnyObject) {
		eacChildViewControllerDelegate.transitionToNextVC(self)
		EACAlarmManager.sharedInstance.stopAlarm()
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .lightContent
	}
	
}

