/*
 2021 Steven Troughton-Smith (@stroughtonsmith)
 Provided as sample code to do with as you wish.
 No license or attribution required.
 */

import UIKit

/*
 Let Swift know how to talk to the APIs defined in your AppKitIntegration framework,
 which you can't link directly because it's built for macOS, not iOS
 */

#if targetEnvironment(macCatalyst)

extension NSObject {
	@objc public func _marzipan_setupWindow(_ sender:Any) {
		
	}
	
	@objc public func searchToolbarItem(sceneIdentifier:String, itemIdentifier:NSToolbarItem.Identifier, target:AnyObject, selector:Selector) -> NSToolbarItem {
		return NSToolbarItem(itemIdentifier: itemIdentifier)
	}
	
	@objc func CAT_endEditing(_ sender:Any?) {
		
	}
}
#endif

@main
class CATAppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
#if targetEnvironment(macCatalyst)
	
	static var appKitController:NSObject?
	
	class func fixNSSearchFieldFocusLockup() {
		/*
		 
		 In macOS 11 and macOS 12, tabbing to and from a search field in the toolbar
		 will cause an endless loop. FB9724872
		 
		 This may be fixed in a future release, but for now, we can swizzle the issue
		 away for another day.
		 
		 */
		
		let m1 = class_getInstanceMethod(NSClassFromString("NSSearchFieldCell"), NSSelectorFromString("endEditing:"))
		let m2 = class_getInstanceMethod(NSClassFromString("NSSearchFieldCell"), NSSelectorFromString("CAT_endEditing:"))
		
		if let m1 = m1, let m2 = m2 {
			method_exchangeImplementations(m1, m2)
		}
	}
	
	class func loadAppKitIntegrationFramework() {
		
		if let frameworksPath = Bundle.main.privateFrameworksPath {
			let bundlePath = "\(frameworksPath)/AppKitIntegration.framework"
			do {
				try Bundle(path: bundlePath)?.loadAndReturnError()
				
				let bundle = Bundle(path: bundlePath)!
				NSLog("[APPKIT BUNDLE] Loaded Successfully")
				
				if let appKitControllerClass = bundle.classNamed("AppKitIntegration.AppKitController") as? NSObject.Type {
					appKitController = appKitControllerClass.init()
					
					NotificationCenter.default.addObserver(appKitController as Any, selector: #selector(_marzipan_setupWindow(_:)), name: NSNotification.Name("UISBHSDidCreateWindowForSceneNotification"), object: nil)
				}
			}
			catch {
				NSLog("[APPKIT BUNDLE] Error loading: \(error)")
			}
		}
	}
#endif
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
#if targetEnvironment(macCatalyst)
		
		CATAppDelegate.loadAppKitIntegrationFramework()
		CATAppDelegate.fixNSSearchFieldFocusLockup()
		
#endif
		
		return true
	}
	
}

