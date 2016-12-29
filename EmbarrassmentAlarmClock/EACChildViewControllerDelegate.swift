//
//  EACChildViewControllerDelegate.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import Foundation

protocol EACChildViewControllerDelegate: class {	
	func transitionToNextVC(_ sender: UIViewController)
	
	func transitionToPrevVC(_ sender: UIViewController)
	func hideButtonBar(_ hide: Bool)
	func setNeedsStatusBarAppearanceUpdate()
}

protocol EACChildViewControllerProtocol: class {
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate! { get set }
	var statusBarImageView: UIImageView { get }
}

extension EACChildViewControllerDelegate {
	var lightContentStatusBarImage: UIImage {
		UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
		self.setNeedsStatusBarAppearanceUpdate()
		return UIApplication.statusBarView.viewToImage()
	}
	var darkContentStatusBarImage: UIImage {
		UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: false)
		self.setNeedsStatusBarAppearanceUpdate()
		return UIApplication.statusBarView.viewToImage()
	}
}
