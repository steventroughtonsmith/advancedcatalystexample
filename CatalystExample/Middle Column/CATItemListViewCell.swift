/*
	2021 Steven Troughton-Smith (@stroughtonsmith)
	Provided as sample code to do with as you wish.
	No license or attribution required.
*/

import UIKit

class CATItemListViewCell: UICollectionViewListCell {
	
	var inactive = false
	
	var titleLabel = UILabel()
	var bodyLabel = UILabel()
	
	var modifiedLabel = UILabel()
	
	var stateAreaWidth = CGFloat.zero
	
	override var isSelected: Bool {
		didSet {
			recolor()
		}
	}
	
	override var isHighlighted: Bool {
		didSet {
			recolor()
		}
	}
	
	var closed: Bool = false {
		didSet {
			recolor()
		}
	}
	
	@objc func _focusRingType() -> UInt
	{
		return 1;
	}
	
	override func prepareForReuse() {
		isSelected = false
		isHighlighted = false
		
	}
	
	func recolor() {
		
		if (isSelected || isHighlighted) && !inactive {
			titleLabel.textColor = .white
			bodyLabel.textColor = .white
			modifiedLabel.textColor = .white
		}
		else {
			titleLabel.textColor = closed ? .secondaryLabel : .label
			bodyLabel.textColor = .secondaryLabel
			modifiedLabel.textColor = .secondaryLabel
		}
		if inactive {
			selectedBackgroundView?.backgroundColor = .systemFill
		}
		else {
			selectedBackgroundView?.backgroundColor = tintColor
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		selectedBackgroundView = UIView()
		selectedBackgroundView?.layer.cornerRadius = UIFloat(8)
		selectedBackgroundView?.backgroundColor = tintColor
		
		titleLabel.font = UIFont.boldSystemFont(ofSize: UIFloat(18))
		bodyLabel.font = UIFont.systemFont(ofSize: UIFloat(16))
		
		modifiedLabel.font = UIFont.systemFont(ofSize: UIFloat(15))
		
		modifiedLabel.textAlignment = .right
		
		stateAreaWidth = ("31/12/2021" as NSString).size(withAttributes: [.font : UIFont.systemFont(ofSize: UIFloat(15))]).width + UIFloat(13)
		
		recolor()
		
		contentView.addSubview(titleLabel)
		contentView.addSubview(bodyLabel)
		contentView.addSubview(modifiedLabel)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: -
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let padding = UIFloat(13)
		let insetFrame =  bounds.insetBy(dx: padding, dy: 0)
		
		contentView.frame = insetFrame.insetBy(dx: padding, dy: 0)
		selectedBackgroundView?.frame = insetFrame
		
		/* */
		
		let contentRegion = contentView.bounds.divided(atDistance: stateAreaWidth, from: .maxXEdge)
		let rightRegion = contentRegion.slice.inset(by: UIEdgeInsets(top: padding, left: 0, bottom: padding, right: 0))
		let leftRegion = contentRegion.remainder.inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: 0))
		
		let leftLabelRegion = leftRegion.divided(atDistance: leftRegion.height/2, from: .minYEdge)
		let rightLabelRegion = rightRegion.divided(atDistance: rightRegion.height/2, from: .minYEdge)
		
		titleLabel.frame = leftLabelRegion.slice
		bodyLabel.frame = leftLabelRegion.remainder
		
		modifiedLabel.frame = rightLabelRegion.slice
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		inactive = (traitCollection.activeAppearance == .inactive)
		recolor()
	}
}
