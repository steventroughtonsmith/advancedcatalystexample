/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit
import UniformTypeIdentifiers

class CATWindowSceneDelegate : NSObject, UISceneDelegate, UIWindowSceneDelegate, UIDocumentPickerDelegate {
	
	var window: UIWindow?
	weak var scene:UIScene?
		
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		window = UIWindow(windowScene: scene as! UIWindowScene)
		self.scene = scene
		
		if let window = window {
			let rootViewController = CATMainViewController()
			window.rootViewController = rootViewController
			
			window.backgroundColor = .systemBackground

			reloadToolbar()

			window.makeKeyAndVisible()
			
		}
	}
	
	// MARK: - Toolbar Actions
	
	@objc func create(_ sender:Any) {
		if let documentViewController = window?.rootViewController as? CATMainViewController {
			documentViewController.newItem(sender)
		}
	}
	
	@objc func createFolder(_ sender:Any) {
		if let documentViewController = window?.rootViewController as? CATMainViewController {
			documentViewController.newFolder(sender)
		}
	}

	@objc func search(_ sender:Any) {
		if let nsSender = sender as? NSObject {
			if let string = nsSender.value(forKey: "stringValue") as? NSString {
				NSLog("[SEARCH]: \(string)")
				
				if let documentViewController = window?.rootViewController as? CATMainViewController {
					documentViewController.source.searchString = string as String
				}
			}
		}
	}

	// MARK: - Mac Toolbar
	
	func reloadToolbar() {
		#if targetEnvironment(macCatalyst)
		let toolbar = NSToolbar()
		toolbar.delegate = self
		toolbar.displayMode = .iconOnly
		
		window?.windowScene?.titlebar?.toolbar = toolbar
		window?.windowScene?.titlebar?.toolbarStyle = .automatic
		#endif
	}
}
