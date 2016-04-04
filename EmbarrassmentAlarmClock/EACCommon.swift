//
//  EACCommon.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

import UIKit

let FB_PUBLISH_ACTIONS = "publish_actions"
let FB_GRAPHPATH_FEED = "me/feed"
let FB_GRAPHPATH_FEED_MESSAGE_KEY = "message"

let POST = "POST"

enum ImageAsset: String {
	case Facebook_F_icon = "Facebook-F-icon"
	
	func image(bundle: NSBundle = NSBundle.mainBundle()) -> UIImage {
		return UIImage(named: self.rawValue, inBundle: bundle, compatibleWithTraitCollection: nil)!
	}
}

func typeAsString<T>(type: T.Type) -> String {
	return "\(type)".componentsSeparatedByString(".").last!
}

func viewControllerFromType<T>(vc: T.Type) -> UIViewController {
	return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(typeAsString(vc))
}

func constrainSubview(view: UIView, toSuperView superView: UIView) {
	view.translatesAutoresizingMaskIntoConstraints = false
	view.topAnchor.constraintEqualToAnchor(superView.topAnchor).active = true
	view.bottomAnchor.constraintEqualToAnchor(superView.bottomAnchor).active = true
	view.leadingAnchor.constraintEqualToAnchor(superView.leadingAnchor).active = true
	view.trailingAnchor.constraintEqualToAnchor(superView.trailingAnchor).active = true
}

func viewToImage(view: UIView) -> UIImage {
	var viewImage: UIImage
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
	view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
	
	viewImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	
	return viewImage
}

extension CGPoint {
	func distance(p: CGPoint) -> CGFloat {
		return sqrt(pow(self.x - p.x, 2) + pow(self.y - p.y, 2))
	}
}
