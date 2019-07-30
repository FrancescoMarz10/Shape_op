//
//  GameScene.swift
//  progetto
//
//  Created by Marzullo Francesco on 11/02/2019.
//  Copyright © 2019 Marzullo Francesco. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate, MultiPeerDelegate{
    
    
    var mp: MultiPeer?
    var player = SKShapeNode(rect: CGRect(x: -40, y: -40, width: 80, height: 80), cornerRadius: 0)
    var motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var yAcceleration:CGFloat = 0
    
    var role: String?
    var label: String?
    var fingerLocation = CGPoint()
    var obiettivo : SKShapeNode = SKShapeNode(rect: CGRect(x: -30, y: -30, width: 60, height: 60), cornerRadius: 0)
    let colArray = [SKColor.red, SKColor.green, SKColor.blue]
    
    
    override func sceneDidLoad() {
        
        obiettivo.strokeColor = SKColor.blue
        obiettivo.position = CGPoint(x: frame.size.width/5, y: frame.size.height/2)
        obiettivo.lineWidth = 4
        obiettivo.fillColor = SKColor.gray
        self.addChild(obiettivo)
        
        
        print("GameScene: Tapped on \(String(describing: role))")
        player.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        player.fillColor = SKColor.green
        player.strokeColor = SKColor.white
//      set 45 if rotate
        player.zRotation = 0
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        
        
        
    }
    
    override func didMove(to view: SKView) {
        mp?.delegate = self
        
        if role == "pinch" {
            let pinch = UIPinchGestureRecognizer(target: self,
                                                 action: #selector(GameScene.pinchAction(sender:)))
            view.addGestureRecognizer(pinch)
        }else if role == "move" {
            motionManager.accelerometerUpdateInterval = 1 / 2000
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
                if let accelerometerData = data {
                    let acceleration = accelerometerData.acceleration
                    self.xAcceleration = CGFloat(acceleration.y) * 0.75 + self.yAcceleration * 0.25
                    self.yAcceleration = CGFloat(-acceleration.x) * 0.75 + self.xAcceleration * 0.25
                    
                    self.mp?.send(tipo: "move:", property: "\(self.player.position.x),\(self.player.position.y)")
                }
            }
            
        }
    }
    
    @objc func pinchAction(sender: UIPinchGestureRecognizer) {
        if role == "pinch" {
            let pinch = SKAction.scale(by: sender.scale, duration: 0.0)
            player.run(pinch)
            mp?.send(tipo:"pinch:", property: "\(sender.scale)")
            sender.scale = 1.0
            print(player.xScale)
            if player.frame.width > self.frame.width  / 4{
                player.xScale = 3.5
                player.yScale = 3.5
            }else if player.frame.width < 30{
                player.xScale = 0.8
                player.yScale = 0.8
            }
        }
    }
    
    func moved(manager: MultiPeer, value: String) {
        var position = value.split(separator: ",")
        let posX = position[0]
        let posY = position[1]
        
        player.position.x = CGFloat((posX as NSString).doubleValue)
        player.position.y = CGFloat((posY as NSString).doubleValue)
        
    }
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
        player.position.y += yAcceleration * 50
        
        if player.position.y < -20 {
            player.position = CGPoint(x: player.position.x, y: self.size.height + 20)
        }else if player.position.y > self.size.height + 20 {
            player.position = CGPoint(x: player.position.x, y: -20)
        }
        
    }
    
     var once = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if role == "color" {
            var n = Int.random(in: 0 ... 2)
            let colArray = [SKColor.red, SKColor.green, SKColor.blue]
            self.changeColor(color: colArray[n])
            //        controllo se sono il giocatore addetto al cambio colore
            switch n {
            case 0:
                mp?.send(tipo:"color:",property: "red")
            case 1:
                mp?.send(tipo:"color:",property: "green")
            case 2:
                mp?.send(tipo:"color:",property: "blue")
            default:
                mp?.send(tipo:"color:",property: "white")
            }
        
            
            if !once {
                DispatchQueue.init(label: "threadChangeStrokeColor", qos: .userInitiated).async {
                    self.once = true
                    while true {
                        usleep(3000000)
                        var t = Int.random(in: 0 ... 2)
                        
                      
                        switch t {
                        case 0:
                            self.mp?.send(tipo:"colorStroke:",property: "red")
                            self.obiettivo.strokeColor = .red
                            
                        case 1:
                            self.mp?.send(tipo:"colorStroke:",property: "green")
                            self.obiettivo.strokeColor = .green
                            
                        case 2:
                            self.mp?.send(tipo:"colorStroke:",property: "blue")
                            self.obiettivo.strokeColor = .blue
                            
                        default:
                            self.mp?.send(tipo:"colorStroke:",property: "white")
                            self.obiettivo.strokeColor = .white
                            
                        }
                        
                    }
                    
                }
                
            }
        
        }
        else if role == "rotate"{
            for touch: AnyObject in touches {
                fingerLocation = touch.location(in: self)
            }
        }
        
    }
    
    func colorStrokeChanged(manager: MultiPeer, colorString: String) {
      
        if(colorString == "red"){
             self.obiettivo.strokeColor = .red
        }
        else if(colorString == "green"){
            self.obiettivo.strokeColor = .green
        }
        else if (colorString == "blue"){
            self.obiettivo.strokeColor = .blue
        }
        else if (colorString == "white"){
            self.obiettivo.strokeColor = .white
        }
        
    }
    

    func changeColor(color : UIColor) {
        UIView.animate(withDuration: 0.2) {
            self.player.fillColor = color
        }
    }
    
    func colorChanged(manager: MultiPeer, colorString: String) {
        OperationQueue.main.addOperation {
            switch colorString {
            case "red":
                self.changeColor(color: .red)
            case "green":
                self.changeColor(color: .green)
            case "blue":
                self.changeColor(color: .blue)
            default:
                self.changeColor(color: .white)
            }
        }
    }
    
    func changeScale(scale : CGFloat) {
        UIView.animate(withDuration: 0.2) {
            //            self.player.xScale = scale
            //            self.player.yScale = scale
            
            let pinch = SKAction.scale(by: scale, duration: 0.0)
            self.player.run(pinch)
            if self.player.frame.width > self.frame.width  / 4{
                self.player.xScale = 3.5
                self.player.yScale = 3.5
            }else if self.player.frame.width < 30{
                self.player.xScale = 0.8
                self.player.yScale = 0.8
            }
        }
    }
    
    func pinchChanged(manager: MultiPeer, pinchScale: String) {
        
        OperationQueue.main.addOperation {
            let n = CGFloat((pinchScale as NSString).doubleValue)
            //            guard let temp = NumberFormatter().number(from: pinchScale) else { return }
            //            let n = CGFloat(truncating: temp)
            print("hola: \(n)")
            self.changeScale(scale: n)
            
        }
    }
    
    func setPause(manager: MultiPeer, pause: String) {
        
        if self.view?.isPaused == false{
            self.view?.isPaused = true
            role = "null"
        } else {
            self.view?.isPaused = false
            role = label
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            fingerLocation = touch.location(in: self)
            rotate1()
        }
    }
    
    func rotate1(){
        if role == "rotate" {
            var radians = atan2(fingerLocation.x, fingerLocation.y)
            player.run(SKAction.rotate(byAngle: radians, duration: 0.0))
            self.mp?.send(tipo: "rotate:", property: "\(fingerLocation.y),\(fingerLocation.x)")
        }
    }
    
    func rotateSquare(manager: MultiPeer, value: String){
        var fl = value.split(separator: ",")
        let fly = fl[0]
        let flx = fl[1]
        let radians = atan2(CGFloat((flx as NSString).doubleValue),CGFloat((fly as NSString).doubleValue))
        player.run(SKAction.rotate(byAngle: radians, duration: 0.0))
    }
    
    func victory(manager: MultiPeer, value: String){
        let scene = GameScene(fileNamed: "WinningScene")!
        let transition = SKTransition.moveIn(with: .down, duration: 3)
        self.view?.presentScene(scene, transition: transition)
        player.isPaused = true
        //        mp?.send(tipo:"pause:",property: "pause")
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        /* var n1 = Int.random(in: 0 ... 2)
         let array = [SKColor.red, SKColor.green, SKColor.blue]
         obiettivo.strokeColor = array[n1]*/
        var tmp : Int
        if player.zRotation <= 180{
            tmp = Int(player.zRotation) % 180
        }
        else {
            tmp = -Int(player.zRotation) % 180
        }
        
        print("rotation general: \(tmp)")
        if (player.fillColor == obiettivo.strokeColor){
            if((player.frame.width > obiettivo.frame.width - 20) && (player.frame.height > obiettivo.frame.height - 20)){
                if((player.position.x < obiettivo.position.x + 2) && (player.position.x > obiettivo.position.x - 2) && (player.position.y < obiettivo.position.y + 2) && (player.position.y > obiettivo.position.y - 2)){
                    print(" obiettivo rotation: \(obiettivo.zRotation)")
                    print(" player rotation: \(tmp)")
                    var rotation = 45
                    if((tmp  < Int(obiettivo.zRotation) + 15  && tmp > Int(obiettivo.zRotation) - 15 )
                        || (tmp  < Int(obiettivo.zRotation) + 105  && tmp  > Int(obiettivo.zRotation) + 75 )
                        || (tmp < Int(obiettivo.zRotation) - 75  && tmp  > Int(obiettivo.zRotation) - 105 )
                        || (tmp  < Int(obiettivo.zRotation) - 165  && tmp  > Int(obiettivo.zRotation) + 165)
                        ){
                        print("Uguale")
                        //                        mp?.send(tipo:"win:",property: "win")
                        let scene = GameScene(fileNamed: "WinningScene")!
                        let transition = SKTransition.moveIn(with: .down, duration: 1.5)
                        self.view?.presentScene(scene, transition: transition)
                        
    
                        //self.present(nextViewController, animated: true, completion: nil)
                        
                        return
                    }
                }
            }
        }
    }
    
    
    
}
