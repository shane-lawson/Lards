//
//  PlayingCardView.swift
//  Lards
//
//  Created by Shane Lawson on 5/21/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {

   // MARK: Properties
   
   var rank: Rank = .two { didSet { setNeedsDisplay(); setNeedsLayout() } }
   var suit: Suit = .clubs { didSet { setNeedsDisplay(); setNeedsLayout() } }
   var isFaceUp: Bool = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
   
   // MARK: Computed Properties
   
   private var color: UIColor {
      switch suit {
      case .hearts, .diamonds:
         return .systemRed
      default:
         return .black
      }
   }
   
   private var cornerString: String {
      return rank.string + "\n" + suit.string
   }
   
   private lazy var upperLeftCornerLabel = createLabel()
   private lazy var lowerRightCornerLabel = createLabel()
   private lazy var weatherIcon = createWeatherIcon()
   
   // MARK: Overrides

   override func draw(_ rect: CGRect) {
      //set path of card
      let path = UIBezierPath(roundedRect: bounds.inset(by: UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)), cornerRadius: cornerRadius)
      
      //set border and fill colors or shaded card "shape" if none
      if rank == Rank.none {
         UIColor.black.withAlphaComponent(0.15).setFill()
         path.stroke()
         path.fill()
         return
      } else {
         UIColor.gray.setStroke()
         UIColor.white.setFill()
      }
      
      path.stroke()
      path.fill()
      
      //draw card face or card back
      if isFaceUp {
         //TODO: draw card face
      } else {
         //TODO: draw card back
         let backRect = CGRect(origin: bounds.origin.offsetBy(dx: cardBackBorderWidth, dy: cardBackBorderWidth), size: CGSize(width: bounds.width - 2*cardBackBorderWidth, height: bounds.height - 2*cardBackBorderWidth))
         let path = UIBezierPath(rect: backRect)
         UIColor.systemTeal.setFill()
         path.fill()
      }
   }
   
   override func layoutSubviews() {
      super.layoutSubviews()
      
      configureCornerLabel(upperLeftCornerLabel)
      configureCornerLabel(lowerRightCornerLabel)
      
      //position corner labels appropriately
      upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
      
      lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
         .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
         .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
      lowerRightCornerLabel.transform = CGAffineTransform(rotationAngle: .pi)
      
      configureWeatherIcon(weatherIcon)
      
      //position weather icon on card back
      weatherIcon.center = CGPoint(x: bounds.midX, y: bounds.midY)
   }
   
   // MARK: Helpers
   
   private func createLabel() -> UILabel {
      let label = UILabel()
      label.numberOfLines = 0
      addSubview(label)
      return label
   }
   
   private func configureCornerLabel(_ label: UILabel) {
      label.text = self.cornerString
      configureLabel(label)
   }
   
   private func configurePipLabel(_ label: UILabel) {
      label.text = suit.string
      configureLabel(label)
   }
   
   private func configureLabel(_ label: UILabel) {
      label.frame.size = CGSize.zero
      label.sizeToFit()
      label.isHidden = !isFaceUp
      label.textColor = self.color
   }
   
   private func createWeatherIcon() -> UIImageView {
      let imageView = UIImageView()
      imageView.contentMode = .scaleAspectFit
      addSubview(imageView)
      return imageView
   }
   
   private func configureWeatherIcon(_ imageView: UIImageView) {
      //TODO: Set icon based on weather
//      imageView.image = self.image
      let image = UIImage(systemName: "cloud.sun")
      imageView.image = image!.withTintColor(.white, renderingMode: .alwaysOriginal)
      imageView.frame.size = cardBackIconSize
      imageView.isHidden = isFaceUp || rank == Rank.none
   }
}
   
// MARK: - Constants

extension PlayingCardView {
   
   private static let pipLayout = [
      [0,0,0],
      [0,1,0],
      [0,1,0,1,0],
      [0,1,1,1,0],
      [0,2,0,2,0],
      [0,2,1,2,0],
      [0,2,2,2,0],
      [0,2,3,2,0],
      [0,3,2,3,0],
      [0,1,2,3,2,1,0],
      [0,2,3,3,2,0]
   ]
   
   //some of these constants and structure come from the Stanford course "Designing iOS 11 Apps with Swift" taught by Paul Hegarty and available online
   private struct SizeRatio {
      static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
      static let pipFontSizeToBoundsHeight: CGFloat = 0.15
      static let corderRadiusToBoundsHeight: CGFloat = 0.06
      static let cornerOffsetToCornerRadius: CGFloat = 0.45
      static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
      static let cardBackIconSizeToBoundsSize: CGFloat = 0.75
   }
   
   private var cornerFontSize: CGFloat {
      return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
   }
   
   private var pipFontSize: CGFloat {
      return bounds.size.height * SizeRatio.pipFontSizeToBoundsHeight
   }
   
   private var cornerRadius: CGFloat {
      return bounds.size.height * SizeRatio.corderRadiusToBoundsHeight
   }
   
   private var cornerOffset: CGFloat {
      return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
   }
   
   private var cardBackIconSize: CGSize {
      return CGSize(width: bounds.size.width * SizeRatio.cardBackIconSizeToBoundsSize, height: bounds.size.width * SizeRatio.cardBackIconSizeToBoundsSize)
   }
   
   private var cardBackBorderWidth: CGFloat {
      return cornerRadius / 1.5
   }
}

// MARK: - Extensions

extension CGPoint {
   func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
      return CGPoint(x: x+dx, y: y+dy)
   }
}
