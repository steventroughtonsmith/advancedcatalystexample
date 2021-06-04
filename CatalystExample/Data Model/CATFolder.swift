/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import Foundation

class CATFolder: CATElement, ObservableObject {
	
	@Published var title = NSLocalizedString("FOLDER_UNTITLED", comment: "") 
	var itemIDs = Array<String>()

	override init() {
		super.init()
	}

	// MARK: - Codable

	required init(from decoder: Decoder) throws {
		super.init()

		let container = try decoder.container(keyedBy: CodingKeys.self)
	
		identifier = (try? container.decode(String.self, forKey: .identifier)) ?? UUID().uuidString
		title = (try? container.decode(String.self, forKey: .title)) ?? NSLocalizedString("FOLDER_UNTITLED", comment: "")
		itemIDs = (try? container.decode(Array<String>.self, forKey: .itemIDs)) ?? Array()
		
	}
	
	override func encode(to encoder: Encoder) throws {
		
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(identifier, forKey: .identifier)
		try container.encode(title, forKey: .title)
		try container.encode(itemIDs, forKey: .itemIDs)
	}
	
	enum CodingKeys: String, CodingKey {
		case identifier
		case title
		case itemIDs
	}
	
	// MARK: - Hashable
	
	static func == (lhs: CATFolder, rhs: CATFolder) -> Bool {
		if (lhs.identifier == rhs.identifier) && (lhs.title == rhs.title) && (rhs.itemIDs == lhs.itemIDs) {
			return true
		}
		
		return false
	}

}
