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
	var statusBarImageView: UIImageView!

	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalInRect: snoozeCount.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.CGPath
		snoozeCount.layer.mask = maskShape
		
		self.view.addGestureRecognizer({
			let g = UISwipeGestureRecognizer(target: self, action: #selector(EACActiveAlarmViewController.stopAlarm(_:)))
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
		eacChildViewControllerDelegate.transitionToNextVC(self)
		EACAlarmManager.sharedInstance.stopAlarm()
	}
	
}

