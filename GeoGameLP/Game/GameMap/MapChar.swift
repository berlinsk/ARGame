import Foundation
import GoogleMaps
import CoreLocation
import UIKit

class MapChar {
    var char: CharModel
    var location: CLLocation
    var marker: GMSMarker?
    var image: UIImage?
    
    init(char: CharModel, location: CLLocation) {
        self.char = char
        self.location = location
    }
}
