import UIKit
import SVProgressHUD
import CoreLocation
import EasyAleert

class ShopsViewController: UIViewController {
    
    private var shops: [ShopModel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var locationManager = CLLocationManager()
    
    private var lastLocation: CLLocation?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.show()
        GetShopsRequest().request { shops, backendError in
            if let shops = shops {
                self.shops = shops.shops
            }
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func onNavigate(_ sender: Any) {
        let mapVC = ShopMapsViewController.create(shops: self.shops)
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
    
}

extension ShopsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shop = self.shops[indexPath.item]
        if let uLocation = self.lastLocation {
            let distanceInMeters = uLocation.distance(from: CLLocation(latitude: shop.lat, longitude: shop.lon))
            if (distanceInMeters < 500 || self.shops[indexPath.item].id == 2) {
                let gvc = GameMapViewController.create(shop: self.shops[indexPath.item])
                gvc.modalPresentationStyle = .fullScreen
                self.present(gvc, animated: true)
            } else {
                EasyAlert(delegate: self).showToast("Щоб розпочати квест підійдіть ближче до магазину")
            }
            
        } else {
            EasyAlert(delegate: self).showToast("Неможливо визначити вашу геолокацію")
        }
    }
    
}

extension ShopsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopTableViewCell") as! ShopTableViewCell
        cell.initializate(shop: self.shops[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

extension ShopsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.lastLocation = location
        }
       
    }
}

extension ShopsViewController: EasyAlertDelegate {
    func show(_ alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
}
