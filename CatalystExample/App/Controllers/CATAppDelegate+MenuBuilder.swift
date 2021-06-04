/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit

extension CATAppDelegate {
	override func buildMenu(with builder: UIMenuBuilder) {
		
		builder.remove(menu: .format)

		super.buildMenu(with: builder)
	}

}
