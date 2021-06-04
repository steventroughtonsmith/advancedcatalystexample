/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import Foundation

class CATItem: CATElement, ObservableObject {

	var title = NSLocalizedString("ITEM_TITLE_UNTITLED", comment: "")
	var body = "Lorem ipsum dolor sit amet"
	var created = Date()

	override init() {
		super.init()
	}
	
	// MARK: - Codable

	required init(from decoder: Decoder) throws {
		super.init()

		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		identifier = try container.decode(String.self, forKey: .identifier)
		title = (try? container.decode(String.self, forKey: .title)) ?? NSLocalizedString("ITEM_TITLE_UNTITLED", comment: "")
		body = (try? container.decode(String.self, forKey: .body)) ?? ""
		
		created = (try? container.decode(Date.self, forKey: .created)) ?? Date()
	}
	
	override func encode(to encoder: Encoder) throws {
		
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(identifier, forKey: .identifier)
		try container.encode(title, forKey: .title)
		try container.encode(body, forKey: .body)

		try container.encode(created, forKey: .created)
	}
	
	enum CodingKeys: String, CodingKey {
		case identifier
		case title
		case body

		case created
	}
	
	// MARK: - Search

	func search(searchString:String) -> Bool {
		
		let searchString = searchString.lowercased()

		if title.lowercased().contains(searchString) || body.lowercased().contains(searchString) {
			return true
		}
		
		return false
	}
	
	// MARK: - Hashable
	
	static func == (lhs: CATItem, rhs: CATItem) -> Bool {
		if (lhs.identifier == rhs.identifier) && (lhs.title == rhs.title) && (rhs.body == lhs.body) && (rhs.created == lhs.created) {
			return true
		}
		
		return false
	}
}
