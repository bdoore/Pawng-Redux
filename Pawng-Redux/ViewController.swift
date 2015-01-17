//
//  ViewController.swift
//  Pawng-Redux
//
//  Created by Brian Doore on 12/8/14.
//  Copyright (c) 2014 Brian Doore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var animator: UIDynamicAnimator!
    var collision: UICollisionBehavior!
    
    var isLaunching : Bool = false
    var launchMode : Bool = false
    
    var ballProperties : UIDynamicItemBehavior!
    var paddleProperties : UIDynamicItemBehavior!
    
    var snapBehavior : UISnapBehavior!
    
    var pusher : UIPushBehavior!
    
    var viewFrame : CGRect!
    
    var maxX : CGFloat!
    var maxY : CGFloat!

    var square : UIView!
    var UserPaddle : UIView!
    var AIPaddle : UIView!
    
    var userScore : Int = 0
    var aiScore: Int = 0
    
    
    @IBOutlet weak var normalModeLabel: UILabel!
    @IBOutlet weak var launchModeLabel: UILabel!
    @IBOutlet weak var aiScoreLabel: UILabel!
    @IBOutlet weak var userScoreLabel: UILabel!
    
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        animator = UIDynamicAnimator(referenceView: view)

        ballProperties = UIDynamicItemBehavior(items: [square])
        ballProperties.allowsRotation = false
        ballProperties.elasticity = 1.0
        ballProperties.friction = 0.0
        ballProperties.resistance = 0.0
        
        paddleProperties = UIDynamicItemBehavior(items: [UserPaddle,AIPaddle])
        paddleProperties.allowsRotation = false
        paddleProperties.density = 9999.0
        
        collision = UICollisionBehavior(items: [square,UserPaddle,AIPaddle])
        collision.translatesReferenceBoundsIntoBoundary = true
        
        collision.action = {
            
//            println("ball velocity \(self.ballProperties.linearVelocityForItem(self.square))")

            if(self.square.frame.minX <= 10) {
                
                self.aiDidScore()
                
            }
            
            if(self.square.frame.maxX >= self.maxX-10) {
                
                self.userDidScore()
            }
            
            self.updateAIPaddle()
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        
        super.loadView()
        square = UIView()
        UserPaddle = UIView()
        AIPaddle = UIView()
        
        for viewToAdd in [square,UserPaddle,AIPaddle]{
            view.addSubview(viewToAdd)
        }
        
        view.addGestureRecognizer(panRecognizer)
        
        viewFrame = self.view.bounds
        
        maxX = viewFrame.maxX
        maxY = viewFrame.maxY
        
        launchModeLabel.hidden = true

    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
//        println("frames: \(UserPaddle.frame.size.height)")
        
        if(UserPaddle.frame.size.height == 0) {
            UserPaddle.frame = CGRect(x: 10, y: maxY/2-50, width: 10, height: 100)
            UserPaddle!.backgroundColor = UIColor.blueColor()
        }
        
        if(AIPaddle.frame.size.height == 0) {
            
            AIPaddle.frame = CGRect(x: maxX-20, y: maxY/2-50, width: 10, height: 100)
            AIPaddle.backgroundColor = UIColor.redColor()
            
            animator.addBehavior(paddleProperties)

            
        }
        
        if(square.frame.size.height == 0) {
            
            square.frame = CGRect(x: (maxX/2), y: 0, width: 25, height: 25)
            square.backgroundColor = UIColor.grayColor()
            
            animator.addBehavior(ballProperties)
            
            animator.addBehavior(collision)

//            self.pushBall(false)
            self.launchBall(self.launchMode, left: false)
            
        }
        


        


        
    }
    
// MARK: Game Functions
    
    
    func gameDidStart() {
        
        userScore = 0
        aiScore = 0
        updateScoreLabels()
        
//        self.pushBall(false)
        self.launchBall(self.launchMode, left: false)
        
    }
    
    func userDidWin() {
        
        println("User Wins")
        var alert = UIAlertController(title: "You Win!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default, handler: { (action) in self.gameDidStart() }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
    func aiDidWin() {
        
        println("AI Wins")
        var alert = UIAlertController(title: "You Lose!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default, handler:{ (action) in self.gameDidStart() }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
// MARK: Score Handling
    
    func updateScoreLabels() {
        
        userScoreLabel.text = String(userScore)
        aiScoreLabel.text = String(aiScore)
        
    }
    
    func userDidScore() {
        
        userScore+=1
        
        updateScoreLabels()
        
        if(userScore >= 10){
            userDidWin()
            snapSquare()
        } else if(userScore < 10){
//            self.pushBall(false)
            self.launchBall(self.launchMode, left: false)
        }
        
        
    }
    
    func aiDidScore() {
        
        aiScore+=1
        
        updateScoreLabels()
        
        if(aiScore >= 10) {
            aiDidWin()
            snapSquare()
        } else if(aiScore < 10){
//            self.pushBall(true)
            self.launchBall(self.launchMode, left: true)
        }
        
        
    }
    
// MARK: Push Handling
    
    func updateAIPaddle() {
        
        var ballVelocity : CGPoint = self.ballProperties.linearVelocityForItem(self.square)
        
        var paddleCenter : CGPoint = AIPaddle.center
        var ballCenter :CGPoint = square.center
        
        var diff : CGFloat = ballCenter.y - paddleCenter.y
        
        var random = arc4random_uniform(5)+1
        
        var offset : CGFloat = diff / abs(diff) * CGFloat(random)
        var originPoint : CGPoint = AIPaddle!.frame.origin
        var newPoint : CGPoint = CGPointMake(10, originPoint.y + offset)
        
        
        var potentialNewFrame : CGRect = CGRectMake(maxX-20, newPoint.y, CGRectGetWidth(AIPaddle!.frame), CGRectGetHeight(AIPaddle!.frame))
        
        if (CGRectContainsRect(self.view.frame, potentialNewFrame)) {
            
            self.AIPaddle.frame = potentialNewFrame;
            animator.updateItemUsingCurrentState(AIPaddle)
//            println( "new point y \(newPoint.y)")
            
        }
        
        
    }
    
    func pushActualLeft(){
        self.pushActual(true)
    }
    
    func pushActualRight(){
        self.pushActual(false)
    }
    
    func pushActual(left : Bool){
        
        showSquare()

        pusher = UIPushBehavior(items: [square], mode: UIPushBehaviorMode.Instantaneous)
        var xDir : CGFloat = 0.25
        if (left){
            xDir = xDir * -1
        }
        pusher.pushDirection = CGVectorMake(xDir, 0.125)

        pusher.active = true
        
//        println("number of behaviors \(animator.behaviors.count)")
        
//        println("ball velocity \(ballProperties.linearVelocityForItem(square))")
        animator.addBehavior(pusher)
    }
    
    func launchBall(launchMode: Bool, left: Bool) {
        
        if(launchMode) {
            
            
            
            if (snapBehavior != nil){
                animator.removeBehavior(snapBehavior)
            }
            
            snapSquare()
            
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("showSquare"), userInfo: true, repeats: false)

            
        } else {
            
            if (snapBehavior != nil){
                animator.removeBehavior(snapBehavior)
            }
            
            snapBehavior = UISnapBehavior(item: square, snapToPoint: CGPointMake((maxX/2), 0))
            square.hidden = true
            animator.addBehavior(snapBehavior)
            
            for pushBehavior : AnyObject in animator.behaviors{
                if (pushBehavior.isKindOfClass(UIPushBehavior.classForCoder())){
                    animator.removeBehavior(pushBehavior as UIPushBehavior)
                }
            }
            
            
            if(left) {
                NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("pushActualLeft"), userInfo: true, repeats: false)
                
            } else {
                NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("pushActualRight"), userInfo: true, repeats: false)
                
            }

            
        }
        
        
        
    }
    
    func snapSquare() {
        
        snapBehavior = UISnapBehavior(item: square, snapToPoint: CGPointMake((maxX/2), (maxY/2)))
        square.hidden = true
        animator.addBehavior(snapBehavior)

        
    }
    
    func showSquare(){
        square.hidden = false
        
        if(self.launchMode) {
            isLaunching = true

        }
        
        
        if (snapBehavior != nil){
            animator.removeBehavior(snapBehavior)
        }
    }
    
    func launchFromPoint(point: CGPoint) {
        
        var velocityVector = CGPointMake( max(50, point.x)*point.x/abs(point.x)/300, max(25, point.y)*point.y/abs(point.y)/300)
        
        pusher = UIPushBehavior(items: [square], mode: UIPushBehaviorMode.Instantaneous)
        
        pusher.pushDirection = CGVectorMake(velocityVector.x , velocityVector.y)
        
        pusher.active = true
        
        //        println("number of behaviors \(animator.behaviors.count)")
        
        //        println("ball velocity \(ballProperties.linearVelocityForItem(square))")
        animator.addBehavior(pusher)


        
    }
    

    func pushBall(left: Bool) {
        
        if (snapBehavior != nil){
            animator.removeBehavior(snapBehavior)
        }
        
        snapBehavior = UISnapBehavior(item: square, snapToPoint: CGPointMake((maxX/2), 0))
        showSquare()
        animator.addBehavior(snapBehavior)
        
        for pushBehavior : AnyObject in animator.behaviors{
            if (pushBehavior.isKindOfClass(UIPushBehavior.classForCoder())){
                animator.removeBehavior(pushBehavior as UIPushBehavior)
            }
        }
        
        
        
        if(left) {
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("pushActualLeft"), userInfo: true, repeats: false)

        } else {
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("pushActualRight"), userInfo: true, repeats: false)

        }

        
    }

    
    
    @IBAction func didPanOnView(sender: UIPanGestureRecognizer) {
        
        if(isLaunching) {
            
            var offset : CGPoint = sender.translationInView(self.view)
            var originPoint = square!.frame.origin
            var newPoint = CGPointMake(originPoint.x + offset.x, originPoint.y + offset.y)
            var centerSquare = CGRectMake(maxX/2-100, maxY/2-100, 200, 200)
            var potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, square.frame.width, square.frame.height)
            
            var difference : CGPoint = CGPointMake(maxX/2 - square.center.x, maxY/2 - square.center.y)
            
            if(CGRectContainsRect(centerSquare, potentialNewFrame)) {
                
                self.square.frame = potentialNewFrame
                animator.updateItemUsingCurrentState(square)
                
            }
            
            if(sender.state == UIGestureRecognizerState.Ended){
                
//                println( "final offset \(offset.y, offset.x)")
                println( "new point x \(difference.x)")
                println( "new point y \(difference.y)")
                
                self.launchFromPoint(difference)
                
                isLaunching = false

                
            }
            
            sender.setTranslation(CGPointZero, inView: square!)

            
            
        } else {
            
            var offset : CGPoint = sender.translationInView(self.view)
            var originPoint : CGPoint = UserPaddle!.frame.origin
            var newPoint : CGPoint = CGPointMake(10, originPoint.y + offset.y)
            
            var potentialNewFrame : CGRect = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(UserPaddle!.frame), CGRectGetHeight(UserPaddle!.frame))
            
            if (CGRectContainsRect(self.view.frame, potentialNewFrame)) {
                
                self.UserPaddle.frame = potentialNewFrame;
                animator.updateItemUsingCurrentState(UserPaddle)
                //            println( "new point y \(newPoint.y)")
                
            }
            
            sender.setTranslation(CGPointZero, inView: UserPaddle!)
            
        }
        
    }
    
    

    @IBAction func toggleLaunchMode(sender: UIButton) {
        
        if(launchMode) {
            
            launchModeLabel.hidden = true
            normalModeLabel.hidden = false
            
            launchMode = false
            
        } else {
            
            launchModeLabel.hidden = false
            normalModeLabel.hidden = true
            
            launchMode = true

        }
        
    }

}