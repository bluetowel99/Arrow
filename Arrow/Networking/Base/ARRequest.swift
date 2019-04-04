
import APIKit

/// Arrow specific implementation of APIKit Request + additional helpers.

protocol ARRequest: Request {
    
    var platform: ARPlatform { get set }
    
    var sessionHeaderFields: [String: String] { get }
    
    func updateAppSession(with object: Any, urlResponse: HTTPURLResponse) throws
    
}

// MARK: - ARRequest Implementation

extension ARRequest {
    
    var platform: ARPlatform {
        return ARPlatform.shared
    }
    
    var baseURL: URL {
        return ARConstants.URLs.base
    }
    
    var sessionHeaderFields: [String: String] {
        var headerFields = [String: String]()
        
        guard let authToken = platform.userSession?.authToken else {
            return headerFields
        }
        
        headerFields["Authorization"] = "Token \(authToken)"
        return headerFields
    }
    
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard(200..<300).contains(urlResponse.statusCode) else {
            print("Response error (\(urlResponse.statusCode)):\n\(object)")
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        
        return object
    }
    
    func updateAppSession(with object: Any, urlResponse: HTTPURLResponse) throws {
        guard let dictionary = object as? [String: Any],
            let authToken = dictionary["token"] as? String else {
            throw ResponseError.unexpectedObject(object)
        }
        
        if platform.userSession == nil {
            platform.userSession = ARUserSession(authToken: authToken)
        } else {
            platform.userSession?.authToken = authToken
        }
    }
    
}

// MARK: - ARRequest Implementation for Dictionariable Response

extension ARRequest where Response: Dictionariable {
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard let response = Response(with: object) else {
            throw ResponseError.unexpectedObject(object)
        }
        return response
    }
    
}
