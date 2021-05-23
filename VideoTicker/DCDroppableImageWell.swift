//
//  DCDroppableImageWell.swift
//  DevToolboxNewUI
//
//  Created by Paul Derbyshire on 12/09/2019.
//  Copyright © 2019 DERBS.CO. All rights reserved.
//

import AppKit
import Foundation


class DCDroppableImageWell: NSImageView {
	
	@IBOutlet weak var dcDelegate: DCDroppableImageWellDelegate?
	var highlight: Bool = false
	var returnArray: Array<URL> = []
	
	
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.commonInit()
	}
	func commonInit() {
		self.registerForDraggedTypes([.fileURL])
	}
	
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		self.highlight = true
		self.setNeedsDisplay(self.bounds)
		return NSDragOperation.generic
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
		self.highlight = false
		self.setNeedsDisplay(self.bounds)
	}
	
	override func draggingEnded(_ sender: NSDraggingInfo) {
		self.highlight = false
		self.setNeedsDisplay(self.bounds)
		self.returnArray.removeAll()
		
		guard let items = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) else { return }
		let item = items.first as! URL
		
		if FileManager.isDirectory(url: item) {
			var pathArray = [String]()
			
			do {
				try pathArray = FileManager.default.contentsOfDirectory(atPath: item.path)
				for pathItem in pathArray {
					let url = item.appendingPathComponent(pathItem)
					self.returnArray.append(url)
				}
			} catch {
				print("error")
			}
			

		} else {
			
			for object in items {
				if let url = object as? URL {
					self.returnArray.append(url)
				}
				
			}
			
			
//			sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)?.forEach {
//				// Do something with the file paths.
//				if let url = $0 as? URL {
//					self.returnArray.append(url)
//				}
//			}
//
		}
		dcDelegate?.droppableImageWellDroppedFiles(files: self.returnArray)
		print(returnArray.description)
	}
	
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		if self.highlight {
			let color = NSColor.init(red: 0.188, green: 0.514, blue: 0.984, alpha: 1.0)
			color.set()
			NSBezierPath.defaultLineWidth = 5.0
			NSBezierPath.stroke(self.bounds)
		}
		
	}
	
}



@objc protocol DCDroppableImageWellDelegate: Any {
	func droppableImageWellDroppedFiles(files: Array<URL>)
}


extension FileManager {
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let directory = paths[0]
		return directory
	}
	func getDesktopDirectory() -> URL {
		let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
		let directory = paths[0]
		return directory
	}
	func getPicturesDirectory() -> URL {
		let paths = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)
		let directory = paths[0]
		return directory
	}
	func getAppSupportDirectory() -> URL {
		let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		let directory = paths[0]
		return directory
	}

	func getLibraryDirectory() -> URL {
		let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
		let directory = paths[0]
		return directory
	}
	
	public class func isDirectory(url: URL) -> Bool {
		let isDir = url.hasDirectoryPath
		return isDir
	}
	
	
}
