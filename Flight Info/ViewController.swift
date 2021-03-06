/*
* Copyright (c) 2014-2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import QuartzCore

// A delay function
func delay(seconds: Double, completion: @escaping ()-> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

class ViewController: UIViewController {
    
  // Enum Animation
  enum AnimationDirection: Int {
    case positive = 1
    case negative = -1
  }
  
  @IBOutlet var bgImageView: UIImageView!
  
  @IBOutlet var summaryIcon: UIImageView!
  @IBOutlet var summary: UILabel!
  
  @IBOutlet var flightNr: UILabel!
  @IBOutlet var gateNr: UILabel!
  @IBOutlet var departingFrom: UILabel!
  @IBOutlet var arrivingTo: UILabel!
  @IBOutlet var planeImage: UIImageView!
  
  @IBOutlet var flightStatus: UILabel!
  @IBOutlet var statusBanner: UIImageView!
  
  var snowView: SnowView!
  
  //MARK: view controller methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //adjust ui
    summary.addSubview(summaryIcon)
    summaryIcon.center.y = summary.frame.size.height/2
    
    //add the snow effect layer
    snowView = SnowView(frame: CGRect(x: -150, y:-100, width: 300, height: 50))
    let snowClipView = UIView(frame: view.frame.offsetBy(dx: 0, dy: 50))
    snowClipView.clipsToBounds = true
    snowClipView.addSubview(snowView)
    view.addSubview(snowClipView)
    
    //start rotating the flights
    changeFlight(to: londonToParis)
  }
  
  //MARK: custom methods
    func changeFlight(to data: FlightData, animated: Bool = false) {
    // populate the UI with the next flight's data
    summary.text = data.summary
    departingFrom.text = data.departingFrom
    arrivingTo.text = data.arrivingTo
    flightStatus.text = data.flightStatus
    if animated {
        fade(imageView: bgImageView, toImage: UIImage(named: data.weatherImageName)!, showEffects: data.showWeatherEffects)
        let direction = data.isTakingOff ? AnimationDirection.positive : AnimationDirection.negative
        // Apply cube transitions
        cubeTransition(label: flightNr, text: data.flightNr, direction: direction)
        cubeTransition(label: gateNr, text: data.gateNr, direction: direction)
        //cubeTransition(label: flightStatus, text: data.flightStatus, direction: .positive)
        _cubeTransition(label: flightStatus, text: data.flightStatus)
        // Departure and Arrive labels animation
        let offsetDeparting = CGPoint(x: CGFloat(direction.rawValue * 80), y: 0.0)
        let offsetArriving = CGPoint(x: CGFloat(direction.rawValue * 50), y: 0.0)
        labelTransition(label: departingFrom, text: data.departingFrom, offset: offsetDeparting)
        labelTransition(label: arrivingTo, text: data.arrivingTo, offset: offsetArriving)
        
    } else {
        bgImageView.image = UIImage(named: data.weatherImageName)
        snowView.isHidden = !data.showWeatherEffects
        flightNr.text = data.flightNr
        gateNr.text = data.gateNr
    }
    bgImageView.image = UIImage(named: data.weatherImageName)
    snowView.isHidden = !data.showWeatherEffects
    
    // schedule next flight
    delay(seconds: 3.0) {
      self.changeFlight(to: data.isTakingOff ? parisToRome : londonToParis, animated: true)
    }
  }
    
    func fade(imageView: UIImageView, toImage: UIImage, showEffects:Bool) {
        // ImageView fade out
        UIView.transition(with: imageView, duration: 1, options: .transitionCrossDissolve, animations: {
            imageView.image = toImage
        }, completion: nil)
        
        // Snow animation
        UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseOut, animations: {
            self.snowView.alpha = showEffects ? 1 : 0
        }, completion: nil)
    }
    
    // Cube transition for flight and gate numbers
    func cubeTransition(label: UILabel, text: String, direction: AnimationDirection) {
        // Crate aux label
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.backgroundColor = label.backgroundColor
        
        // Offset
        let auxLabelOffset = CGFloat(direction.rawValue) * label.frame.size.height / 2
        
        // Transformation Y scale
        auxLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1).concatenating(CGAffineTransform(translationX: 0, y: auxLabelOffset))
        
        // Put auxLabel at same level as label passed as argument
        label.superview?.addSubview(auxLabel)
        
        // Animations
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            auxLabel.transform = .identity
            label.transform = CGAffineTransform(scaleX: 1, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: -auxLabelOffset))
        }) { _ in
            label.text = text
            label.transform = .identity
            
            auxLabel.removeFromSuperview()
        }
    }
    
    // Label transition
    func labelTransition(label: UILabel, text: String, offset: CGPoint) {
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.backgroundColor = UIColor.clear
        auxLabel.textColor = label.textColor
        
        // Transform
        auxLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1).concatenating(CGAffineTransform(translationX: offset.x, y: offset.y))
        auxLabel.alpha = 0
        view.addSubview(auxLabel)
        
        // Cresting a ghost effect giving a delay between animations
        // To change if needed
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            label.transform = CGAffineTransform(translationX: offset.x, y: offset.y)
            label.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseIn, animations: {
            auxLabel.transform = .identity
            auxLabel.alpha = 1.0
        }) { _ in
            // Back to the begin
            auxLabel.alpha = 0.0
            auxLabel.removeFromSuperview()
            label.text = text
            label.transform = .identity
            label.alpha = 1.0
        }
    }
    
    fileprivate func _cubeTransition(label: UILabel, text: String) {
        // Cretae aux label
        let auxLabel = UILabel(frame: label.frame)
        auxLabel.text = text
        auxLabel.font = label.font
        auxLabel.textAlignment = label.textAlignment
        auxLabel.textColor = label.textColor
        auxLabel.backgroundColor = label.backgroundColor
        
        let offset = label.frame.size.height / 2 * -1
        
        // Transform auxLabel and position label as subview
        auxLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1).concatenating(CGAffineTransform(translationX: 0.0, y: offset))
        auxLabel.alpha = 0
        self.view.addSubview(auxLabel)
        
        // Animation
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            label.transform = CGAffineTransform(scaleX: 1, y: 0.1).concatenating(CGAffineTransform(translationX: 0, y: -1 * offset))
            auxLabel.alpha = 1
            auxLabel.transform = .identity
        }) { _ in
            label.text = text
            label.transform = .identity
            auxLabel.removeFromSuperview()
        }
        
        
    }
}









