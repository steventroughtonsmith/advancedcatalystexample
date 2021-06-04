/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import Foundation

class CATPreferencesController {
	static let shared = CATPreferencesController()

	static let debugEnabledKey = "ISSDebugEnabled"

	var enableDebugFeatures:Bool = UserDefaults.standard.bool(forKey: debugEnabledKey)
}
