
import Foundation

class ARBubbleStore {
    
    var networkSession = ARNetworkSession.shared
    var bubblesListVC: BubblesListVC?
    
    fileprivate var _bubbles: [ARBubble]?
    fileprivate var _activeBubble: ARBubble?
    
    var activeBubble: ARBubble? {
        get {
            guard let bubbles = _bubbles, !bubbles.isEmpty else {
                return nil
            }
            
            return _activeBubble ?? bubbles.first
        }
        
        set {
            _activeBubble = newValue
        }
    }
    
    func fetchUserBubbles(forceRefresh: Bool = false, completion: @escaping ([ARBubble]?) -> Void) {
        if forceRefresh == false, let bubbles = _bubbles {
            completion(bubbles)
            return
        }
        
        refreshBubbles { success in
            if success {
                completion(self._bubbles)
            }
        }
    }
    
    fileprivate func refreshBubbles(completion: @escaping (_ success: Bool) -> Void) {
        // Reset cached variable.
        let activeBubbleId = _activeBubble?.identifier
        _bubbles = nil
        _activeBubble = nil
        
        getAllBubblesList { bubbles, error in
            if let error = error {
                print("Error loading bubbles from server: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            self._bubbles = bubbles
            for bubble in self._bubbles!
            {
                if(bubble.identifier == activeBubbleId) {
                    self._activeBubble = bubble
                }
            }
            completion(true)
        }
    }
    
}

// MARK: - Networking

extension ARBubbleStore {
    
    fileprivate func getAllBubblesList(callback: (([ARBubble]?, NSError?) -> Void)?) {
        let getAllBubblesReq = GetAllBubblesRequest(platform: ARPlatform.shared)
        let _ = networkSession.send(getAllBubblesReq) { result in
            switch result {
            case .success(let bubbles):
                callback?(bubbles, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }
    
}
