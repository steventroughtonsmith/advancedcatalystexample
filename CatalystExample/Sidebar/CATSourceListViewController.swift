/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit

class CATSourceListViewController: UICollectionViewController {
	
	var listViewController:CATItemListViewController?
	var documentViewController:CATMainViewController?
	
	static let cellIdentifier = "Cell"
	var diffableDataSource:UICollectionViewDiffableDataSource<AnyHashable,AnyHashable>?

	var selectedIdentifier = "all"
	
	var source:CATSourceFile? {
		didSet {
			reload()
		}
	}
	
	init() {
		
		let layout = UICollectionViewCompositionalLayout() { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
			
			var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
			configuration.showsSeparators = false
			configuration.headerMode = .firstItemInSection
			
			let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
			
			return section
		}
		
		super.init(collectionViewLayout: layout)
		
		diffableDataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, ctx in
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CATSourceListViewController.cellIdentifier, for: indexPath)
			
			var content = UIListContentConfiguration.sidebarCell()
			content.textProperties.allowsDefaultTighteningForTruncation = false
			
			if indexPath.section == 0 {
				
				switch indexPath.row {
				case 0:
					content = UIListContentConfiguration.sidebarHeader()
					
					content.text = NSLocalizedString("SIDEBAR_TITLE_LIBRARY", comment:"")
				case 1:
					content.text = NSLocalizedString("SIDEBAR_ALL_ITEMS", comment:"")
					content.image = UIImage(systemName: "doc.text")
				case 2:
					content.text = NSLocalizedString("SIDEBAR_RECENTS", comment:"")
					content.image = UIImage(systemName: "clock")
				default:
					break
				}
				
				cell.contentConfiguration = content
			}
			else {
				if indexPath.row == 0 {

					content = UIListContentConfiguration.sidebarHeader()
					content.text = NSLocalizedString("SIDEBAR_TITLE_FOLDERS", comment:"")
				}
				else
				{
					if let folder = self.source?.dataStore.folders[(indexPath.item - 1)] {
						content.text = folder.title
						content.image = UIImage(systemName: "folder")
					}
				}
				
				cell.contentConfiguration = content
			}
			
			return cell
		})
		
		
		#if !targetEnvironment(macCatalyst)
		collectionView.backgroundColor = .systemGroupedBackground
		#endif
		
		collectionView.selectionFollowsFocus = true
		
		collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: CATSourceListViewController.cellIdentifier)

		collectionView.dataSource = diffableDataSource
		collectionView.delegate = self

		collectionView.dragInteractionEnabled = true
		collectionView.dragDelegate = self
		collectionView.dropDelegate = self
		
		navigationItem.largeTitleDisplayMode = .always
		
		NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		
		NotificationCenter.default.addObserver(forName: .documentChanged, object: nil, queue: nil) { [weak self] _ in
			DispatchQueue.main.async {
				self!.reload()
			}
		}
		
		title = NSLocalizedString("SOURCE_VIEW_TITLE", comment: "");
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		clearsSelectionOnViewWillAppear = false
	}
	
	// MARK: - Diffable Data Source
	
	func reload() {
		
		var snapshot = NSDiffableDataSourceSnapshot<AnyHashable,AnyHashable>()
		
		snapshot.appendSections(["library"])
		snapshot.appendItems(["library.header", "all", "recents"])
		
		if let folders = self.source?.dataStore.folders {
			snapshot.appendSections(["folders"])
			snapshot.appendItems(["folders.header"])
			snapshot.appendItems(folders)
			
			diffableDataSource?.apply(snapshot, animatingDifferences: false)
			{ [weak self] in
				self!.selectItemWithIdentifier(self!.selectedIdentifier)
			}
		}
	}
	
	func selectItemWithIdentifier(_ identifier:String) {
		
		var intendedIndexPath = IndexPath(item: 0, section: 0)
		var found = false
		
		
		if identifier == "all" {
			intendedIndexPath = IndexPath(item: 1, section: 0)
			found = true
		}
		else if identifier == "recents" {
			intendedIndexPath = IndexPath(item: 2, section: 0)
			found = true
		}
		
		if found == false {
			if let folders = self.source?.dataStore.folders {
				for i in 0 ..< folders.count {
					if folders[i].identifier == identifier {
						intendedIndexPath.item = (i + 1)
						intendedIndexPath.section = 1
						found = true
						break
					}
				}
			}
		}
		
		
		if found == true {
			collectionView.selectItem(at: intendedIndexPath, animated: false, scrollPosition: [])
		}
	}
	
	// MARK: - List View
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		if let listViewController = listViewController {
			
			if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
				if selectedIndexPath.section == 1 {
					if let folder = self.source?.dataStore.folders[(selectedIndexPath.item - 1)] {
						
						selectedIdentifier = folder.identifier
					}
				}
				else {
					if selectedIndexPath.item == 1 {
						selectedIdentifier = "all"
					}
					else if selectedIndexPath.item == 2 {
						selectedIdentifier = "recents"
					}
				}
			}
			
			if indexPath.section == 0 {
				if indexPath.item == 1 {
					listViewController.currentFolderIndex = CATSourceFile.CATFolderIndexAll
				}
				else {
					listViewController.currentFolderIndex = CATSourceFile.CATFolderIndexRecents
				}
			}
			else {
				listViewController.currentFolderIndex = (indexPath.item - 1)
			}
		}
		
		guard let listViewController = documentViewController?.listViewController else { return }

		if UIDevice.current.userInterfaceIdiom == .phone || view.window?.traitCollection.horizontalSizeClass == .compact {
			navigationController?.pushViewController(listViewController, animated: true)
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		if indexPath.item == 0 {
			return false
		}
		else {
			
			return true
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return (indexPath.item != 0)
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
}
