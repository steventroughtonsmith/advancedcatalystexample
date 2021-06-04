/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import Foundation

func CATPrettyFormatDate(_ date:Date) -> String {
	return CATPrettyFormatDate(date, dateStyle: .long, timeStyle: .short)
}

func CATPrettyFormatDate(_ date:Date, dateStyle:DateFormatter.Style, timeStyle:DateFormatter.Style) -> String {
	let formatter = DateFormatter()

	formatter.locale = Locale.current
	formatter.dateStyle = dateStyle
	formatter.timeStyle = timeStyle

	return formatter.string(from: date)
}
