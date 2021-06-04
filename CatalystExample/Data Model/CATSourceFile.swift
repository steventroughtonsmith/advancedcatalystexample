/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit

extension Notification.Name {
	static let documentChanged = NSNotification.Name("CATSourceFile.modified")
}

class CATDataStore: Codable {
	
	var items = Array<CATItem>()
	var folders = Array<CATFolder>()
		
	init() {
		
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		items = (try? container.decode(Array<CATItem>.self, forKey: .items)) ?? Array()
		folders = (try? container.decode(Array<CATFolder>.self, forKey: .folders)) ?? Array()
	}
	
	func encode(to encoder: Encoder) throws {
		
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(items, forKey: .items)
		try container.encode(folders, forKey: .folders)
	}
	
	enum CodingKeys: String, CodingKey {
		case items
		case folders
	}
}

class CATSourceFile {
	
	var dataStore = CATDataStore()
	
	var searchString = "" {
		didSet {
			changed()
		}
	}
	
	static let CATFolderIndexAll = -1
	static let CATFolderIndexRecents = -2
	
	// MARK: - Load & Save the data store
	
	convenience init(url: URL) {
		self.init()
		
		do {
			let data = try Data(contentsOf: url)
			try load(fromData: data)
		}
		catch {
			NSLog("[LOAD] Error: \(error.localizedDescription)")
		}
		
	}
	
	func load(fromData data: Data) throws {
		let decoder = JSONDecoder()
		
		do {
			let decodedDataStore = try decoder.decode(CATDataStore.self, from: data)
			dataStore = decodedDataStore
			
			print("[ARCHIVE] Opened successfully")
			
		} catch {
			print("[ARCHIVE] Fatal: \(error.localizedDescription)")
		}
	}
	
	func save(to url: URL, completionHandler: ((Bool) -> Void)? = nil) {
		
		let _ = url.startAccessingSecurityScopedResource()
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		let jsonData = try! encoder.encode(dataStore)
		
		do {
			try jsonData.write(to: url, options: .atomic)
			
			if let completionHandler = completionHandler {
				completionHandler(true)
			}
		}
		catch {
			print("[ARCHIVE] Error \(error)")
			
			if let completionHandler = completionHandler {
				completionHandler(false)
			}
		}
	}
}

extension CATSourceFile {
	// MARK: - Managing the data store
	
	func add(item:CATItem) {
		dataStore.items.append(item)
		
		changed()
	}
	
	func removeItem(withIdentifier:String) {
		dataStore.items.removeAll { potentialItem in
			return (potentialItem.identifier == withIdentifier)
		}
		
		changed()
	}
	
	func reorderFolder(at:UInt, to:UInt) {
		
		let target = dataStore.folders[Int(at)]
		dataStore.folders.remove(at: Int(at))
		dataStore.folders.insert(target, at: Int(to))
		
		changed()
	}
	
	// MARK: - Change Notifications
	
	func changed() {
		NotificationCenter.default.post(name: .documentChanged, object: nil)
	}
	
	// MARK: - Sorted Accessor
	
	func sortedItems(tagIndex:Int) -> Array<CATItem> {
		var itemsSorted = [CATItem]()
		
		if tagIndex >= dataStore.folders.count {
			return itemsSorted
		}
		
		if tagIndex == CATSourceFile.CATFolderIndexAll {
			
			for item in dataStore.items {
				
				if searchString != "" {
					if item.search(searchString: searchString) == false {
						continue
					}
				}
				
				itemsSorted.append(item)
			}
		}
		else if tagIndex == CATSourceFile.CATFolderIndexRecents {
			
			let oneDay = TimeInterval(60 * 60 * 24)
			
			for item in dataStore.items {
				if Date.timeIntervalSinceReferenceDate - item.created.timeIntervalSinceReferenceDate < (oneDay * 3) {
					
					if searchString != "" {
						if (item.title.lowercased().contains(searchString.lowercased()) == false) && (item.body.lowercased().contains(searchString.lowercased()) == false) {
							continue
						}
					}
					
					itemsSorted.append(item)
				}
			}
		}
		else {
			
			
			let folder = dataStore.folders[tagIndex]
			
			for item in dataStore.items {
				if folder.itemIDs.contains(item.identifier)  {
					
					if searchString != "" {
						if (item.title.lowercased().contains(searchString.lowercased()) == false) && (item.body.lowercased().contains(searchString.lowercased()) == false) {
							continue
						}
					}
					
					itemsSorted.append(item)
				}
			}
		}
		
		itemsSorted.sort { A, B in
			return (A.created.compare(B.created) == .orderedDescending)
		}
		
		return itemsSorted
	}
}

