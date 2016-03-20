//
//  EACAlarmManager.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

enum EACAlarmState {
	case Initial
	case Armed
	case Ringing
	case Snooze
}

protocol EACAlarmManagerDelegate: class {
	func alarmStateDidChange(alarmState: EACAlarmState)
}

class EACAlarmManager: NSObject {
	
	static let sharedInstance = EACAlarmManager()
	weak var eacAlarmManagerDelegate: EACAlarmManagerDelegate?
	var snoozeAmount = 0
	var alarmFireDate: NSDate?
	private var timer: NSTimer?
	var alarmState = EACAlarmState.Initial {
		didSet {
			self.eacAlarmManagerDelegate?.alarmStateDidChange(alarmState)
		}
	}
	
	func alarmAction(timer: NSTimer) {
		alarmState = .Ringing
		EACAudioManager.sharedInstance.playSong()
	}
	
	func numOfSnoozes() -> Int {
		return snoozeAmount
	}
	
	func armAlarm() {
		alarmState = .Armed
		let cal = NSCalendar.currentCalendar()
		let nowDate = NSDate()
		let nextDateComponent = cal.components([NSCalendarUnit.Hour, .Minute, .Second], fromDate: alarmFireDate!)
		
		let nextDate = cal.nextDateAfterDate(nowDate,
			matchingHour: nextDateComponent.hour,
			minute: nextDateComponent.minute,
			second: 0, options: NSCalendarOptions.MatchNextTime)
		
		print("Now Date", nowDate)
		let nowDF = NSDateFormatter()
		nowDF.dateFormat = "HH:mm:ss"
		print(nowDF.stringFromDate(nowDate))
		
		timer = NSTimer(fireDate: nextDate!, interval: 600, target: self, selector: "alarmAction:", userInfo: nil, repeats: true)
		NSRunLoop.mainRunLoop().addTimer(timer!, forMode: NSDefaultRunLoopMode)
		
		EACAudioManager.AudioPlayerManager.sharedInstance.stoppedPlaying = { (stoppedBecauseAutoSnooze: Bool) -> () in
			if stoppedBecauseAutoSnooze {
				self.snoozeAlarm()
			}
		}
	}
	
	func stopAlarm() {
		snoozeAmount = 0
		alarmState = .Initial
		EACAudioManager.AudioPlayerManager.sharedInstance.stop()
		timer?.invalidate()
		timer = nil
	}
	
	func snoozeAlarm() {
		snoozeAmount += 1
		alarmState = .Snooze
		EACAudioManager.AudioPlayerManager.sharedInstance.snooze()
	}
	
	
	
}