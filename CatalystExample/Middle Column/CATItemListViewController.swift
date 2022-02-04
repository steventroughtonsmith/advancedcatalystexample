/*
 2021 Steven Troughton-Smith (@stroughtonsmith)
 Provided as sample code to do with as you wish.
 No license or attribution required.
 */

import UIKit

class CATItemListViewController: UICollectionViewController {
	
	static let cellIdentifier = "Cell"
	var diffableDataSource:UICollectionViewDiffableDataSource<AnyHashable,AnyHashable>?
	var selectedIdentifier = UUID().uuidString
	
	var documentViewController:CATMainViewController? {
		didSet {
			reload()
		}
	}
	
	var source:CATSourceFile? {
		didSet {
			reload()
		}
	}
	
	var currentFolderIndex = CATSourceFile.CATFolderIndexAll {
		didSet {
			
			if currentFolderIndex == CATSourceFile.CATFolderIndexAll {
				title = NSLocalizedString("SIDEBAR_ALL_ITEMS", comment: "")
			}
			else if currentFolderIndex == CATSourceFile.CATFolderIndexRecents {
				title = NSLocalizedString("SIDEBAR_RECENTS", comment: "")
			}
			else {
				title = source?.dataStore.folders[currentFolderIndex].title
			}
			
			DispatchQueue.main.async {
				self.reload()
			}
		}
	}
	
	// MARK: -
	
	init() {
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											  heightDimension: .absolute(UIFloat(80)))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		
		let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize,
													 subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		let layout = UICollectionViewCompositionalLayout(section: section)
		
		super.init(collectionViewLayout: layout)
		
		diffableDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, ctx in
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CATItemListViewController.cellIdentifier, for: indexPath) as! CATItemListViewCell
			
			if let items = self.source?.sortedItems(tagIndex: self.currentFolderIndex) {
				let item = items[indexPath.item]
				
				cell.titleLabel.text = item.title
				cell.bodyLabel.text = item.body
				cell.modifiedLabel.text = CATPrettyFormatDate(item.created, dateStyle: .short, timeStyle: .none)
			}
			
			return cell
		})
		
#if !targetEnvironment(macCatalyst)
		collectionView.backgroundColor = .systemGroupedBackground
#endif
	
		collectionView.backgroundColor = .systemBackground
		
		collectionView.register(CATItemListViewCell.self, forCellWithReuseIdentifier: CATItemListViewController.cellIdentifier)
		collectionView.dataSource = diffableDataSource
		collectionView.delegate = self
		
		if #available(iOS 15.0, macOS 15.0, *) {
			collectionView.allowsFocus = true
		}
		
		collectionView.contentInset.top = UIFloat(13)
		
		NotificationCenter.default.addObserver(forName: .documentChanged, object: nil, queue: nil) { [weak self] _ in
			DispatchQueue.main.async {
				
				
				if self!.currentFolderIndex >= 0 {
					if let count = self!.source?.dataStore.folders.count {
						
						if self!.currentFolderIndex < count {
							if let tag = self!.source?.dataStore.folders[self!.currentFolderIndex] {
								self!.title = tag.title
							}
						}
						else {
							self!.title = ""
						}
					}
				}
				
				self!.reload()
			}
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		
#if !targetEnvironment(macCatalyst)
		let searchController = UISearchController()
		
		searchController.searchResultsUpdater = self
		searchController.definesPresentationContext = true
		searchController.delegate = self
		searchController.obscuresBackgroundDuringPresentation = false
		
		navigationItem.searchController = searchController
#endif
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.clearsSelectionOnViewWillAppear = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		let barItem = UIBarButtonItem(barButtonSystemItem: .compose, target: documentViewController, action: NSSelectorFromString("newItem:"))
		
		if UIDevice.current.userInterfaceIdiom != .phone {
			navigationItem.title = NSLocalizedString("SIDEBAR_ALL_ITEMS", comment: "")
		}
		navigationItem.rightBarButtonItem = barItem
		
		
	}
	
	// MARK: - Keyboard Avoidance
	
	@objc func adjustForKeyboard(notification: Notification) {
		guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
		
		let keyboardScreenEndFrame = keyboardValue.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
		
		if notification.name == UIResponder.keyboardWillHideNotification {
			collectionView.contentInset = .zero
		} else {
			collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
		}
		
		collectionView.scrollIndicatorInsets = collectionView.contentInset
	}
	
	// MARK: - Diffable Data Source
	
	func reload() {
		
		var snapshot = NSDiffableDataSourceSnapshot<AnyHashable,AnyHashable>()
		
		snapshot.appendSections(["items"])
		
		if let items = source?.sortedItems(tagIndex: currentFolderIndex) {
			snapshot.appendItems(items)
		}
		
		guard let diffableDataSource = diffableDataSource else { return }

		diffableDataSource.apply(snapshot, animatingDifferences: false, completion: { [weak self] in
			self!.selectItemWithIdentifier(self!.selectedIdentifier)
		})
	}
	
	func selectItemWithIdentifier(_ identifier:String) {
		
		var intendedIndexPath = IndexPath(item: 0, section: 0)
		var found = false
		
		if let items = source?.sortedItems(tagIndex: self.currentFolderIndex) {
			for i in 0 ..< items.count {
				if items[i].identifier == identifier {
					intendedIndexPath.item = i
					found = true
					break
				}
			}
		}
		
		if found == true {
			guard intendedIndexPath.section < collectionView.numberOfSections else { return }
			guard intendedIndexPath.item < collectionView.numberOfItems(inSection: intendedIndexPath.section) else { return }
			
			collectionView.selectItem(at: intendedIndexPath, animated: false, scrollPosition: [])
		}
	}
	
	func pushItemWithIdentifier(_ identifier:String) {
		
		var intendedIndexPath = IndexPath(item: 0, section: 0)
		var found = false
		
		if let items = source?.sortedItems(tagIndex: self.currentFolderIndex) {
			for i in 0 ..< items.count {
				if items[i].identifier == identifier {
					intendedIndexPath.item = i
					found = true
					break
				}
			}
		}
		
		if found == true {
			guard intendedIndexPath.section < collectionView.numberOfSections else { return }
			guard intendedIndexPath.item < collectionView.numberOfItems(inSection: intendedIndexPath.section) else { return }
			
			collectionView(collectionView, didSelectItemAt: intendedIndexPath)
		}
	}
	
	// MARK: - List View
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let source = source {
			let sortedItems = source.sortedItems(tagIndex: self.currentFolderIndex)
			if indexPath.item < sortedItems.count {
				let item = sortedItems[indexPath.item]
				selectedIdentifier = item.identifier
				
				guard let detailViewController = documentViewController?.detailViewController else { return }
				detailViewController.source = source

				if UIDevice.current.userInterfaceIdiom == .phone || view.window?.traitCollection.horizontalSizeClass == .compact {
					navigationController?.pushViewController(detailViewController, animated: true)
				}
			}
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		cell.selectedBackgroundView = nil
	}
	
	// MARK: - Contextual Menus
	
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { elementArray -> UIMenu? in
			return self.contextMenuForIndexPath(indexPath: indexPath)
		}
		
		return config
	}
	
	func contextMenuForIndexPath(indexPath:IndexPath) -> UIMenu {
		let symcfg = UIImage.SymbolConfiguration(pointSize: UIFloat(18), weight: .bold)
		
		var deleteActionsCommand = Array<UIAction>()
		
		do {
			let action = UIAction(title: NSLocalizedString("CONTEXT_DELETE", comment:""), image: UIImage(systemName: "trash.fill", withConfiguration: symcfg), identifier: nil) { (UIAction) in
				
				if let source = self.source {
					if let sortedItems = self.source?.sortedItems(tagIndex: self.currentFolderIndex) {
						
						if indexPath.item < sortedItems.count {
							let item = sortedItems[(indexPath.item)]
							let identifier = item.identifier
							
							source.removeItem(withIdentifier: identifier)
						}
					}
				}
				
			}
			action.attributes = .destructive
			deleteActionsCommand.append(action)
		}
		
		
		let deleteMenu = UIMenu(title: "", image: nil, identifier: UIMenu.Identifier(rawValue: "SIDEBAR_DELETE"), options: .displayInline, children: deleteActionsCommand)
		
		return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [deleteMenu])
	}
	
	// MARK: - Keyboard Focus
	
	override func collectionView(_ collectionView: UICollectionView, selectionFollowsFocusForItemAt indexPath: IndexPath) -> Bool {
		return UIDevice.current.userInterfaceIdiom == .mac || view.window?.traitCollection.horizontalSizeClass == .regular
	}
}

extension CATItemListViewController: UISearchResultsUpdating, UISearchControllerDelegate {
	func updateSearchResults(for searchController: UISearchController) {
		if let source = self.source {
			source.searchString = searchController.searchBar.text ?? ""
		}
	}
}
