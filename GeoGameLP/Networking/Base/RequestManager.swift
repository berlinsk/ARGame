import Foundation

enum RequestHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol RequestManager {
    init()
    func request<T: Decodable, E: Decodable & NetworkError>(
        requestModel: Encodable?,
        url: URL,
        type: RequestHTTPMethod,
        headers: [String : String]?,
        completion: @escaping (_ model: T?, _ backendError: E?, _ statusCode: Int?) -> Void
    )
    
    func request<T: Decodable, E: Decodable & NetworkError>(
        requestModel: Encodable?,
        url: URL,
        type: RequestHTTPMethod,
        headers: [String : String]?,
        completion: @escaping (_ model: T?, _ backendError: E?) -> Void
    )
}

