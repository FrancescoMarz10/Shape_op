import Foundation
import MultipeerConnectivity

protocol MultiPeerDelegate {
    
    func colorChanged(manager : MultiPeer, colorString: String)
    func pinchChanged(manager : MultiPeer, pinchScale: String)
    func setPause(manager: MultiPeer, pause: String)
    func moved(manager: MultiPeer, value: String)
    func rotateSquare(manager: MultiPeer, value: String)
    func victory(manager: MultiPeer, value: String)
    func colorStrokeChanged(manager: MultiPeer, colorString: String)
}

class MultiPeer : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    // and can contain only ASCII lowercase letters, numbers and hyphens.
    private let ColorServiceType = "example-color"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    var delegate : MultiPeerDelegate?
 
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    func deinitializer() {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        session.disconnect()
    }
    
    func send(tipo :String, property : String) {
        NSLog("%@", "property: \(property) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(tipo.data(using: .utf8)!+property.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    
}

extension MultiPeer : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension MultiPeer : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MultiPeer : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
     
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        var stringhe = str.split(separator: ":")
        var str1 = stringhe[0]
        var str2 = stringhe[1]
        
        if str1 == "color"{
            if (str2 == "red" || str2 == "blue" || str2 == "green" || str2 == "white"){
                self.delegate?.colorChanged(manager: self, colorString: String(str2))
            }
        }
        else if str1 == "colorStroke" {
            print("COLOR STROKE \(str2)")
            if (str2 == "red" || str2 == "blue" || str2 == "green" || str2 == "white"){
                self.delegate?.colorStrokeChanged(manager: self, colorString: String(str2))
            }
        }
            
        else if str1 == "pause" {
            self.delegate?.setPause(manager: self, pause: String(str1))
            
        } else if str1 == "move" {
            self.delegate?.moved(manager: self, value: String(str2))
            
        }   else if str1 == "pinch" {
            print("ciao")
            self.delegate?.pinchChanged(manager: self, pinchScale: String(str2))
            print("str: \(str)")
        }
        else if str1 == "rotate" {
            self.delegate?.rotateSquare(manager: self, value: String(str2))
        }
        else if str1 == "win" {
            self.delegate?.victory(manager: self, value: String(str2))
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
 
}


