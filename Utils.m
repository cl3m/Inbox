//
//  Utils.m
//  gInbox
//
//  Created by Chen Asraf on 3/12/15.
//  Copyright (c) 2015 Chen Asraf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@implementation Utils

// Read file into string
+ (NSString *) readFileIntoNSString:(NSString *)path
ofType:(NSString *)fileType
{
    NSString* finalPath =
    [[NSBundle mainBundle] pathForResource:path ofType:fileType];
    NSStringEncoding* encoding = nil;
    NSString* content = [NSString stringWithContentsOfFile:finalPath usedEncoding:encoding error:nil];
    return content;
}

// inject JS string into document
+ (void) injectJSStringIntoWebView:(WebView*) webView JSString:(NSString*) jsString
{
    DOMDocument* domDocument = [webView mainFrameDocument];
    DOMElement* jsElement = [domDocument createElement:@"script"];
    [jsElement setAttribute:@"type" value:@"text/javascript"];
    DOMText* jsText = [domDocument createTextNode:jsString];
    [jsElement appendChild:jsText];
    DOMElement* bodyElement = (DOMElement*)[[domDocument getElementsByTagName:@"body"] item: 0];
    [bodyElement appendChild:jsElement];
}

// inject CSS string into document
+ (void) injectCSSStringIntoWebView:(WebView*) webView CSSString:(NSString*) cssString
{
    DOMDocument* domDocument = [webView mainFrameDocument];
    DOMElement* jsElement = [domDocument createElement:@"style"];
    [jsElement setAttribute:@"type" value:@"text/css"];
    DOMText* jsText = [domDocument createTextNode:cssString];
    [jsElement appendChild:jsText];
    DOMElement* bodyElement = (DOMElement*)[[domDocument getElementsByTagName:@"head"] item: 0];
    [bodyElement appendChild:jsElement];
}

@end