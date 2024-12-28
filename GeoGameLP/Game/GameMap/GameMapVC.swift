import UIKit
import GoogleMaps
import CoreLocation
import SVProgressHUD
import EasyAleert

class GameMapViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!

    private var mapView: GMSMapView!
    private var viewModel: GameMapViewModel!
    private var locationManager = CLLocationManager()
    
    private var firstCentration: Bool = false
    
    class func create(shop: ShopModel) -> GameMapViewController {
        let vc = GameMapViewController.storyboardInst.instantiateViewController(withIdentifier: GameMapViewController.identifier) as! GameMapViewController
        vc.viewModel = GameMapViewModel(shop: shop)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMapView()
        locationManager.delegate = self
        
        bindViewModel()
        viewModel.fetchCharacters()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    private func initMapView() {
        mapView = GMSMapView(frame: view.bounds)
        mapView.delegate = self
        view.insertSubview(mapView, at: 0)
        mapView.isMyLocationEnabled = true
        
        if let shopMarker = viewModel.createShopMarker() {
            shopMarker.map = mapView
        }
    }
    
    private func bindViewModel() {
        viewModel.onCharactersFetched = { [weak self] chars in
            DispatchQueue.main.async {
                chars.forEach { char in
                    char.marker?.map = self?.mapView
                }
                SVProgressHUD.dismiss()
            }
        }
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self?.dismiss(animated: true)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
            self.mapView.frame = self.view.frame
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension GameMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if !firstCentration {
            mapView.animate(to: GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17))
            firstCentration = true
        }
        
        viewModel.handlePlayerLocation(location: location, onProximity: { [weak self] char in
            self?.locationManager.stopUpdatingLocation()
            EasyAlert(delegate: self).showConfirmationAlert(title: "Приготуйся спіймати монстра") {
                let gvc = GameViewController.create(treasure: Treasure(name: char.char.name, image: char.image))
                gvc.delegate = self
                gvc.modalPresentationStyle = .fullScreen
                self?.present(gvc, animated: true)
            } cancelCompletion: {
                self?.locationManager.startUpdatingLocation()
            }
        })
    }
}

extension GameMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        locationManager(self.locationManager, didUpdateLocations: [CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)])
        return true
    }
}

extension GameMapViewController: GameViewControllerDelegate {
    func charCathed(gvc: GameViewController, charName: String) {
        viewModel.removeCharacter(named: charName)
    }
}

extension GameMapViewController: EasyAlertDelegate {
    func show(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}

extension GameMapViewController: StoryboardInstantiable {
    static var storyboardInst: UIStoryboard {
        return UIStoryboard.main
    }
}
