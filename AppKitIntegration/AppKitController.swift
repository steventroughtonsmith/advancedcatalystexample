/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import AppKit

extension NSObject {
	@objc func hostWindowForSceneIdentifier(_ identifier:String) -> NSWindow? {
		return nil
	}
}

class AppKitController : NSObject {
	var searchItems:[String:NSSearchToolbarItem] = [:]

	// MARK: -
	
	@objc public func _marzipan_setupWindow(_ note:Notification) {
		
		NSLog("_marzipan_setupWindow: \(String(describing: note.userInfo))")
		
		/*
			Here, AppKit has generated the host window for your UIKit window.
			Now it is safe to go do any AppKit-y things you'd like to do to it
		*/
	}
	
	@objc public func closeWindowForSceneIdentifier(_ sceneIdentifier:String) {
		guard let appDelegate = NSApp.delegate as? NSObject else { return }
		
		if appDelegate.responds(to: #selector(hostWindowForSceneIdentifier(_:))) {
			guard let hostWindow = appDelegate.hostWindowForSceneIdentifier(sceneIdentifier) else { return }
			
			hostWindow.performClose(self)
		}
	}
}

extension AppKitController {

	@objc public func searchToolbarItem(sceneIdentifier:String, itemIdentifier:NSToolbarItem.Identifier, target:AnyObject, selector:Selector) -> NSToolbarItem {
		
		if let searchItem = searchItems[sceneIdentifier] {
			
			return searchItem
		}
		else {
			let searchItem = NSSearchToolbarItem(itemIdentifier: itemIdentifier)
			searchItem.target = target
			searchItem.action = selector
			searchItem.searchField.placeholderString = NSLocalizedString("TOOLBAR_SEARCH_PLACEHOLDER", comment: "")
			
			searchItems[sceneIdentifier] = searchItem

			return searchItem
		}
		
	}
}
