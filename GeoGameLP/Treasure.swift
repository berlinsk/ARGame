import Foundation
import UIKit
import CoreLocation

final class Treasure {
    var name: String
    var item = CALayer()
    var image: UIImage?
    
    init(name: String, image: UIImage?) {
        self.name = name
        self.image = image
        if let image = self.image {
            self.item.contents = image.cgImage
        }
    }
}
