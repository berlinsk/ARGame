import UIKit
import SVProgressHUD
import CoreLocation

class ShopsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: ShopsViewModel!
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ShopsViewModel(locationManager: locationManager)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        viewModel.shopsDidUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
        
        viewModel.loadShops()
    }
    
    @IBAction func onNavigate(_ sender: Any) {
        let mapVC = ShopMapsViewController.create(shops: viewModel.shops)
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
}

extension ShopsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.handleShopSelection(at: indexPath.item, viewController: self)
    }
}

extension ShopsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.shops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopTableViewCell") as! ShopTableViewCell
        cell.initializate(shop: viewModel.shops[indexPath.item])
        return cell
    }
}

extension ShopsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        viewModel.updateLocation(locations.last)
    }
}
