import Foundation
import GoogleMaps
import CoreLocation
import SVProgressHUD

class GameMapViewModel {
    private let shop: ShopModel
    private var chars: [MapChar] = []
    
    var onCharactersFetched: (([MapChar]) -> Void)?
    var onError: ((Error?) -> Void)?
    
    init(shop: ShopModel) {
        self.shop = shop
    }
    
    func fetchCharacters() {
        SVProgressHUD.show()
        GetCharsRequest().request { [weak self] response, error in
            guard let self = self else { return }
            if let chars = response?.chars {
                self.generateMapCharacters(from: chars)
                self.onCharactersFetched?(self.chars)
            } else {
                self.onError?(error)
            }
        }
    }
    
    func createShopMarker() -> GMSMarker? {
        let marker = GMSMarker()
        marker.icon = UIImage(named: "shopIcon")
        marker.position = CLLocationCoordinate2D(latitude: shop.lat, longitude: shop.lon)
        return marker
    }
    
    func handlePlayerLocation(location: CLLocation, onProximity: @escaping (MapChar) -> Void) {
        for char in chars {
            if char.location.distance(from: location) < 20 {
                onProximity(char)
                return
            }
        }
    }
    
    func removeCharacter(named charName: String) {
        chars.removeAll(where: { $0.char.name == charName })
    }
    
    private func generateMapCharacters(from charModels: [CharModel]) {
        for charModel in charModels {
            var location: CLLocation
            repeat {
                location = generateRandomLocation(center: shop.getLocation(), radius: 100)
            } while chars.contains(where: { $0.location.distance(from: location) < 100 })
            
            let mapChar = MapChar(char: charModel, location: location)
            if let url = URL(string: charModel.imageURL), let data = try? Data(contentsOf: url) {
                mapChar.image = UIImage(data: data)
                mapChar.marker = GMSMarker(position: location.coordinate)
                mapChar.marker?.icon = mapChar.image?.imageWith(newSize: CGSize(width: 40, height: 40))
            }
            chars.append(mapChar)
        }
    }
    
    private func generateRandomLocation(center: CLLocation, radius: Double) -> CLLocation {
        let radiusInMeters: Double = radius
        let earthRadius: Double = 6371000

        let radiusInRadians = radiusInMeters / earthRadius
        let u = Double.random(in: 0...1)
        let v = Double.random(in: 0...1)
        let w = radiusInRadians * sqrt(u)
        let t = 2 * Double.pi * v

        let centerLatRadians = center.coordinate.latitude.toRadians()
        let centerLonRadians = center.coordinate.longitude.toRadians()

        let newLatRadians = asin(sin(centerLatRadians) * cos(w) + cos(centerLatRadians) * sin(w) * cos(t))
        let newLonRadians = centerLonRadians + atan2(sin(w) * sin(t), cos(centerLatRadians) * cos(w) - sin(centerLatRadians) * sin(w) * cos(t))

        return CLLocation(latitude: newLatRadians.toDegrees(), longitude: newLonRadians.toDegrees())
    }
}
