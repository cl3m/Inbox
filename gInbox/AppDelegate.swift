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

class AppDelegate : NSObject, NSApplicationDelegate {
	var mailto : NSURL?

	@IBOutlet var window: NSWindow!
	@IBOutlet weak var webViewController: WebViewController?

	
	override init() {
		super.init()
		let appleEventManager = NSAppleEventManager.sharedAppleEventManager()
		appleEventManager.setEventHandler(self, andSelector: Selector("handleGetURLEvent:replyEvent:"), forEventClass: UInt32(kInternetEventClass), andEventID: UInt32(kAEGetURL))
	}

    func applicationDidFinishLaunching(notification: NSNotification) {
        self.window.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
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
}