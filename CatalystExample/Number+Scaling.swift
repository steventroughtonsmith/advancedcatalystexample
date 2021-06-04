/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

/*

	Number+Scaling

	This function lets you wrap all UI-facing metrics in UIFloat()
	so that they will scale appropriately for iOS and macOS idioms
	without you having to have multiple metrics

*/
import UIKit

public let supportsMacIdiom = !(UIDevice.current.userInterfaceIdiom == .pad)

@inlinable func UIFloat(_ value: CGFloat) -> CGFloat
{
	#if targetEnvironment(macCatalyst)
	return round((value == 0.5) ? 0.5 : value * (supportsMacIdiom ? 0.77 : 1.0))
	#else
	return value
	#endif
}
