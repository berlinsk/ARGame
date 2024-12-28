import Foundation
import CoreLocation

class ShopsViewModel {
    private let locationManager: CLLocationManager
    var shops: [ShopModel] = []
    var lastLocation: CLLocation?
    var shopsDidUpdate: (() -> Void)?
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    func loadShops() {
        SVProgressHUD.show()
        GetShopsRequest().request { [weak self] shopsResponse, error in
            if let shops = shopsResponse?.shops {
                self?.shops = shops
                self?.shopsDidUpdate?()
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func updateLocation(_ location: CLLocation?) {
        self.lastLocation = location
    }
    
    func handleShopSelection(at index: Int, viewController: UIViewController) {
        guard let lastLocation = lastLocation else {
            EasyAlert(delegate: viewController).showToast("Неможливо визначити вашу геолокацію")
            return
        }
        
        let shop = shops[index]
        let distance = lastLocation.distance(from: CLLocation(latitude: shop.lat, longitude: shop.lon))
        
        if distance < 500 || shop.id == 2 {
            let gameVC = GameMapViewController.create(shop: shop)
            gameVC.modalPresentationStyle = .fullScreen
            viewController.present(gameVC, animated: true)
        } else {
            EasyAlert(delegate: viewController).showToast("Щоб розпочати квест підійдіть ближче до магазину")
        }
    }
}
