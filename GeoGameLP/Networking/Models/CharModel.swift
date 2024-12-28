import Foundation

class CharModel: ResponseModel {
    
    var name: String
    var imageURL: String
    
    
    private enum CodingKeys: String, CodingKey {
        case imageURL = "imageURL"
        case name = "name"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try? values.decode(String.self, forKey: .name)) ?? ""
        self.imageURL = (try? values.decode(String.self, forKey: .imageURL)) ?? ""
    }
    
}

class CharsResponseModel: ResponseModel {
    
    var chars: [CharModel]
    
    
    private enum CodingKeys: String, CodingKey {
        case chars = "chars"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.chars = (try? values.decode([CharModel].self, forKey: .chars)) ?? []
    }
    
}
