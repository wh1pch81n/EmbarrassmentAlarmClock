//
//  EACChildViewControllerDelegate.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import Foundation

protocol EACChildViewControllerDelegate: class {	
	func transitionToNextVC(sender: UIViewController)
	
	func transitionToPrevVC(sender: UIViewController)
	func hideButtonBar(hide: Bool)
	func setNeedsStatusBarAppearanceUpdate()
}

protocol EACChildViewControllerProtocol: class {
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate! { get set }
	var statusBarImageView: UIImageView! { set get }
}

extension EACChildViewControllerDelegate {
	var lightContentStatusBarImage: UIImage {
		UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
		self.setNeedsStatusBarAppearanceUpdate()
		return UIApplication.statusBarView.viewToImage()
	}
	var darkContentStatusBarImage: UIImage {
		UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
		self.setNeedsStatusBarAppearanceUpdate()
		return UIApplication.statusBarView.viewToImage()
	}
}