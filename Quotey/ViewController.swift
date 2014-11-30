//
//  ViewController.swift
//  cardTest
//
//  Created by Mordechai Levi on 11/21/14.
//  Copyright (c) 2014 Martini. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController {
    
    @IBOutlet var card: UIView!
    @IBOutlet weak var keepButton: UIView!
    
    var animator : UIDynamicAnimator!
    var attachmentBehavior : UIAttachmentBehavior!
    var gravityBehaviour : UIGravityBehavior!
    var snapBehavior : UISnapBehavior!
    var pushBehavior : UIPushBehavior!
    var itemBehavior : UIDynamicItemBehavior!
    
    var originalBounds = CGRect()
    var originalCenter = CGPoint()
    
    let throwingThreshhold : CGFloat = 1000 // the velocity of the flick needed to throw off the screen
    let throwingVelocityPadding : CGFloat = 18 // speed(ish) () of the card going off screen
    

    @IBOutlet var quoteTextLabel: UILabel!
    @IBOutlet var quoteAuthorLabel: UILabel!
    
    var num = 0
    
    var didSwipeRight : Bool!
    var didSwipeLeft : Bool!
    
    var keptQuotes : Array<Dictionary<String,String>> = []
    var skippedQuotes : Array<Dictionary<String,String>> = []

    
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: view)
        originalBounds = card.bounds
        originalCenter = card.center

        card.layer.cornerRadius = 13
     
        cardAnimation()
        
        //Shadow magic
        card.layer.shadowOffset = CGSizeMake(0.1, -0.1)
        card.layer.shadowColor = UIColor(red: 0.189, green: 0.328, blue: 0.404, alpha: 1.000).CGColor
        card.layer.shadowRadius = 54
        card.layer.shadowOpacity = 0.20
        card.layer.shadowPath = UIBezierPath(rect: card.layer.bounds).CGPath

        
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        
        if event.subtype == UIEventSubtype.MotionShake {
            
            //clear coredata option
        }
        
    } 
    
    
    @IBAction func keepTapped(sender: AnyObject) {
        
        performSegueWithIdentifier("keepSeg", sender: self)
    
    }
   
    @IBAction func skipTapped(sender: AnyObject) {
        
        performSegueWithIdentifier("skipSeg", sender: self)
        
    }
 
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "keepSeg"{
            
            var navController : UINavigationController = segue.destinationViewController as UINavigationController
            var destinationView : KeepTableViewController = navController.viewControllers[0] as KeepTableViewController
            
            destinationView.keptQuotes = keptQuotes

            
        }
        if segue.identifier == "skipSeg" {
            
            var navController : UINavigationController = segue.destinationViewController as UINavigationController
            var destinationView : SkipTableViewController = navController.viewControllers[0] as SkipTableViewController
            
            destinationView.skippedQuotes = skippedQuotes
            
        }
        
    }
    
    func cardAnimation() {
        
        self.card.bounds = self.originalBounds
        self.card.center = self.originalCenter
        self.card.transform = CGAffineTransformIdentity
        
        self.card.backgroundColor = UIColor.whiteColor()
        self.quoteTextLabel.textColor = UIColor.blackColor()
        self.quoteAuthorLabel.textColor = UIColor.blackColor()
        
        var translate = CGAffineTransformMakeTranslation(0, 90)
        var transfrom = CGAffineTransformMakeScale(0.3, 0.3)
        
        self.card.transform = CGAffineTransformConcat(translate, transfrom)
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
        
            var translate = CGAffineTransformMakeTranslation(0, 0)
            var transfrom = CGAffineTransformMakeScale(1, 1)
            
            self.card.transform = CGAffineTransformConcat(translate, transfrom)

        }, completion: nil)
        
    }
    
    @IBAction func handlePan(sender: AnyObject) {
      
        view.layoutIfNeeded()
        
        var location = sender.locationInView(view)
        var cardLocation = sender.locationInView(card)
        
        if sender.state == UIGestureRecognizerState.Began {
        
            card.layoutIfNeeded()
            //more logic stuffs
            
            
            println("your touch started at position \(NSStringFromCGPoint(location))")
            println("location in image started is \(NSStringFromCGPoint(cardLocation))")
        
            
            //1
            self.animator.removeAllBehaviors()
            //2
            var centerOffset = UIOffsetMake(cardLocation.x - CGRectGetMidX(self.card.bounds), cardLocation.y - CGRectGetMidY(self.card.bounds))
            self.attachmentBehavior = UIAttachmentBehavior(item: self.card, offsetFromCenter: centerOffset, attachedToAnchor: location)
            //3
            self.animator.addBehavior(attachmentBehavior)
            
            
            
        }else if sender.state == UIGestureRecognizerState.Changed {
            
            
            attachmentBehavior.anchorPoint = sender.locationInView(view)
            
            let v = sender.velocityInView(view)
            
            if v.x > 0{
                
                println("right")
                
                didSwipeRight = true
                didSwipeLeft = false
                
                greenCard()
            
            }else {
                
                println("left")
                
                didSwipeRight = false
                didSwipeLeft = true
                
                redCard()
            }

            
            
        }else if sender.state == UIGestureRecognizerState.Ended {

            self.animator.removeBehavior(self.attachmentBehavior)
            
            //1
            var velocity = sender.velocityInView(view)
            var magnitude  = sqrtf(Float((velocity.x * velocity.x) + (velocity.y * velocity.y)))
            
            if CGFloat(magnitude) > throwingThreshhold {
                //2
                var pushBehavior = UIPushBehavior(items: [self.card], mode: UIPushBehaviorMode.Instantaneous)
                pushBehavior.pushDirection = CGVectorMake(velocity.x/10, velocity.y/10)
                pushBehavior.magnitude = CGFloat(magnitude) / throwingVelocityPadding
                
                self.pushBehavior = pushBehavior
                animator.addBehavior(pushBehavior)
                
                //3
                var angle = arc4random_uniform((20)-10)
                
                self.itemBehavior = UIDynamicItemBehavior(items: [self.card])
                self.itemBehavior.friction = 0.2
                self.itemBehavior.allowsRotation = true
                self.itemBehavior.addAngularVelocity(CGFloat(angle), forItem: self.card)
                
                //4
                
                
                   // self.goBack()
                    
                   // self.card.center = self.view.center
                
                
                
                delay(0.5, closure: {

                    //self.goBack()
                    
                    
                    self.actionOnSwipe()
                    println(self.keptQuotes)
                    self.animator.removeAllBehaviors()
                    self.num++
                    self.newCard()
                    
                    
                    
                })
                
                
            }else{
                
                goBack()
                didSwipeRight = false
                didSwipeLeft = false
                
            }
            
            
        }
        
        
        
        
    }

    func newCard() {
    
        if num == quotes.count {
            
            num = 0
        }
        
        quoteTextLabel.text = quotes[num]["quote"]
        quoteAuthorLabel.text = quotes[num]["author"]
        
//        quoteTextLabel.font = UIFont(name: "AvenirNextCondensed-Medium", size: 19)
//        quoteTextLabel.textAlignment = NSTextAlignment.Center
        cardAnimation()
    }
    
    func actionOnSwipe() {
        
        var q : String = quotes[self.num]["quote"]!
        var a : String = quotes[self.num]["author"]!
        
        if didSwipeRight == true && didSwipeLeft == false {
            
            var appDel : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            var context : NSManagedObjectContext = appDel.managedObjectContext!
            
            var newQuote = NSEntityDescription.insertNewObjectForEntityForName("KeptQuotes", inManagedObjectContext: context) as NSManagedObject
            
            newQuote.setValue(q, forKey: "quote")
            newQuote.setValue(a, forKey: "author")
            
            context.save(nil)
            
            println(newQuote)
            
        }else if didSwipeRight == false && didSwipeLeft == true {
            
            
            
        }
        
    }
    
    func greenCard() {
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            
            self.card.backgroundColor = UIColor(red: 0.196, green: 0.875, blue: 0.463, alpha: 1)
            self.quoteTextLabel.textColor = UIColor.whiteColor()
            self.quoteAuthorLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
            
            }, completion: nil)
        
    }
    
    func redCard() {
        
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            
            self.card.backgroundColor = UIColor(red: 1, green: 0.275, blue: 0.275, alpha: 1)
            self.quoteTextLabel.textColor = UIColor.whiteColor()
            self.quoteAuthorLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
            
            }, completion: nil)
        
    }

    func whiteCard() {
    
        UIView.animateWithDuration(0.4, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            
            self.card.backgroundColor = UIColor.whiteColor()
            self.quoteTextLabel.textColor = UIColor.blackColor()
            self.quoteAuthorLabel.textColor = UIColor.blackColor()
            
            }, completion: nil)
    
    }
    
    
    func goBack() {
        
        animator.removeAllBehaviors()
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            
            self.card.bounds = self.originalBounds
            self.card.center = self.originalCenter
            self.card.transform = CGAffineTransformIdentity
            
            
            }, completion: nil)
        
        whiteCard()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}

/*

@IBAction func keepTapped(sender: AnyObject) {

greenCard()

var pB = UIPushBehavior(items: [self.card], mode: UIPushBehaviorMode.Instantaneous)
pB.pushDirection = CGVectorMake(0, 0)
pB.angle = 0
pB.magnitude = 155 //speed(ish)

var ab = UIAttachmentBehavior(item: card, offsetFromCenter: UIOffsetMake(230, 500), attachedToAnchor: CGPointMake(700, 50)) //no clue what im doing here, just tweaking the values to my liking
animator.addBehavior(pB)
animator.addBehavior(ab)

didSwipeRight = true
didSwipeLeft = false
actionOnSwipe()

delay(0.6, closure: {

self.animator.removeAllBehaviors()
self.num++
self.newCard()

})

}


@IBAction func skipTapped(sender: AnyObject) {


redCard()

var pB = UIPushBehavior(items: [self.card], mode: UIPushBehaviorMode.Instantaneous)
pB.pushDirection = CGVectorMake(-1, 0)
//without angle it goes the opposite direction (which is what I want) -  dont ask, it just works.
pB.magnitude = 155 //speed(ish)

var ab = UIAttachmentBehavior(item: card, offsetFromCenter: UIOffsetMake(230, 500), attachedToAnchor: CGPointMake(700, 50)) //no clue what im doing here, just tweaking the values to my liking
animator.addBehavior(pB)
animator.addBehavior(ab)

didSwipeRight = false
didSwipeLeft = true
actionOnSwipe()

delay(0.6, closure: {

self.animator.removeAllBehaviors()
self.num++
self.newCard()

})

}

*/


