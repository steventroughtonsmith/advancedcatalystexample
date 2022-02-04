/*
 2021 Steven Troughton-Smith (@stroughtonsmith)
 Provided as sample code to do with as you wish.
 No license or attribution required.
 */

import UIKit

class CATMainViewController: UIViewController, ObservableObject, UISplitViewControllerDelegate {
	
	let rootSplitViewController = UISplitViewController(style: .tripleColumn)
	
	public var listViewController:CATItemListViewController?
	public let detailViewController = CATItemViewController()
	public let sourceListViewController = CATSourceListViewController()
	
	let source = CATSourceFile(url: Bundle.main.url(forResource: "Example", withExtension: "json")!)
	
	init() {
		
		super.init(nibName: nil, bundle: nil)
		
		listViewController = CATItemListViewController()
		
		rootSplitViewController.primaryBackgroundStyle = .sidebar
		
		rootSplitViewController.preferredPrimaryColumnWidth = UIFloat(260)
		rootSplitViewController.minimumPrimaryColumnWidth = UIFloat(200)
		
		rootSplitViewController.delegate = self
		rootSplitViewController.preferredDisplayMode = .twoBesideSecondary
		rootSplitViewController.modalPresentationStyle = .overFullScreen
		
#if targetEnvironment(macCatalyst)
		rootSplitViewController.presentsWithGesture = false
#endif
		
		buildThreeColumnUI()
		
		addChild(rootSplitViewController)
		view.addSubview(rootSplitViewController.view)
		
		
		listViewController?.documentViewController = self
		sourceListViewController.documentViewController = self
		
		listViewController?.source = source
		detailViewController.source = source
		sourceListViewController.source = source
		sourceListViewController.listViewController = listViewController
		
		traitCollectionDidChange(traitCollection)
	}
	
	
	func buildThreeColumnUI() {
		let sidebarNC = UINavigationController(rootViewController: sourceListViewController)
		
#if targetEnvironment(macCatalyst)
		sidebarNC.isNavigationBarHidden = true
#else
		sidebarNC.navigationBar.prefersLargeTitles = true
#endif
		
		let listNC = UINavigationController(rootViewController: listViewController!)
#if targetEnvironment(macCatalyst)
		listNC.isNavigationBarHidden = true
		listNC.navigationBar.setBackgroundImage(UIImage(), for: .default)
		listNC.navigationBar.shadowImage = UIImage()
#else
		listNC.navigationBar.prefersLargeTitles = true
#endif
		
		let detailViewNC = UINavigationController(rootViewController: detailViewController)
#if targetEnvironment(macCatalyst)
		detailViewNC.isNavigationBarHidden = true
#else
		detailViewNC.navigationBar.setBackgroundImage(UIImage(), for: .default)
		detailViewNC.navigationBar.shadowImage = UIImage()
#endif
		detailViewNC.isToolbarHidden = true
		
		rootSplitViewController.viewControllers = [sidebarNC, listNC, detailViewNC]
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Actions
	
	@objc func newItem(_ sender:Any) {
		let item = CATItem()
		source.add(item: item)
	}
	
	@objc func newFolder(_ sender:Any) {		
		source.newFolder()
	}
	
	// MARK: - Layout
	
	override func viewDidLayoutSubviews() {
		rootSplitViewController.view.frame = view.bounds
	}
	
	// MARK: - Disallow rotation on iPhone
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIDevice.current.userInterfaceIdiom == .phone ? .portrait : .all
	}
	
	// MARK: - Size Class Transition
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		if traitCollection.horizontalSizeClass == .regular {
			buildThreeColumnUI()
		}
	}
}
