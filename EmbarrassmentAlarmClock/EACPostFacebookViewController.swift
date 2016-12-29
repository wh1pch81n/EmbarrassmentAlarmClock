//
//  EACPostFacebookViewController.swift
//  EmbarrassmentAlarmClock
//
//  Created by Derrick  Ho on 3/19/16.
//  Copyright © 2016 Derrick  Ho. All rights reserved.
//

class EACPostFacebookViewController: UIViewController, EACChildViewControllerProtocol {
	
	weak var eacChildViewControllerDelegate: EACChildViewControllerDelegate!
	var snoozeAmount = 0
	@IBOutlet var imageView: UIImageView!
	var statusBarImageView: UIImageView = UIImageView(frame: UIApplication.shared.statusBarFrame)
	
	@IBAction func tappedPostToFacebook(_ sender: AnyObject) {
//				let accessToken = FBSDKAccessToken.currentAccessToken()
//					if accessToken.hasGranted(FB_PUBLISH_ACTIONS) {
//						let req = FBSDKGraphRequest(graphPath: FB_GRAPHPATH_FEED, parameters: [
//							FB_GRAPHPATH_FEED_MESSAGE_KEY : "Hi"
//							], HTTPMethod: POST)
//						req.startWithCompletionHandler({ (gReq: FBSDKGraphRequestConnection!, data: AnyObject!, err: NSError!) -> Void in
//							if err == nil {
//								print("Post id", data)
//							}
//						})
//					}
		submitToFacebook()
		
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(statusBarImageView)
		statusBarImageView.isHidden = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.imageView.image = generateImage()
		eacChildViewControllerDelegate.hideButtonBar(true)
	}
	
	func generateImage() -> UIImage {
		let df = DateFormatter()
		df.dateFormat = "MMM dd, yyyy @ hh:mm:ss"
		var message: String = ""
		switch snoozeAmount {
		case 0:
			message += "I woke up without snoozing my alarm!"
		case 1:
			message += "I snoozed my alarm Just once."
		default:
			message += "I snoozed my ass \(snoozeAmount) times"
		}
		
		//message += " [\(df.stringFromDate(NSDate()))]"
		
		let label = UILabel()
		label.numberOfLines = 0
		label.textAlignment = NSTextAlignment.center
		label.text = message
		label.backgroundColor = UIColor.black
		label.textColor = UIColor.red
		
		let size = label.sizeThatFits(CGSize(width: 150, height: 0))
		label.frame.size = size
		
		return label.viewToImage()
	}
	
	@IBAction func tappedCancel(_ sender: AnyObject) {
		eacChildViewControllerDelegate.transitionToNextVC(self)
	}
	
	func submitToFacebook() {
		let photoImage = FBSDKSharePhoto()
		photoImage.image = self.imageView.image!
		photoImage.isUserGenerated = false
		let content = FBSDKSharePhotoContent()
		content.photos = [photoImage]
		
		//		FBSDKShareDialog.showFromViewController(activeAlarmVC.parentViewController, withContent: content, delegate: activeAlarmVC)
		
		FBSDKShareAPI.share(with: content, delegate: self)
		
//		let dialog = FBSDKShareDialog()
//		dialog.fromViewController = activeAlarmVC.parentViewController
//		dialog.shareContent = content;
//		dialog.mode = FBSDKShareDialogMode.Native; // if you don't set this before canShow call, canShow would always return YES
//		if (!dialog.canShow()) {
//			// fallback presentation when there is no FB app
//			dialog.mode = FBSDKShareDialogMode.FeedBrowser
//		}
//		dialog.show()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
}

extension EACPostFacebookViewController: FBSDKSharingDelegate {
	
	func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
		
	}
	
	func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
		
	}
	
	func sharerDidCancel(_ sharer: FBSDKSharing!) {
		
	}
	
}
