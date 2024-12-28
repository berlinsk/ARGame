import Foundation
import CoreLocation

class ShopModel: ResponseModel {
    
    var id: Int
    var lat: Double
    var lon: Double
    var name: String
    
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case lat = "lat"
        case lon = "lon"
        case name = "name"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? values.decode(Int.self, forKey: .id)) ?? -1
        self.name = (try? values.decode(String.self, forKey: .name)) ?? ""
        self.lat = (try? values.decode(Double.self, forKey: .lat)) ?? 0
        self.lon = (try? values.decode(Double.self, forKey: .lon)) ?? 0
    }
    
    func getLocation() -> CLLocation {
        return CLLocation(latitude: self.lat, longitude: self.lon)
    }
}

class ShopsResponseModel: ResponseModel {
    
    var shops: [ShopModel]
    
    
    private enum CodingKeys: String, CodingKey {
        case shops = "shops"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.shops = (try? values.decode([ShopModel].self, forKey: .shops)) ?? []
    }
    
}
