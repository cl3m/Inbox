//
//  AppDelegate.swift
//  gInbox
//
//  Created by Chen Asraf on 11/9/14.
//  Copyright (c) 2014 Chen Asraf. All rights reserved.
//

import Foundation
import Cocoa
import WebKit
import AppKit
import ApplicationServices
import Alamofire
import SWXMLHash


class AppDelegate : NSObject, NSApplicationDelegate {
	var mailto : NSURL?
	var timer : NSTimer!

	@IBOutlet var window: NSWindow!
	@IBOutlet weak var webViewController: WebViewController?

	
	override init() {
		super.init()
		let appleEventManager = NSAppleEventManager.sharedAppleEventManager()
		appleEventManager.setEventHandler(self, andSelector: Selector("handleGetURLEvent:replyEvent:"), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL))
		timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("updateBadge"), userInfo: nil, repeats: false)
	}

    func applicationDidFinishLaunching(notification: NSNotification) {
        self.window.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
		updateBadge()
	}
	
	func handleGetURLEvent(event : NSAppleEventDescriptor,  replyEvent: NSAppleEventDescriptor)
	{
		if let urlString = event.paramDescriptorForKeyword(UInt32(keyDirectObject))?.stringValue {
			let encoded = CFURLCreateStringByAddingPercentEscapes(nil, urlString, nil, "!*'();:@&=+$,/?%#[]", CFStringBuiltInEncodings.UTF8.rawValue)
			mailto = NSURL(string : "https://inbox.google.com/?mailto=\(encoded)")
			if let webView = webViewController?.webView {
				webView.mainFrame.loadRequest(NSURLRequest(URL: mailto!))
			}
		}
	}

    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            window.orderFront(self)
        } else {
            window.makeKeyAndOrderFront(self)
        }
        return true
    }
	func updateBadge() {
		Alamofire.request(.GET, "https://mail.google.com/mail/u/0/feed/atom", parameters: nil)
			.response { (request, response, data, error) in
				let xml = SWXMLHash.parse(data!)
				if let unread = xml["feed"]["fullcount"].element?.text where Int(unread) > 0 {
					NSApplication.sharedApplication().dockTile.badgeLabel = unread
				} else {
					NSApplication.sharedApplication().dockTile.badgeLabel = nil
				}
		}
	}
	
}