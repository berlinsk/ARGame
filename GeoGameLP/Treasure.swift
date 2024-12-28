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
    
//    func makeImage(withCompletion completion: @escaping (Bool) -> ()) {
//        guard image == nil else { return }
//
//        if let url = URL(string: self.imageURL) {
//            DispatchQueue.global().async {
//                if let data = try? Data(contentsOf: url) {
//                    DispatchQueue.main.async {
//                        self.image = UIImage(data: data)
//                        if let image = self.image {
//                            self.item.contents = image.cgImage
//                        }
//                        completion(true)
//                    }
//                }
//            }
//        }
//    }

}
