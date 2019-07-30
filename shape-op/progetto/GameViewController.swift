//
//  GameViewController.swift
//  progetto
//
//  Created by Marzullo Francesco on 11/02/2019.
//  Copyright © 2019 Marzullo Francesco. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    var mp: MultiPeer?
    var labelText: String?
    var roleChosen: String?
    
    var viewcp: SKView?
    var sceneNodecp: GameScene?
        
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        print("GameViewController: Tap on \(String(describing: roleChosen))")
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                sceneNodecp = sceneNode
                
                // Copy gameplay related content over to the scene
                sceneNode.role = roleChosen
                sceneNode.mp = mp
                sceneNode.label = labelText
                
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    viewcp = view
                    
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = false
                }
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        label.text = labelText
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
      
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        if viewcp?.isPaused == false{
            viewcp?.isPaused = true
//            pauseButton.isHidden = true
//            resumeButton.isHidden = false
            sceneNodecp?.role = "null"
            mp?.send(tipo:"pause:",property: "pause")
        } else {
            viewcp?.isPaused = false
//            resumeButton.isHidden = true
//            pauseButton.isHidden = false
            sceneNodecp?.role = label.text
            mp?.send(tipo:"pause:", property: "pause")
        }
    }
    
 
}
