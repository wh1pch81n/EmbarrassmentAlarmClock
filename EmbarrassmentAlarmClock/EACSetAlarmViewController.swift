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
	var statusBarImageView: UIImageView = UIImageView(frame: UIApplication.shared.statusBarFrame)
	
	override func loadView() {
		super.loadView()
		let circle = UIBezierPath(ovalIn: alarmTimeButton.bounds)
		let maskShape = CAShapeLayer()
		maskShape.path = circle.cgPath
		alarmTimeButton.layer.mask = maskShape
		view.addSubview(statusBarImageView)
		statusBarImageView.isHidden = true
	}
	
	@IBAction func tappedAlarmTimeButton(_ sender: AnyObject) {
		// save the time somewhere
		EACAlarmManager.sharedInstance.alarmFireDate = datePicker.date 
		EACAlarmManager.sharedInstance.armAlarm()
		
		UserDefaults.standard.set(datePicker.date, forKey: chosenDateKey)
		// transition to next view
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		eacChildViewControllerDelegate.hideButtonBar(false)
		
		if let object = UserDefaults.standard.object(forKey: chosenDateKey) {
			if let dateObject = object as? Date {
				datePicker.setDate(dateObject, animated: true)
			}
		}
	}
	
	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .default
	}
	
}

