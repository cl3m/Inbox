//
//  WebViewController.swift
//  gInbox
//
//  Created by Chen Asraf on 11/11/14.
//  Copyright (c) 2014 Chen Asraf. All rights reserved.
//

import Foundation
import WebKit
import AppKit
import Cocoa

@available(OSX 10.10, *)

class WebViewController: NSViewController, WKNavigationDelegate, NSURLDownloadDelegate, WebPolicyDelegate, WebUIDelegate {
    
    @IBOutlet weak var webView: WebView!
    let openURLWebView = WebView()
    let settingsController = Settings(windowNibName: "Settings")
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        openURLWebView.policyDelegate = self

        let url : NSURL!
		if let app = NSApplication.sharedApplication().delegate as? AppDelegate, let mailto = app.mailto {
			url = mailto
		} else {
			url = NSURL(string : "https://inbox.google.com/")!
		}
		
        let request = NSURLRequest(URL: url)
        
        if (!Preferences.getBool("afterFirstLaunch")!) {
            Preferences.clearDefaults()
        }
        
		if let webUA = Preferences.getString("userAgentString") where webUA.characters.count > 0 {
			webView.customUserAgent = webUA
		}
        webView.mainFrame.loadRequest(request)
    }
    
    @IBAction func openSettings(sender: AnyObject) {
        settingsController.showWindow(sender, webView: webView)
    }
	
	@IBAction func logout(sender: AnyObject) {
		webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: "https://accounts.google.com/Logout?continue=https%3A%2F%2Finbox.google.com%2F")!))
	}
    
    func webView(sender: WebView!, createWebViewWithRequest request: NSURLRequest!) -> WebView! {
        return openURLWebView
    }

    @available(OSX 10.10, *)
    func webView(sender: WKWebView,
        decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
            if sender == webView {
                NSWorkspace.sharedWorkspace().openURL(navigationAction.request.URL!)
            }
    }
    
    func webView(sender: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        
        if actionInformation["WebActionOriginalURLKey"] != nil {
            let url = (actionInformation["WebActionOriginalURLKey"]?.absoluteString as String?)!
            let hangoutsNav:Bool = (url.hasPrefix("https://plus.google.com/hangouts/") || url.hasPrefix("https://talkgadget.google.com/u/"))
            let hideHangouts:Bool = (Preferences.getInt("hangoutsMode") > 0)
            
            if (url.hasPrefix("#")) {
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
                listener.ignore()
            } else if sender == openURLWebView {
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: url)!)
                listener.ignore()
            } else if hideHangouts && hangoutsNav {
                listener.ignore()
            } else {
                listener.use()
            }
        }
    }
    
    func webView(webView: WebView!, decidePolicyForNewWindowAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
        if (request.URL!.absoluteString.hasPrefix("https://accounts.google.com") == false && request.URL!.absoluteString.hasPrefix("https://inbox.google.com") == false) {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: (actionInformation["WebActionOriginalURLKey"]?.absoluteString)!)!)
            listener.ignore()
        } else {
            webView.mainFrame.loadRequest(request)
        }
    }
	
	func webView(webView: WebView!, decidePolicyForMIMEType type: String!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
		if(type != "text/html") {
            listener.download()
		}
	}

    /*override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        let path = NSBundle.mainBundle().pathForResource("gInboxTweaks", ofType: "js", inDirectory: "Assets")
        let jsString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
        let hangoutsMode: String? = Preferences.getString("hangoutsMode")
        
        webView.stringByEvaluatingJavaScriptFromString(jsString)
        webView.stringByEvaluatingJavaScriptFromString(String(format: "console.log('test'); updateHangoutsMode(%@)", hangoutsMode!))
    }*/
    
    func consoleLog(message: String) {
        NSLog("[JS] -> %@", message)
    }
    
    func webView(sender: WebView!, didClearWindowObject windowObject: WebScriptObject!, forFrame frame: WebFrame!) {
        
        if (webView.mainFrameDocument != nil) { // && frame.DOMDocument == webView.mainFrameDocument) {
            let document:DOMDocument = webView.mainFrameDocument
            let hangoutsMode: String? = Preferences.getString("hangoutsMode")
            let windowScriptObject = webView.windowScriptObject;
            windowScriptObject.setValue(self, forKey: "gInbox")
            windowScriptObject.evaluateWebScript("console = { log: function(msg) { gInbox.consoleLog(msg); } }")
            
            let path = NSBundle.mainBundle().pathForResource("gInboxTweaks", ofType: "js")
            let jsString = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            let script = document.createElement("script")
            let jsText = document.createTextNode(jsString)
            let bodyEl = document.getElementsByName("body").item(0)
            
            script.setAttribute("type", value: "text/javascript")
            script.appendChild(jsText)
            bodyEl?.appendChild(script)
            
            webView.stringByEvaluatingJavaScriptFromString(jsString)
            webView.stringByEvaluatingJavaScriptFromString(String(format: "console.log('test'); updateHangoutsMode(%@)", hangoutsMode!))
            
            windowScriptObject.evaluateWebScript(String(format: "console.log('test'); updateHangoutsMode(%@)", hangoutsMode!))
        }
    }
    
    func webView(sender: WebView!, resource identifier: AnyObject!, willSendRequest request: NSURLRequest!, redirectResponse: NSURLResponse!, fromDataSource dataSource: WebDataSource!) -> NSURLRequest! {

        return NSMutableURLRequest(URL: request.URL!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: request.timeoutInterval)
    }
    
    func isSelectorExcludedFromWebScript(selector: Selector) -> Bool {
        if selector == Selector("consoleLog") {
            return false
        }
        return true
    }

    func download(_download: NSURLDownload,
                    decideDestinationWithSuggestedFilename filename: String) {
        let savePanel = NSSavePanel();
        savePanel.nameFieldStringValue = filename;

        if (savePanel.runModal() == NSModalResponseOK) {
            _download.setDestination(savePanel.URL!.path!, allowOverwrite: false)
        } else {
            _download.cancel()
        }
    }
}