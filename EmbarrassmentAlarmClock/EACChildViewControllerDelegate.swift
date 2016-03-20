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
}

protocol EACChildViewControllerProtocol: class {
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate! { get set }
}