import Foundation
import Alamofire
import AlamofireNetworkActivityLogger

class AlamofireRequest: RequestManager {
    
    
    internal func request<T: Decodable, E: Decodable & NetworkError>(
        requestModel: Encodable?,
        url: URL,
        type: RequestHTTPMethod,
        headers: [String : String]?,
        completion: @escaping (_ model: T?, _ backendError: E?) -> Void)  {
        
        self.request(requestModel: requestModel, url: url, type: type, headers: headers) { (responce, error, _) in
            completion(responce, error)
        }
    }
    
    internal func request<T: Decodable, E: Decodable & NetworkError>(
        requestModel: Encodable?,
        url: URL,
        type: RequestHTTPMethod,
        headers: [String : String]?,
        completion: @escaping (_ model: T?, _ backendError: E?, _ statusCode: Int?) -> Void
        ) {
        
        let headers = (headers ?? [:])
        
        let ahs = HTTPHeaders(headers)
                
        AF.request(url, method: type.alamofireHTTPMethod, parameters: requestModel?.dictionary, encoding: JSONEncoding.default, headers: ahs).responseData { (response) in
            
            switch response.result {
            case .success(let v):
                if ((response.response?.statusCode ?? 0) / 100 == 2) { 
                    completion(try? JSONDecoder().decode(T.self, from: v), nil, response.response?.statusCode)
                } else {
                    let error: E? = try? JSONDecoder().decode(E.self, from: v)
                    error?.statusCode = response.response?.statusCode
                    completion(nil, error, response.response?.statusCode)
                }
            case .failure(_):
                completion(nil, nil, response.response?.statusCode)
            }

        }
        
    }
    
    required init() {
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
    }
    
    
    
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension RequestHTTPMethod {
    var alamofireHTTPMethod: Alamofire.HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .patch:
            return .patch
        case .delete:
            return .delete
        }
    }
}
