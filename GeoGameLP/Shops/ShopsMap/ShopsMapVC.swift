import UIKit
import GoogleMaps
import CoreLocation

class ShopMapsViewController: UIViewController {
    private var mapView: GMSMapView!
    private var viewModel: ShopMapsViewModel!

    class func create(shops: [ShopModel]) -> ShopMapsViewController {
        let vc = ShopMapsViewController.storyboardInst.instantiateViewController(withIdentifier: ShopMapsViewController.identifier) as! ShopMapsViewController
        vc.viewModel = ShopMapsViewModel(shops: shops)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initMapView()
        
        viewModel.startUpdatingLocation()
    }

    private func initMapView() {
        mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        view.addSubview(mapView)
        viewModel.setupMarkers(on: mapView)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        viewModel.reloadMapView(mapView: mapView, parentView: view)
    }
}

extension ShopMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            viewModel.updateLocation(location, mapView: mapView)
        }
    }
}

extension ShopMapsViewController: StoryboardInstantiable {
    static var storyboardInst: UIStoryboard {
        return UIStoryboard.main
    }
}
