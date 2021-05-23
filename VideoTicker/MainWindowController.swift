//
//  MainWindowController.swift
//  DevToolboxNewUI
//
//  Created by Paul Derbyshire on 20/06/2019.
//  Copyright © 2019 DERBS.CO. All rights reserved.
//

import Cocoa
import Speech

class MainWindowController: NSWindowController {
	
    override func windowDidLoad() {
        super.windowDidLoad()
		
		window?.isMovableByWindowBackground = true
//		window?.titlebarAppearsTransparent = true
//		window?.titleVisibility = .hidden
		window?.backgroundColor = .white
		
		// - Check for microphone access
		SFSpeechRecognizer.requestAuthorization { (status) in
			print("\(status)")
		}
    }
	
	
	

}


class MainWindow: NSWindow {
	
	
	
}
