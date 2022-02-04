/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
	static let newItem = NSToolbarItem.Identifier("com.highcaffeinecontent.catalystexample.new")
	static let newFolder = NSToolbarItem.Identifier("com.highcaffeinecontent.catalystexample.newfolder")
	static let search = NSToolbarItem.Identifier("com.highcaffeinecontent.catalystexample.search")
}

extension CATWindowSceneDelegate : NSToolbarDelegate {
	
	func toolbarIdentifiers() -> [NSToolbarItem.Identifier] {
		return [.flexibleSpace, .newFolder, .primarySidebarTrackingSeparatorItemIdentifier, .flexibleSpace, .supplementarySidebarTrackingSeparatorItemIdentifier, .newItem, .flexibleSpace, .search]
	}
	
	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return toolbarIdentifiers()
	}
	
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		return toolbarIdentifiers()
	}
	
	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		
		if itemIdentifier == .newItem {
			let barItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(create(_:)))
			let item = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: barItem)
			item.accessibilityLabel = NSLocalizedString("ITEM_NONE_SELECTED_NEW_BUTTON", comment: "")
			item.toolTip = NSLocalizedString("ITEM_NONE_SELECTED_NEW_BUTTON", comment: "")
			
			return item
		}
		else if itemIdentifier == .newFolder {
			let barItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(createFolder(_:)))
			let item = NSToolbarItem(itemIdentifier: itemIdentifier, barButtonItem: barItem)
			item.accessibilityLabel = NSLocalizedString("TOOLBAR_NEW_FOLDER_BUTTON", comment: "")
			item.toolTip = NSLocalizedString("TOOLBAR_NEW_FOLDER_BUTTON", comment: "")
			
			return item
		}
		else if itemIdentifier == .search {
			
			if let searchItem = CATAppDelegate.appKitController?.searchToolbarItem(sceneIdentifier:scene?.session.persistentIdentifier ?? UUID().uuidString, itemIdentifier: itemIdentifier, target: self, selector: #selector(search(_:))) {
				return searchItem
			}
			else {
				return NSToolbarItem(itemIdentifier: itemIdentifier)
			}
		}
		else {
			return NSToolbarItem(itemIdentifier: itemIdentifier)
		}
	}
}
#endif
