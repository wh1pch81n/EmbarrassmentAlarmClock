//
//  EACAudioManager.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

enum EACAudioFile: String {
	case Glass
	case Ping
	case Sosumi
	
	func audio(_ bundle: Bundle = Bundle.main) -> AVAudioPlayer {
		return try! AVAudioPlayer(data: NSDataAsset(name: self.rawValue, bundle: bundle)!.data)
	}
}

class EACAudioManager: NSObject, AVAudioPlayerDelegate {
	static let sharedInstance = EACAudioManager()
	var volumeDidChange = { (newVolume: Float) -> () in }
	var currentVolume: Float { return AVAudioSession.sharedInstance().outputVolume }
	
	class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
		static var sharedInstance = AudioPlayerManager()
		
		var audioPlayer = AVAudioPlayer()
		var repeats = 0
		var isPlaying = false
		var stoppedPlaying = { (becauseAutoSnooze: Bool) -> () in }
		// MARK: AVAudioPlayerDelegate
		func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
			playAudio()
		}
		
		func playAudio() {
			if repeats > 0 {
				repeats -= 1
				isPlaying = self.audioPlayer.play()
			} else {
				isPlaying = false
				if repeats == 0 {
					stoppedPlaying(true)
				} else if repeats == -1 {
					stoppedPlaying(false)
				}
			}
		}
		
		func snooze() {
			repeats = -1
			if isPlaying {
				self.audioPlayer.stop()
			}
		}
		
		func stop() {
			repeats = -1
			if isPlaying {
				self.audioPlayer.stop()
			}
		}
	}
	
	override init() {
		super.init()
		
		try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		
		try! AVAudioSession.sharedInstance().setActive(true)
		AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if let keyPath = keyPath {
			switch keyPath {
			case "outputVolume":
				volumeDidChange((object! as AnyObject).value(forKey: keyPath) as! Float)
			default:()
			}
		}
	}
	
	func playSong(_ duration: TimeInterval = 60.0) {
		let audioPlayer = EACAudioFile.Glass.audio()
		audioPlayer.delegate = AudioPlayerManager.sharedInstance
		AudioPlayerManager.sharedInstance.audioPlayer = audioPlayer
		AudioPlayerManager.sharedInstance.repeats = Int(ceil(duration / audioPlayer.duration))
		AudioPlayerManager.sharedInstance.playAudio()
		
	}
	
}
