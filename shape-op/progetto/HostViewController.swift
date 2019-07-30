//
//  HostViewController.swift
//  progetto
//
//  Created by Marzullo Francesco on 12/02/2019.
//  Copyright © 2019 Marzullo Francesco. All rights reserved.
//

import UIKit

class HostViewController: UIViewController {

    var mp = MultiPeer()
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var peerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        switch segue.identifier{
            
        case "playPath"? :
            
            let destinationView = segue.destination as! Game2ViewController
            destinationView.mp = mp
            
        default : print(#function)
        }
        
    }

    @IBAction func refreshButtonTapped(_ sender: Any) {
        peerLabel.text = "CONNECTED PLAYERS: " + "\(mp.session.connectedPeers.count+1)"
        
        if mp.session.connectedPeers.count >= 1 {
            playButton.isHidden = false
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        mp.deinitializer()
    }
    
}
