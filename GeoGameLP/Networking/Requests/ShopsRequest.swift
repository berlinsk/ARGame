import Foundation

class GetShopsRequest: Request {
    func request(
        completion: @escaping (_ shops: ShopsResponseModel?, _ backendError: ErrorModel?) -> Void
        ) {
        
        RequestHelper.shared.requestManager?.request(
            requestModel: nil,
            url: URLBuilder.build(endpoint: GLPendpoint.shops),
            type: RequestHTTPMethod.get,
            headers: [:],
            completion: completion
        )
    }
}
