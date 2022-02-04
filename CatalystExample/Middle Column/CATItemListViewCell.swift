/*
 2021 Steven Troughton-Smith (@stroughtonsmith)
 Provided as sample code to do with as you wish.
 No license or attribution required.
 */

import UIKit

class CATItemListViewCell: UICollectionViewCell {
	
	var inactive = false
	
	var titleLabel = UILabel()
	var bodyLabel = UILabel()
	
	var modifiedLabel = UILabel()
	
	var stateAreaWidth = CGFloat.zero
	
	let focusRingView = UIView()
	let selectionRingView = UIView()

	override var isSelected: Bool {
		didSet {
			if isSelected == true {
				selectionRingView.alpha = 1
			}
			else {
				selectionRingView.alpha = 0
			}

			recolor()
		}
	}

	override var isHighlighted: Bool {
		didSet {
			recolor()
		}
	}
	
	var showFocusRing: Bool = false {
		didSet {
			focusRingView.isHidden = !showFocusRing

			recolor()
		}
	}

	// MARK: -
	
	
	override func prepareForReuse() {
		isSelected = false
		isHighlighted = false
		showFocusRing = false
	}
	
	func recolor() {
		
		var showWhiteLabels = false
		
		if (isSelected && !inactive) || showFocusRing {
			showWhiteLabels = true
		}
		
		if (!showFocusRing && isSelected) || isHighlighted {
			showWhiteLabels = false
		}
		
		if showWhiteLabels == true {
			titleLabel.textColor = .white
			bodyLabel.textColor = .white
			modifiedLabel.textColor = .white
		}
		else {
			titleLabel.textColor = .label
			bodyLabel.textColor = .secondaryLabel
			modifiedLabel.textColor = .secondaryLabel
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		focusRingView.layer.cornerRadius = UIFloat(8)
		focusRingView.layer.cornerCurve = .continuous
		
		selectionRingView.layer.cornerRadius = UIFloat(8)
		selectionRingView.layer.cornerCurve = .continuous
		
		titleLabel.font = UIFont.boldSystemFont(ofSize: UIFloat(18))
		bodyLabel.font = UIFont.systemFont(ofSize: UIFloat(16))
		
		modifiedLabel.font = UIFont.systemFont(ofSize: UIFloat(15))
		
		modifiedLabel.textAlignment = .right
		
		stateAreaWidth = ("31/12/2021" as NSString).size(withAttributes: [.font : UIFont.systemFont(ofSize: UIFloat(15))]).width + UIFloat(13)
		
		recolor()
		
		selectionRingView.alpha = 0
		selectionRingView.backgroundColor = .systemFill
		addSubview(selectionRingView)
		
		focusRingView.isHidden = true
		focusRingView.backgroundColor = tintColor
		addSubview(focusRingView)
		
		contentView.addSubview(titleLabel)
		contentView.addSubview(bodyLabel)
		contentView.addSubview(modifiedLabel)

		if #available(macCatalyst 15.0, iOS 15.0, *) {
			focusEffect = nil
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: -
	
	override func layoutSubviews() {
								
		let padding = UIFloat(13)
		let insetFrame =  bounds.insetBy(dx: padding, dy: 0)
		
		contentView.frame = insetFrame.insetBy(dx: padding, dy: 0)

		selectionRingView.frame = bounds.insetBy(dx: padding, dy: 0)
		focusRingView.frame = selectionRingView.frame
		
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
	
	// MARK: - Keyboard Focus
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		
		super.didUpdateFocus(in: context, with: coordinator)
		
		if context.nextFocusedItem === self {
			showFocusRing = true
		}
		else if context.previouslyFocusedItem === self {
			showFocusRing = false
		}
	}
}
