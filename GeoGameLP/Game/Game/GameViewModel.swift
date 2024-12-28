import AVFoundation
import CoreMotion

class GameViewModel {
    let captureSession = AVCaptureSession()
    let motionManager = CMMotionManager()
    let treasure: Treasure
    
    private(set) var treasureLayer: CALayer?
    private(set) var treasureFrame: CGRect?
    var treasureFoundHandler: (() -> Void)?
    
    private var foundTreasure = false
    
    init(treasure: Treasure) {
        self.treasure = treasure
        setupTreasureLayer()
    }
    
    func startCameraCapture() {
        if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let cameraInput = try? AVCaptureDeviceInput(device: cameraDevice),
           captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
            DispatchQueue.global().async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            self?.updateTreasurePosition(quaternionX: motion.attitude.quaternion.x, quaternionY: motion.attitude.quaternion.y)
        }
    }
    
    func handleTap(at location: CGPoint) {
        guard !foundTreasure else { return }
        
        if treasureFrame?.contains(location) == true {
            foundTreasure = true
            motionManager.stopDeviceMotionUpdates()
            captureSession.stopRunning()
            treasureFoundHandler?()
        }
    }
    
    private func setupTreasureLayer() {
        guard let image = treasure.image else { return }
        treasureLayer = CALayer()
        treasureLayer?.contents = image.cgImage
        treasureLayer?.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        treasureFrame = treasureLayer?.frame
    }
    
    private func updateTreasurePosition(quaternionX: Double, quaternionY: Double) {
        guard let layer = treasureLayer else { return }
        layer.position.x += CGFloat(quaternionX) * 10
        layer.position.y += CGFloat(quaternionY) * 10
    }
}
