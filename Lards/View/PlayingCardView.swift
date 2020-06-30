//
//  PlayingCardView.swift
//  Lards
//
//  Created by Shane Lawson on 5/21/20.
//  Copyright © 2020 Shane Lawson. All rights reserved.
//

import UIKit

// UIView for PlayingCard where custom drawing is done for the card face and back, including appropriate weather icons for weather-based, custom card backs
class PlayingCardView: UIView {

   // MARK: Properties
   
   var rank: Rank = .two { didSet { setNeedsDisplay(); setNeedsLayout() } }
   var suit: Suit = .clubs { didSet { setNeedsDisplay(); setNeedsLayout() } }
   var isFaceUp: Bool = false { didSet { setNeedsDisplay(); setNeedsLayout() } }
   var height: CGFloat = 140 { didSet { bounds.size.width = (5/7) * bounds.size.height; setNeedsDisplay(); setNeedsLayout() } }
   var willGetWeather: Bool = false
   static var weather: WeatherObject? = nil
   
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
      
      //set border color and fill color
      UIColor.gray.setStroke()
      UIColor.white.setFill()
      
      path.stroke()
      path.fill()
      
      //draw card face or card back
      if isFaceUp {
         //card face is mainly drawn using other UI objects.
         //Face cards do not have custom artwork, and would stand out if non face cards had pips on them, so all cards only have corner labels
      } else {
         let backRect = CGRect(origin: bounds.origin.offsetBy(dx: cardBackBorderWidth, dy: cardBackBorderWidth), size: CGSize(width: bounds.width - 2*cardBackBorderWidth, height: bounds.height - 2*cardBackBorderWidth))
         let path = UIBezierPath(rect: backRect)
         LardsUserDefaults.tintColor.setFill()
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
      
      if willGetWeather {
         configureWeatherIcon(weatherIcon)
         
         //position weather icon on card back
         weatherIcon.center = CGPoint(x: bounds.midX, y: bounds.midY)
      }
   }
   
   func startAnimatingWeatherIcon() {
      let rotation = CABasicAnimation(keyPath: "transform.rotation")
      rotation.fromValue = 0
      rotation.toValue = 2 * Double.pi
      rotation.duration = 1.5
      rotation.repeatCount = 30/1.5
      weatherIcon.layer.add(rotation, forKey: "spin")
      
      //TODO: change animation so that it fades out if never receives weather object
   }
   
   func stopAnimatingWeatherIcon() {
      weatherIcon.layer.removeAllAnimations()
      if PlayingCardView.weather == nil {
         UIView.transition(with: weatherIcon, duration: 1, options: [.transitionCrossDissolve], animations: { self.weatherIcon.alpha = 0 })
      }
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
      var image: UIImage? = UIImage(systemName: "sun.max")
      if let weather = PlayingCardView.weather {
         switch weather.id {
         case 200, 201, 202, 230, 231, 232:
            image = UIImage(systemName: "cloud.bolt.rain")!
         case 211, 212:
            image = UIImage(systemName: "cloud.bolt")!
         case 210, 221:
            image = UIImage(systemName: weather.isDay ? "cloud.sun.bolt" : "cloud.moon.bolt")!
         case 300, 301, 302, 310, 311, 312:
            image = UIImage(systemName: "cloud.drizzle")!
         case 500, 501, 520, 521:
            image = UIImage(systemName: "cloud.rain")!
         case 502, 503, 504, 522:
            image = UIImage(systemName: "cloud.heavyrain")!
         case 531:
            image = UIImage(systemName: weather.isDay ? "cloud.sun.rain" : "cloud.moon.rain")!
         case 511, 611, 612, 613, 615, 616:
            image = UIImage(systemName: "cloud.sleet")!
         case 600, 601, 602, 620, 621, 622:
            image = UIImage(systemName: "cloud.snow")!
         case 711, 721:
            image = UIImage(systemName: "sun.haze")!
         case 731, 751, 761, 762:
            image = UIImage(systemName: "sun.dust")!
         case 701, 741:
            image = UIImage(systemName: "cloud.fog")!
         case 771:
            image = UIImage(systemName: "wind")!
         case 781:
            image = UIImage(systemName: "tornado")!
         case 800:
            image = UIImage(systemName: weather.isDay ? "sun.max" : "moon.stars")!
         case 801, 802:
            image = UIImage(systemName: weather.isDay ? "cloud.sun" : "cloud.moon")!
         case 803, 804:
            image = UIImage(systemName: "cloud")!
         default:
            image = UIImage(systemName: weather.isDay ? "sun.max" : "moon")!
         }
         
         stopAnimatingWeatherIcon()
      } else {
         startAnimatingWeatherIcon()
      }
      UIView.transition(with: self, duration: 0.5, options: [.transitionCrossDissolve], animations: {
         imageView.image = image?.withTintColor(.white, renderingMode: .alwaysOriginal)
      })
      imageView.frame.size = cardBackIconSize
      imageView.isHidden = isFaceUp
   }

   func refresh(_ weather: WeatherObject?) {
      PlayingCardView.weather = weather
      setNeedsDisplay()
      setNeedsLayout()
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

// MARK: - Animations

extension PlayingCardView {
   func move(to endPoint: CGPoint, duration: TimeInterval = 1, delay: TimeInterval = 0, options: UIView.AnimationOptions = [.curveEaseInOut], completion: ((Bool) -> Void)? = nil) {
      DispatchQueue.main.async {
         UIView.animate(
            withDuration: duration,
            delay: delay,
            options: options,
            animations: {
               self.center = endPoint
               self.isFaceUp = !self.isFaceUp
         }, completion: completion)
      }
   }
}

// MARK: - Extensions

extension CGPoint {
   func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
      return CGPoint(x: x+dx, y: y+dy)
   }
}
