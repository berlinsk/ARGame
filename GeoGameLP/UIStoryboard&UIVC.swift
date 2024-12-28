import Foundation
import UIKit

extension UIStoryboard {
    class var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

extension UIViewController {
    class var identifier: String {
        return String(describing: self)
    }
}

protocol StoryboardInstantiable where Self: UIViewController {
    static var storyboardInst: UIStoryboard { get }
}
