//
//  EACAlarmManager.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

enum EACAlarmState {
	case initial
	case armed
	case ringing
	case snooze
}

protocol EACAlarmManagerDelegate: class {
	func alarmStateDidChange(_ alarmState: EACAlarmState)
}

class EACAlarmManager: NSObject {
	
	static let sharedInstance = EACAlarmManager()
	weak var eacAlarmManagerDelegate: EACAlarmManagerDelegate?
	var snoozeAmount = 0
	var alarmFireDate: Date?
	fileprivate var timer: Timer?
	var alarmState = EACAlarmState.initial {
		didSet {
			self.eacAlarmManagerDelegate?.alarmStateDidChange(alarmState)
		}
	}
	
	func alarmAction(_ timer: Timer) {
		alarmState = .ringing
		EACAudioManager.sharedInstance.playSong()
	}
	
	func numOfSnoozes() -> Int {
		return snoozeAmount
	}
	
	func armAlarm() {
		alarmState = .armed
		let cal = NSCalendar.current
		let nowDate = Date()
		let nextDateComponent = cal.dateComponents([.hour, .minute, .second], from: alarmFireDate!)
		
		let nextDate = cal.nextDate(after: nowDate,
		                            matching: nextDateComponent,
		                            matchingPolicy: Calendar.MatchingPolicy.nextTime,
		                            repeatedTimePolicy: Calendar.RepeatedTimePolicy.first
			, direction: Calendar.SearchDirection.forward)
		
		print("Now Date", nowDate)
		let nowDF = DateFormatter()
		nowDF.dateFormat = "HH:mm:ss"
		print(nowDF.string(from: nowDate))
		
		timer = Timer(fireAt: nextDate!, interval: 600, target: self, selector: #selector(EACAlarmManager.alarmAction(_:)), userInfo: nil, repeats: true)
		RunLoop.main.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
		
		EACAudioManager.AudioPlayerManager.sharedInstance.stoppedPlaying = { (stoppedBecauseAutoSnooze: Bool) -> () in
			if stoppedBecauseAutoSnooze {
				self.snoozeAlarm()
			}
		}
	}
	
	func stopAlarm() {
		snoozeAmount = 0
		alarmState = .initial
		EACAudioManager.AudioPlayerManager.sharedInstance.stop()
		timer?.invalidate()
		timer = nil
	}
	
	func snoozeAlarm() {
		snoozeAmount += 1
		alarmState = .snooze
		EACAudioManager.AudioPlayerManager.sharedInstance.snooze()
	}
	
	
	
}
