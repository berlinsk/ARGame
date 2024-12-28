import UIKit
import GoogleMaps
import CoreLocation
import SVProgressHUD
import EasyAleert

class GameMapViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    
    
    private var mapView: GMSMapView!
    
    private var locationManager = CLLocationManager()
    
    private var firstCentration: Bool = false
    
    private var shop: ShopModel!
    private var chars: [MapChar] = []
    
    class func create(shop: ShopModel) -> GameMapViewController {
        let vc = GameMapViewController.storyboardInst.instantiateViewController(withIdentifier: GameMapViewController.identifier) as! GameMapViewController
        vc.shop = shop
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initMapView()

        self.locationManager.delegate = self
        
        SVProgressHUD.show()
        GetCharsRequest().request { chars, backendError in
            if let chars = chars {
                var newLocation = self.generateRandomLocation(center: self.shop.getLocation(), radius: 100)
                chars.chars.forEach { char in
                    
                    var fl: Bool = true
                    while(fl) {
                        fl = false
                        newLocation = self.generateRandomLocation(center: self.shop.getLocation(), radius: 100)
                        self.chars.forEach { char in
                            if (char.location.distance(from: newLocation) < 100) {
                                fl = true
                                return
                            }
                        }
                    }
                    
                    let mapChar = MapChar(char: char, location: newLocation)
                    self.chars.append(mapChar)
                    
                   
                    
                    if let url = URL(string: char.imageURL), let data = try? Data(contentsOf: url) {
                        mapChar.image = UIImage(data: data)
                        
                        
                        mapChar.marker = GMSMarker()
                        mapChar.marker?.icon = mapChar.image?.imageWith(newSize: CGSize(width: 40, height: 40))
                        mapChar.marker?.position = mapChar.location.coordinate
                        mapChar.marker?.map = self.mapView
                    }
                    
                }
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                self.dismiss(animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }
    
    private func initMapView() {
        let options = GMSMapViewOptions()
        if let shop = self.shop {
            options.camera = GMSCameraPosition.camera(withLatitude: shop.lat, longitude: shop.lon, zoom: 6.0)
        }
        
        options.frame = self.view.frame

        self.mapView = GMSMapView(options: options)
        self.mapView.delegate = self
        self.view.insertSubview(self.mapView, at: 0)

        self.mapView.isMyLocationEnabled = true
        
        if let shop = self.shop {
            let shopMarker = GMSMarker()
            shopMarker.icon = UIImage(named: "shopIcon")
            shopMarker.position = CLLocationCoordinate2D(latitude: shop.lat, longitude: shop.lon)
            shopMarker.map = self.mapView
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { _ in
            self.mapView.frame = self.view.frame
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    private func generateRandomLocation(center: CLLocation, radius: Double) -> CLLocation {
        let radiusInMeters: Double = radius
        let earthRadius: Double = 6371000 // Earth's radius in meters

        // Convert radius from meters to radians
        let radiusInRadians = radiusInMeters / earthRadius

        // Generate two random numbers
        let u = Double.random(in: 0...1)
        let v = Double.random(in: 0...1)

        // Convert random numbers to polar coordinates
        let w = radiusInRadians * sqrt(u)
        let t = 2 * Double.pi * v

        // Convert center latitude and longitude to radians
        let centerLatRadians = center.coordinate.latitude.toRadians()
        let centerLonRadians = center.coordinate.longitude.toRadians()

        // Calculate new latitude in radians
        let newLatRadiansPart1 = sin(centerLatRadians) * cos(w)
        let newLatRadiansPart2 = cos(centerLatRadians) * sin(w) * cos(t)
        let newLatRadians = asin(newLatRadiansPart1 + newLatRadiansPart2)

        // Calculate new longitude in radians
        let newLonRadiansPart1 = sin(w) * sin(t)
        let newLonRadiansPart2 = cos(centerLatRadians) * cos(w)
        let newLonRadiansPart3 = sin(centerLatRadians) * newLonRadiansPart1
        let newLonRadians = centerLonRadians + atan2(newLonRadiansPart1, newLonRadiansPart2 - newLonRadiansPart3)

        // Convert radians back to degrees
        let newLat = newLatRadians.toDegrees()
        let newLon = newLonRadians.toDegrees()


        return CLLocation(latitude: newLat, longitude: newLon)
    }
}

extension GameMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 17)
            
            if (!firstCentration) {
                self.mapView.animate(to: camera)
                self.firstCentration = true
            }
            
            self.chars.forEach { char in
                print(char.location.distance(from: location))
                if (char.location.distance(from: location) < 20) {
                    self.locationManager.stopUpdatingLocation()
                    EasyAlert(delegate: self).showConfirmationAlert(title: "Приготуйся спіймати монстра") {
                        let gvc = GameViewController.create(treasure: Treasure(name: char.char.name, image: char.image))
                        gvc.delegate = self
                        gvc.modalPresentationStyle = .fullScreen
                        self.present(gvc, animated: true)
                        
                    } cancelCompletion: {
                        self.locationManager.startUpdatingLocation()
                    }

                    return
                }
            }
            
            
        }
       
    }
}

extension GameMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.locationManager(self.locationManager, didUpdateLocations: [CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)])
        return true
    }
}

extension GameMapViewController: GameViewControllerDelegate {
    func charCathed(gvc: GameViewController, charName: String) {
        self.chars.first(where: {$0.char.name == charName})?.marker?.map = nil
        self.chars.removeAll(where: { $0.char.name == charName })
    }
    
    
}

extension GameMapViewController: EasyAlertDelegate {
    func show(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}


extension GameMapViewController: StoryboardInstantiable {
    static var storyboardInst: UIStoryboard {
        return UIStoryboard.main
    }
    
}

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
