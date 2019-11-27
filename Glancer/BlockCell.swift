//
//  BlockCell.swift
//  Glancer
//
//  Created by Dylan Hanson on 7/25/18.
//  Copyright © 2018 Dylan Hanson. All rights reserved.
//

import Foundation
import UIKit
import AddictiveLib

class BlockCell: TableCell {
	
	private let controller: DayController
	private let composite: CompositeBlock
	
	init(controller: DayController, composite: CompositeBlock) {
		self.controller = controller
		self.composite = composite
		
		super.init("block", nib: "BlockCell")
		
		self.setEstimatedHeight(70)
		self.setSelectionStyle(.none)
		
		self.setCallback() {
			template, cell in
			
			if let blockCell = cell as? UIBlockCell {
				self.layout(cell: blockCell)
			}
		}
	}
	
//	Set name label to bold if there's a class or not
	
	private func layout(cell: UIBlockCell) {
		let analyst = self.composite.block.analyst
		let block = self.composite.block
		
//		Setup
		cell.nameLabel.text = analyst.displayName
//        cell.nameLabel.font = UIFont(name: "Comic Sans MS", size: CGFloat(20))
		cell.blockNameLabel.text = block.id.displayName
        cell.blockNameLabel.textColor = Scheme.calenderText.color
//        cell.blockNameLabel.font = UIFont(name: "Comic Sans MS", size: CGFloat(14))
		
		cell.fromLabel.text = block.schedule.start.prettyTime
        cell.fromLabel.textColor = Scheme.lightText.color
//        cell.fromLabel.font = UIFont(name: "Comic Sans MS", size: CGFloat(16))
		cell.toLabel.text = block.schedule.end.prettyTime
        cell.toLabel.textColor = Scheme.lightText.color
//        cell.toLabel.font = UIFont(name: "Comic Sans MS", size: CGFloat(16))
		
		cell.locationLabel.text = analyst.location
        cell.backgroundColor = Scheme.calenderAndBlocksBackground.color
		
//		Formatting
		var heavy = !analyst.courses.isEmpty
		if block.id == .lab, let before = self.composite.schedule.selectedTimetable!.getBlockBefore(block: block) {
			if !before.analyst.courses.isEmpty {
				heavy = true
			}
		}
		
		cell.nameLabel.font = UIFont.systemFont(ofSize: 22, weight: heavy ? .bold : .semibold)
		cell.nameLabel.textColor = analyst.color
		
		cell.tagIcon.image = cell.tagIcon.image!.withRenderingMode(.alwaysTemplate)
		cell.rightIcon.image = cell.rightIcon.image!.withRenderingMode(.alwaysTemplate)
		
//		Attachments
		for arranged in cell.attachmentsStack.arrangedSubviews { cell.attachmentsStack.removeArrangedSubview(arranged) ; arranged.removeFromSuperview() }
		
		if block.id == .lunch {
			if let menu = self.composite.lunch {
				let lunchView = LunchAttachmentView(menuName: menu.title)
				lunchView.clickHandler = {
					self.controller.openLunch(menu: menu)
				}
				cell.attachmentsStack.addArrangedSubview(lunchView)
			}
		}
		
		for event in composite.events {
			if !event.gradeRelevant {
				continue // Don't show if it's not relevant
			}
			
			let view = EventAttachmentView()
			view.text = event.oldCompleteTitle
			cell.attachmentsStack.addArrangedSubview(view)
		}
		
		cell.attachmentStackBottomConstraint.constant = cell.attachmentsStack.arrangedSubviews.count > 0 ? 10.0 : 0.0
	}
	
}

class UIBlockCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	
	@IBOutlet weak var tagIcon: UIImageView!
	@IBOutlet weak var blockNameLabel: UILabel!
	
	@IBOutlet weak var fromLabel: UILabel!
	@IBOutlet weak var rightIcon: UIImageView!
	@IBOutlet weak var toLabel: UILabel!
	
	@IBOutlet weak var attachmentsStack: UIStackView!
	@IBOutlet weak var attachmentStackBottomConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var locationLabel: UILabel!
	
}

extension UIView{
    func addGradientBackground(firstColor: UIColor, secondColor: UIColor){
        clipsToBounds = true
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        print(gradientLayer.frame)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
