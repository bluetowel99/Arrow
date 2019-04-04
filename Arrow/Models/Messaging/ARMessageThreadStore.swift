
import Foundation

class ARMessageThreadStore {

    var networkSession = ARNetworkSession.shared

    fileprivate var _threads: [ARMessageThread]?
    
    var messagingInboxVC: MessagingInboxVC?

    func fetchUserThreads(forceRefresh: Bool = false, completion: @escaping ([ARMessageThread]?) -> Void) {
        if forceRefresh == false, let threads = _threads {
            completion(threads)
            return
        }

        refreshThreads { success in
            if success {
                completion(self._threads)
            }
        }
    }

    fileprivate func refreshThreads(completion: @escaping (_ success: Bool) -> Void) {
        // Reset cached variable.
        _threads = nil

        getAllThreadList { threads, error in
            if let error = error {
                print("Error loading threads from server: \(error.localizedDescription)")
                completion(false)
                return
            }

            self._threads = threads
            completion(true)
        }
    }

}

// MARK: - Networking

extension ARMessageThreadStore {

    fileprivate func getAllThreadList(callback: (([ARMessageThread]?, NSError?) -> Void)?) {
        let getAllThreadsReq = GetAllMessageThreadsRequest(platform: ARPlatform.shared)
        let _ = networkSession.send(getAllThreadsReq) { result in
            switch result {
            case .success(let threads):
                callback?(threads, nil)
            case .failure(let error):
                callback?(nil, error as NSError)
            }
        }
    }

}
