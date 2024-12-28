import UIKit
import AVFoundation
import CoreMotion

protocol GameViewControllerDelegate {
    func charCathed(gvc: GameViewController, charName: String)
}

final class GameViewController: UIViewController {
    
    private let viewModel: GameViewModel
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var foundImageView: UIImageView!
    private var dismissButton: UIButton!
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupMainComponents()
        bindViewModel()
        viewModel.startMotionUpdates()
        viewModel.startCameraCapture()
    }
    
    private func setupMainComponents() {
        setupPreviewLayer()
        setupGestureRecognizer()
        setupDismissButton()
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.captureSession)
        previewLayer.frame = view.bounds
        
        if let treasureLayer = viewModel.treasureLayer {
            view.layer.addSublayer(treasureLayer)
        }
        view.layer.addSublayer(previewLayer)
    }
    
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
    
    private func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    private func bindViewModel() {
        viewModel.treasureFoundHandler = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.animateInDismissButton()
                self.animateInTreasure()
                self.displayDiscoverLabel()
                self.displayNameOfTreasure()
            }
        }
    }
    
    @objc private func close() {
        self.dismiss(animated: true)
    }
    
    @objc private func viewTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        viewModel.handleTap(at: location)
    }
    
    private func animateInDismissButton() {
        UIView.transition(with: dismissButton, duration: 2.5, options: .transitionCrossDissolve) {
            self.dismissButton.alpha = 1.0
        }
    }
    
    private func animateInTreasure() {
        guard let frame = viewModel.treasureFrame else { return }
        let image = viewModel.treasure.image!
        foundImageView = UIImageView(image: image)
        foundImageView.alpha = 0.0
        foundImageView.frame = frame
        view.addSubview(foundImageView)
        
        UIView.animate(withDuration: 1.5, delay: 0.8, options: []) {
            self.foundImageView.alpha = 1.0
        }
    }
    
    private func displayDiscoverLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Regular", size: 30.0)
        label.text = "Caught❗️"
        label.textAlignment = .center
        label.textColor = .white
        label.alpha = 0.0
        view.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        
        UIView.animate(withDuration: 1.5, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 4.0, options: []) {
            label.alpha = 1.0
        }
    }
    
    private func displayNameOfTreasure() {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Regular", size: 45.0)
        label.text = viewModel.treasure.name
        label.textAlignment = .center
        label.textColor = .blue
        label.alpha = 0.0
        view.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: foundImageView.bottomAnchor, constant: 14.0).isActive = true
        
        UIView.animate(withDuration: 2.5, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: []) {
            label.alpha = 1.0
        }
    }
}
