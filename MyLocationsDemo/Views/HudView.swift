//
//  HudView.swift
//  MyLocationsDemo
//
//  Created by Abdallah on 9/9/19.
//  Copyright © 2019 Abdallah Eldesoky. All rights reserved.
//

import UIKit


class HudView: UIView {
    
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.isUserInteractionEnabled = false
        
        view.addSubview(hudView)
        hudView.show(animated: true)
        
        return hudView
    }
    
    
    override func draw(_ rect: CGRect) {
        
        
        let hudWidth: CGFloat = 96
        let hudHeight: CGFloat = 96
        
        let hudRect = CGRect(x: round((bounds.size.width - hudWidth) / 2), y: round((bounds.size.height - hudHeight) / 2), width: hudWidth, height: hudHeight)
        
        let roundedHud = UIBezierPath(roundedRect: hudRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedHud.fill()
        
        let attribs = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.white ]
        //let textSize = text.size(withAttributes: attribs)
        let textPoint = CGPoint(
            x: round(hudRect.midX - 3 * CGFloat(text.count)),
            y: round(hudRect.midY) - 20)
        text.draw(at: textPoint, withAttributes: attribs)
        
    }
    
    
    func show(animated: Bool) {
        
        if animated {
            
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
        
        after(delay: 0.6) {
            self.hide()
        }
    }
    
    func hide() {
        
        alpha = 1
        transform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (flag) in
            if flag {
                self.superview?.isUserInteractionEnabled = true
                self.removeFromSuperview()
            }
        }
       
    }
}
