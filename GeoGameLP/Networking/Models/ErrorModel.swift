import Foundation

class NetworkError: Error {
    var statusCode: Int?

    init() {
        
    }
}

class ErrorModel: NetworkError, ResponseModel {
    
    var error: String?
    
    private enum CodingKeys: String, CodingKey {
        case error = "error"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.error = try? values.decode(String.self, forKey: .error)
    }
    
}
