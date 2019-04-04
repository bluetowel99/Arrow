
import APIKit

/// `Session` manages tasks for HTTP/HTTPS requests.
class ARNetworkSession: Session {
    
    // Shared session for class methods.
    private static let privateSharedSession: ARNetworkSession = {
        let configuration = URLSessionConfiguration.default
        let adapter = URLSessionAdapter(configuration: configuration)
        return ARNetworkSession(adapter: adapter)
    }()
    
    /// The shared `Session` instance for class methods, `Session.sendRequest(_:handler:)` and `Session.cancelRequest(_:passingTest:)`.
    override class var shared: ARNetworkSession {
        return privateSharedSession
    }
    
}
