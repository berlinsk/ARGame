import Foundation

protocol BaseUrl {
    var rawValue: String {get}
}

enum GLPurl: String, BaseUrl {
    case BASE_URL = "https://hcr-res.fra1.cdn.digitaloceanspaces.com/kpi/"
}

protocol Endpoint {
    var rawValue: String {get}
}

enum GLPendpoint: String, Endpoint {
    case shops = "shops.json"
    case chars = "chars.json"

}

class URLBuilder {
    class func build(endpoint: Endpoint) -> URL {
        return URLBuilder.build(endpoint: endpoint.rawValue)
    }
    
    class func build(url: GLPurl = GLPurl.BASE_URL, endpoint: String) -> URL {
        let urlString = ((url.rawValue + endpoint).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
        print("-----------------------------------------")
        print(urlString)
        return URL(string: urlString)!
    }
}
