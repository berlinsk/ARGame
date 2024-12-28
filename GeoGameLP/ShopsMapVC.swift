import UIKit
import GoogleMaps
import CoreLocation

class ShopMapsViewController: UIViewController {
    private var mapView: GMSMapView!
    
    private var locationManager = CLLocationManager()
    
    private var shops: [ShopModel] = []
    
    class func create(shops: [ShopModel]) -> ShopMapsViewController {
        let vc = ShopMapsViewController.storyboardInst.instantiateViewController(withIdentifier: ShopMapsViewController.identifier) as! ShopMapsViewController
        vc.shops = shops
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMapView()

        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    private func initMapView() {
        self.mapView = GMSMapView()
        self.reloadMapView()
        self.view.insertSubview(self.mapView, at: 0)

        self.mapView.isMyLocationEnabled = true
        
        self.shops.forEach { shop in
            let shopMarker = GMSMarker()
            shopMarker.icon = UIImage(named: "shopIcon")
            shopMarker.position = CLLocationCoordinate2D(latitude: shop.lat, longitude: shop.lon)
            shopMarker.title = shop.name
            shopMarker.snippet = shop.name
            shopMarker.map = self.mapView
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.reloadMapView()
    }
    
    private func reloadMapView() {
        Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
            let parentFrame = self.view.frame
            let navBarMaxY = self.navigationController?.navigationBar.frame.maxY ?? 0
            self.mapView.frame = CGRect(x: parentFrame.origin.x, y: navBarMaxY, width:parentFrame.width, height: parentFrame.height - navBarMaxY)
        }
    }
}

extension ShopMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
            self.mapView.animate(to: camera)
            self.locationManager.stopUpdatingLocation()
        }
       
    }
}

extension ShopMapsViewController: StoryboardInstantiable {
    static var storyboardInst: UIStoryboard {
        return UIStoryboard.main
    }
    
}

