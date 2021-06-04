/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import Foundation
import MobileCoreServices

class CATElementWrapper: NSObject, NSItemProviderWriting {
	static var writableTypeIdentifiersForItemProvider: [String] { return ["public.string"] }

	var element:CATElement
	
	init(element:CATElement) {
		self.element = element
		super.init()
	}
	
	// MARK: -
	
	func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		let jsonData = try! encoder.encode(element)
		
		completionHandler(jsonData, nil)
		
		return nil
	}
	
}

class CATElement: Codable, Hashable {
	var identifier = UUID().uuidString

	init() {
		
	}
	
	// MARK: - Hashable
	
	static func == (lhs: CATElement, rhs: CATElement) -> Bool {
		if (lhs.identifier == rhs.identifier) {
			return true
		}
		
		return false
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(self)
	}
}
