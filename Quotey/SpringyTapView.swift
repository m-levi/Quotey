//
//  SpringyTapView.swift
//  buttons
//
//  Created by Mordechai Levi on 11/26/14.
//  Copyright (c) 2014 Martini. All rights reserved.
//

import UIKit

class SpringyTapView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        // super.touchesBegan(touches, withEvent: event)
        
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            
            
            self.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1)// transform the layer (the button) to scaled down size for taped size
            
            
            }, completion: nil)
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        // super.touchesEnded(touches, withEvent: event)
        
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            
            
            self.layer.transform = CATransform3DMakeScale(1, 1, 1) // transform the layer (the button) back to its original size
            
            
            }, completion: nil)
        
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
        //super.touchesCancelled(touches, withEvent: event)
        
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            
            
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
            
            
            }, completion: nil)
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        //super.touchesMoved(touches, withEvent: event)
        
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            
            
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
            
            
            }, completion: nil)
    }

    
    
}
