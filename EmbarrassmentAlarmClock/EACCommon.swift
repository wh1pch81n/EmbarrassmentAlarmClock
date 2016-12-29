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
	
	func image(_ bundle: Bundle = Bundle.main) -> UIImage {
		return UIImage(named: self.rawValue, in: bundle, compatibleWith: nil)!
	}
}

func viewControllerFromType<T>(_ vc: T.Type) -> T {
	return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: vc)) as! T
}

func constrainSubview(_ view: UIView, toSuperView superView: UIView) {
	view.translatesAutoresizingMaskIntoConstraints = false
	view.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
	view.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
	view.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
	view.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
}

extension UIView {
	func viewToImage() -> UIImage {
		var viewImage: UIImage
		UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
		layer.render(in: UIGraphicsGetCurrentContext()!)
		
		viewImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return viewImage
	}
}

extension CGPoint {
	func distance(_ p: CGPoint) -> CGFloat {
		return sqrt(pow(self.x - p.x, 2) + pow(self.y - p.y, 2))
	}
}

extension UIApplication {
	static var statusBarView: UIView {
//			UIView *subViewWindow = [[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
//			for (UIView *i in subViewWindow.subviews) {
//				if ([i isKindOfClass:NSClassFromString(@"UIStatusBar")]) {
//					return i;
//				}
//			}
//			return nil;
//		}
	return (UIApplication.shared.value(forKey: "statusBarWindow")! as AnyObject).subviews[0]
	}
}

