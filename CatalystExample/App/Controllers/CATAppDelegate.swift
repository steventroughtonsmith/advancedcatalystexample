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
	
	@objc public func hideWindowForSceneIdentifier(_ sceneIdentifier:String) {
   
	}
	
	@objc public func showWindowForSceneIdentifier(_ sceneIdentifier:String) {
	
	}
	
	@objc public func searchToolbarItem(sceneIdentifier:String, itemIdentifier:NSToolbarItem.Identifier, target:AnyObject, selector:Selector) -> NSToolbarItem {
		return NSToolbarItem(itemIdentifier: itemIdentifier)
	}
}
#endif

@main
class CATAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
	#if targetEnvironment(macCatalyst)
	
	static var appKitController:NSObject?
	
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
		#endif
		
        return true
    }

}

