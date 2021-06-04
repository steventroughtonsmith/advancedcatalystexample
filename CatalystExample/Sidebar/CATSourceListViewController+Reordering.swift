/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit

extension CATSourceListViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
	
	func shouldMoveItemAt(indexPath: IndexPath) -> Bool {
		
		if indexPath.isEmpty {
			return false
		}
		
		if indexPath.section == 1 && indexPath.item > 0 {
			return true
		}
		
		return false
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return shouldMoveItemAt(indexPath: indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		
		if shouldMoveItemAt(indexPath: indexPath) == false {
			return []
		}
		
		if let folders = source?.dataStore.folders {
			let folder = folders[(indexPath.item - 1)]
			let context = CATElementWrapper(element: folder)
			
			let provider = NSItemProvider(object: context)
			let item = UIDragItem(itemProvider: provider)
			
			session.localContext = context
			return [item]
		}
		
		return []
	}
	
	func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
		return (session.localDragSession?.localContext != nil)
	}
	
	
	func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
		
		if let destinationIndexPath = destinationIndexPath {
			if !shouldMoveItemAt(indexPath: destinationIndexPath) {
				return UICollectionViewDropProposal(operation:.cancel, intent: .unspecified)
			}
		}
		
		if session.localDragSession?.localContext != nil {
			
			if let wrapper = session.localDragSession?.localContext as? CATElementWrapper {
				
				if let _ = wrapper.element as? CATFolder {
					
				}
				else if let _ = wrapper.element as? CATItem {
					return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
				}
			}
		}
		
		return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
	}
	
	override func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
		
		if proposedIndexPath.isEmpty {
			return proposedIndexPath
		}
		
		if proposedIndexPath.section < 1 {
			return IndexPath(item: 1, section: 1)
		}
		
		if proposedIndexPath.item < 1 {
			return IndexPath(item: 1, section: proposedIndexPath.section)
		}
		
		return proposedIndexPath
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let sourceIndex = UInt(sourceIndexPath.item - 1)
		let destinationIndex = UInt(destinationIndexPath.item - 1)
		
		if let source = source {
			source.reorderFolder(at:sourceIndex, to: destinationIndex)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
		
		switch coordinator.proposal.operation {
		case .move:
			
			for _ in coordinator.session.items {
				if let wrapper = coordinator.session.localDragSession?.localContext as? CATElementWrapper {
					if let _ = wrapper.element as? CATFolder {
						for dropItem in coordinator.items {
							if let sourceIndexPath = dropItem.sourceIndexPath, let destination = coordinator.destinationIndexPath {
								
								let sourceIndex = UInt(sourceIndexPath.item - 1)
								let destinationIndex = UInt(destination.item - 1)
								
								if sourceIndex != destinationIndex && destination.section == 1 {
									
									
									if let source = source {
										source.reorderFolder(at:sourceIndex, to: destinationIndex)
									}
									
									coordinator.drop(dropItem.dragItem, toItemAt: destination)
								}
							}
						}
					}
				}
			}
		default:
			for dropItem in coordinator.items {
				if let sourceIndexPath = dropItem.sourceIndexPath {
					coordinator.drop(dropItem.dragItem, toItemAt: sourceIndexPath)
				}
			}
			break
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
		reload()
	}
	
	func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession) {
		
	}
}
