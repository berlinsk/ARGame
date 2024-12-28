import Foundation
import GoogleMaps
import CoreLocation

class ShopMapsViewModel {
    private let locationManager = CLLocationManager()
    private var shops: [ShopModel]

    init(shops: [ShopModel]) {
        self.shops = shops
        locationManager.delegate = nil
    }

    func setupMarkers(on mapView: GMSMapView) {
        shops.forEach { shop in
            let marker = GMSMarker()
            marker.icon = UIImage(named: "shopIcon")
            marker.position = CLLocationCoordinate2D(latitude: shop.lat, longitude: shop.lon)
            marker.title = shop.name
            marker.map = mapView
        }
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func updateLocation(_ location: CLLocation, mapView: GMSMapView) {
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
        mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }

    func reloadMapView(mapView: GMSMapView, parentView: UIView) {
        let parentFrame = parentView.frame
        let navBarMaxY = parentView.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        mapView.frame = CGRect(x: 0, y: navBarMaxY, width: parentFrame.width, height: parentFrame.height - navBarMaxY)
    }
}
