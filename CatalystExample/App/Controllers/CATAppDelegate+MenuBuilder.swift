/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit

extension CATAppDelegate {
	override func buildMenu(with builder: UIMenuBuilder) {
		
		builder.remove(menu: .format)
		
		do {
			let command = UIKeyCommand(input: "N", modifierFlags: [.command, .alternate], action: NSSelectorFromString("newItem:"))
			
			command.title = NSLocalizedString("MENU_ITEM_NEW_ITEM", comment: "")
			
			let menu = UIMenu(title: NSLocalizedString("MENU_ITEM", comment: ""), image: nil, identifier: UIMenu.Identifier("MENU_ITEM"), options: [], children: [command])
			builder.insertSibling(menu, afterMenu: .edit)
		}

		super.buildMenu(with: builder)
	}

}
