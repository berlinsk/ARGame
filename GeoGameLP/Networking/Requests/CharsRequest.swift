import Foundation

class GetCharsRequest: Request {
    func request(
        completion: @escaping (_ chars: CharsResponseModel?, _ backendError: ErrorModel?) -> Void
        ) {
        
        RequestHelper.shared.requestManager?.request(
            requestModel: nil,
            url: URLBuilder.build(endpoint: GLPendpoint.chars),
            type: RequestHTTPMethod.get,
            headers: [:],
            completion: completion
        )
    }
}
