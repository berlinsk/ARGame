import UIKit
import AVFoundation
import CoreMotion


final class GameViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    let motionManager = CMMotionManager()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var treasure: Treasure!
    
    var foundImageView: UIImageView!
    var dismissButton: UIButton!
    
    var delegate: GameViewControllerDelegate?
    
    class func create(treasure: Treasure) -> GameViewController {
        let vc = GameViewController.storyboardInst.instantiateViewController(withIdentifier: GameViewController.identifier) as! GameViewController
        vc.treasure = treasure
        return vc
    }
    
    var quaternionX: Double = 0.0 {
        didSet {
            if !foundTreasure { treasure.item.center.y = (CGFloat(quaternionX) * view.bounds.size.width - 180) * 4.0 }
        }
    }
    var quaternionY: Double = 0.0 {
        didSet {
            if !foundTreasure { treasure.item.center.x = (CGFloat(quaternionY) * view.bounds.size.height + 100) * 4.0 }
        }
    }
    
    var foundTreasure = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        DispatchQueue.main.async {
            self.setupMainComponents()
        }
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupMainComponents() {
        setupCaptureCameraDevice()
        setupPreviewLayer()
        setupMotionManager()
        setupGestureRecognizer()
        setupDismissButton()
    }
}

extension GameViewController {
    private func setupDismissButton() {
        dismissButton = UIButton(type: .system)
        dismissButton.setTitle("❌", for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        dismissButton.setTitleColor(UIColor.red, for: .normal)
        dismissButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.alpha = 0.0
        view.addSubview(dismissButton)
        dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -14.0).isActive = true
        dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
    
    private func animateInDismissButton() {
        UIView.transition(with: self.dismissButton, duration: 2.5, options: .transitionCrossDissolve) {
            self.dismissButton.alpha = 1.0
        }
    }
    
}

extension GameViewController {
    
    private func setupCaptureCameraDevice() {
        if
            let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let cameraDeviceInput = try? AVCaptureDeviceInput(device: cameraDevice) {
            
            if (captureSession.canAddInput(cameraDeviceInput)) {
                captureSession.addInput(cameraDeviceInput)
                DispatchQueue.global().async {
                    self.captureSession.startRunning()
                }
            }
            
        }
       
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        
        if treasure.image != nil {
            let height = treasure.image!.size.height
            let width = treasure.image!.size.height
            treasure.item.bounds = CGRectMake(100.0, 100.0, width, height)
            treasure.item.position = CGPointMake(view.bounds.size.height / 2, view.bounds.size.width / 2)
            previewLayer.addSublayer(treasure.item)
            view.layer.addSublayer(previewLayer)
        }
    }
    
}

extension GameViewController {
    
    private func setupMotionManager() {
        
        if motionManager.isDeviceMotionAvailable && motionManager.isAccelerometerAvailable {
            motionManager.deviceMotionUpdateInterval = 2.0 / 60.0
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { motion, error in
                if error != nil { print("wtf. \(String(describing: error))"); return }
                
                guard let motion = motion else { print("Couldn't unwrap motion"); return }
                
                self.quaternionX = motion.attitude.quaternion.x
                self.quaternionY = motion.attitude.quaternion.y
            }
        }
    }
}

extension GameViewController {
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(self.viewTapped(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func viewTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        
        let topLeftX = Int(treasure.item.origin.x)
        let topRightX = topLeftX + Int(treasure.item.width)
        let topLeftY = Int(treasure.item.origin.y)
        let bottomLeftY = topLeftY + Int(treasure.item.height)
        
        guard topLeftX < topRightX && topLeftX < bottomLeftY else { return }
        
        let xRange = topLeftX...topRightX
        let yRange = topLeftY...bottomLeftY
        
        checkForRange(xRange: xRange, yRange, withLocation: location)
    }
    
    private func checkForRange(xRange: ClosedRange<Int>, _ yRange: ClosedRange<Int>, withLocation location: CGPoint) {
        guard foundTreasure == false else { return }
        
        let tapIsInRange = xRange.contains(Int(location.x)) && yRange.contains(Int(location.y))
        
        if tapIsInRange {
            
            foundTreasure = true
            motionManager.stopDeviceMotionUpdates()
            captureSession.stopRunning()
            
            treasure.item.springToMiddle(withDuration: 1.5, damping: 9, inView: view)
            treasure.item.centerInView(view: view)
            
            previewLayer.fadeOutWithDuration(duration: 1.0)
            
            animateInTreasure()
            animateInDismissButton()
            displayNameOfTreasure()
            displayDiscoverLabel()
            
            self.delegate?.charCathed(gvc: self, charName: self.treasure.name)
            
        }
    }
}

extension GameViewController {
    
    func animateInTreasure() {
        let frame = treasure.item.frame
        let image = treasure.image!
        foundImageView = UIImageView(image: image)
        foundImageView.alpha = 0.0
        foundImageView.frame = frame
        view.addSubview(foundImageView)
        
        UIView.animate(withDuration: 1.5, delay: 0.8, options: []) {
            self.foundImageView.alpha = 1.0
        }
    }
    
    func displayDiscoverLabel() {
        let label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Regular", size: 30.0)
        label.text = "Caught❗️"
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.alpha = 0.0
        
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        
        label.center.x -= 800
        label.alpha = 1.0
        
        UIView.animate(withDuration: 1.5, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 4.0, options: []) {
            label.center.x = self.view.center.x
        }
        
    }
    
    func displayNameOfTreasure() {
        let label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Regular", size: 45.0)
        label.text = treasure.name
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.blue
        label.alpha = 0.0
        
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: foundImageView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: foundImageView.bottomAnchor, constant: 14.0).isActive = true
        label.centerYAnchor.constraint(equalTo: foundImageView.centerYAnchor).isActive = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        let originalCenterY = label.center.y
        label.center.y += 400
        label.alpha = 1.0
        
        UIView.animate(withDuration: 2.5, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: []) {
            label.center.y = originalCenterY
        }
        
    }
}

extension GameViewController: StoryboardInstantiable {
    static var storyboardInst: UIStoryboard {
        return UIStoryboard.main
    }
    
}

protocol GameViewControllerDelegate {
    func charCathed(gvc: GameViewController, charName: String)
}
