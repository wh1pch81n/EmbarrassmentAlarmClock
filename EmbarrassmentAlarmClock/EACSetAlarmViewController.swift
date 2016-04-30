//
//  EACSetAlarmViewController.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

class EACSetAlarmViewController: UIViewController, EACChildViewControllerProtocol {
	@IBOutlet weak var alarmTimeButton: UIButton!
	@IBOutlet weak var datePicker: UIDatePicker!
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate!
	
	let chosenDateKey = "chosen_date_key"
	var statusBarImageView: UIImageView!
	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalInRect: alarmTimeButton.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.CGPath
		alarmTimeButton.layer.mask = maskShape
		statusBarImageView = UIImageView(frame: UIApplication.statusBarView.bounds)
		view.addSubview(statusBarImageView)
		statusBarImageView.hidden = true;
	}
	
	@IBAction func tappedAlarmTimeButton(sender: AnyObject) {
		// save the time somewhere
		EACAlarmManager.sharedInstance.alarmFireDate = datePicker.date
		EACAlarmManager.sharedInstance.armAlarm()
		
		NSUserDefaults.standardUserDefaults().setObject(datePicker.date, forKey: chosenDateKey)
		// transition to next view
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(false)
		
		if let object = NSUserDefaults.standardUserDefaults().objectForKey(chosenDateKey) {
			if let dateObject = object as? NSDate {
				datePicker.setDate(dateObject, animated: true)
			}
		}
	}
	
}

