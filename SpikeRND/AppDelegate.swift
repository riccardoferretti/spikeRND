//
//  AppDelegate.swift
//  SpikeRND
//
//  Created by Riccardo on 06/05/2016.
//
//

import Cocoa
import React

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, RCTBridgeDelegate {

  @IBOutlet weak var window: NSWindow!
  var bridge: RCTBridge? = nil

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    let windowController: NSWindowController  = NSWindowController(window: self.window)

    let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 1100, height: 620))
    let appDefTextbox = Views.createAppTextField(frame:  NSRect(x: 10, y: 10, width: 400, height: 600)) { text in
        self.bridge?.eventDispatcher.sendDeviceEventWithName("onCommit", body: ["metadata": text])
    }
    let renderView = Views.createRenderView(frame: NSRect(x: 430, y: 10, width: 660, height: 600))

    rootView.subviews = [appDefTextbox, renderView]

    window.contentView = rootView
    window.minSize = NSSize(width: 1100, height: 620)
    windowController.showWindow(self.window)

    bridge = RCTBridge(delegate:self, launchOptions: [:])
    let reactRootView = RCTRootView(bridge: bridge, moduleName: "SpikeRND", initialProperties: nil)
    reactRootView.frame = renderView.bounds
    renderView.addSubview(reactRootView)
    //rootView.subviews = [appDefTextbox, reactRootView]
  }

  func applicationWillTerminate(aNotification: NSNotification) {
  }

  func sourceURLForBridge(bridge: RCTBridge) -> NSURL? {
    #if BUNDLE
      return NSBundle.mainBundle().URLForResource("main", withExtension: "jsbundle")
    #else
      return NSURL(string: "http://localhost:8081/index.osx.bundle?platform=osx&dev=true")
    #endif
  }

  func loadSourceForBridge(bridge: RCTBridge, withBlock loadCallback:RCTSourceLoadBlock) {
    if let url = sourceURLForBridge(bridge) {
        RCTJavaScriptLoader.loadBundleAtURL(url) { (err, data) in
            // some logic here (hide spinner or show indicator
            loadCallback(err, data)
        }
    } 

  }

}

struct Views {
  static func createRenderView(frame frame: NSRect) -> NSView {
    let renderView = NSView(frame: frame)
    renderView.layer?.backgroundColor = NSColor.whiteColor().CGColor
    return renderView
  }

static func readDefaultMetadata() -> String {
    do {
        let defaultApp = NSBundle.mainBundle().pathForResource("app", ofType: "json")
        let content = try String(contentsOfFile:defaultApp!, encoding: NSUTF8StringEncoding)
        return content
    } catch _ as NSError {
        return ""
    }
}

  static func createAppTextField(frame frame: NSRect, onCommit: String -> ()) -> NSView {
    let scrollview = NSScrollView(frame: frame)
    let textfield = TextView(frame: frame)
    textfield.onCommit = onCommit
    textfield.font = NSFont(name: "Courier", size: 12)
    textfield.automaticDashSubstitutionEnabled = false
    textfield.automaticTextReplacementEnabled = false
    textfield.automaticQuoteSubstitutionEnabled = false
    textfield.automaticSpellingCorrectionEnabled = false
    textfield.string = readDefaultMetadata()
    scrollview.documentView = textfield
    return scrollview
  }
}


class TextView: NSTextView {
  var onCommit: (String -> ())?

  override func keyDown(event: NSEvent) {
    let char = event.characters!
    let modifiers = event.modifierFlags

    // press CMD+ENTER
    if char == String(UnicodeScalar(13)) && modifiers.contains(NSEventModifierFlags.CommandKeyMask) {
      if let onCommit = self.onCommit {
        onCommit(self.textStorage!.string)
      }
    }
    super.keyDown(event)
  }
}