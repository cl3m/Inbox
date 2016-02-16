//
//  Settings.swift
//  gInbox
//
//  Created by Chen Asraf on 11/9/14.
//  Copyright (c) 2014 Chen Asraf. All rights reserved.
//

import Foundation
import WebKit
import AppKit

public class Settings : NSWindowController, NSWindowDelegate {
    
	lazy var webViewController : WebViewController = WebViewController()
    var webView: WebView!
    
    public override func showWindow(sender: AnyObject?) {
        super.showWindow(sender)
    }
    
    public func showWindow(sender: AnyObject?, webView:WebView!) {
        super.showWindow(sender)
        self.webView = webView
    }
    
    public func windowWillClose(notification: NSNotification) {
		if let webUA = Preferences.getString("userAgentString") where webUA.characters.count > 0 {
			webView.customUserAgent = webUA
		}
        webView.mainFrame.reload()
    }
    
    @IBAction func resetPrefsToDefault(sender: AnyObject?) {
        Preferences.clearDefaults()
    }
}