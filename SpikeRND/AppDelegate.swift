//
//  AppDelegate.swift
//  SpikeRND
//
//  Created by Riccardo on 06/05/2016.
//
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    let windowController: NSWindowController  = NSWindowController(window: self.window)

    let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 1100, height: 620))
    let appDefTextbox = Views.createAppTextField(frame:  NSRect(x: 10, y: 10, width: 400, height: 600)) { text in
      NSLog(text)
    }
    let renderView = Views.createRenderView(frame: NSRect(x: 430, y: 10, width: 660, height: 600))

    rootView.subviews = [appDefTextbox, renderView]

    window.contentView = rootView
    window.minSize = NSSize(width: 1100, height: 620)
    windowController.showWindow(self.window)
  }

  func applicationWillTerminate(aNotification: NSNotification) {
  }
}



struct Views {
  static func createRenderView(frame frame: NSRect) -> NSView {
    let renderView = NSView(frame: frame)
    renderView.wantsLayer = true
    renderView.layer?.backgroundColor = NSColor.controlHighlightColor().CGColor
    renderView.layer?.borderColor = NSColor.controlDarkShadowColor().CGColor
    renderView.layer?.borderWidth = 1.0
    return renderView
  }

  static func createAppTextField(frame frame: NSRect, onCommit: String -> ()) -> NSView {
    let scrollview = NSScrollView(frame: frame)
    let textfield = TextView(frame: frame)
    textfield.onCommit = onCommit
    textfield.font = NSFont(name: "Courier", size: 12)
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