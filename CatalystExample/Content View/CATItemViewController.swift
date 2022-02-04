/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit
import SwiftUI

struct ContentView: View {
	@ObservedObject var item:CATItem = CATItem()

	var parent:CATItemViewController
	
	var body: some View {
		Text("MAIN_VIEW_HELLO_WORLD_LABEL")
	
	}
}

class CATItemViewController : UIViewController, ObservableObject {
	
	var hostingController:UIHostingController<ContentView>?
	var documentViewController:CATMainViewController?
	var source:CATSourceFile?
	
	override func viewDidLoad() {
		view.backgroundColor = .systemBackground
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		hostingController = UIHostingController(rootView: ContentView(parent: self))
		navigationItem.largeTitleDisplayMode = .never
		
		if let hostingController = hostingController {
			view.addSubview(hostingController.view)
		}
		
		if #available(macCatalyst 15.0, iOS 15.0, *) {
			focusGroupIdentifier = "com.example.details"
		}
	}

	// MARK: -
	
	@objc required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLayoutSubviews() {
		if let hostingController = hostingController {
			hostingController.view.frame = view.bounds.inset(by: view.safeAreaInsets)
		}
	}
	
	// MARK: - Keyboard Focus
	
	override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
		return false
	}
}
