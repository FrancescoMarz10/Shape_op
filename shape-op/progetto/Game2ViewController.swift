//
//  Game2ViewController.swift
//  progetto
//
//  Created by Gaetano Giuseppe on 19/02/2019.
//  Copyright © 2019 Marzullo Francesco. All rights reserved.
//

import UIKit

class Game2ViewController: UIViewController {
    
    var roleChosen: String?
    var mp: MultiPeer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier{
            
        case "pinchPath"? :
            
            let destinationView = segue.destination as! GameViewController
            roleChosen = "pinch"
            destinationView.mp = mp
            destinationView.labelText = "pinch"
            destinationView.roleChosen = roleChosen
            
        case "movePath"? :
            
            let destinationView = segue.destination as! GameViewController
            roleChosen = "move"
            destinationView.mp = mp
            destinationView.labelText = "move"
            destinationView.roleChosen = roleChosen
            
        case "colorPath"? :
            
            let destinationView = segue.destination as! GameViewController
            roleChosen = "color"
            destinationView.mp = mp
            destinationView.labelText = "color"
            destinationView.roleChosen = roleChosen
        
        case "rotatePath"? :
            let destinationView = segue.destination as! GameViewController
            roleChosen = "rotate"
            destinationView.mp = mp
            destinationView.labelText = "rotate"
            destinationView.roleChosen = roleChosen
            
        default : print(#function)
        }
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        mp?.deinitializer()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
