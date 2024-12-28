import UIKit

class ShopTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    private var shop: ShopModel? {
        didSet {
            self.label.text = shop?.name
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.shop = nil
    }
    
    func initializate(shop: ShopModel) {
        self.shop = shop
    }
    
}
