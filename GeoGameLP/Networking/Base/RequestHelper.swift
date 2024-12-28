import Foundation

class RequestHelper {
    
    static let shared: RequestHelper = RequestHelper()
    
    private(set) var requestManager: RequestManager? = AlamofireRequest()
    
    private init() {
        
    }
    
    func setupRequestManaget(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
    
}

protocol Request {
    
}

