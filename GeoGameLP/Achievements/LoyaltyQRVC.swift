import SwiftUI
import CoreImage.CIFilterBuiltins

struct LoyaltyQRVC: View {
    let shop: ShopModel
    @State private var qrCodeImage: UIImage?
    @State private var uniqueCode: String = UUID().uuidString.uppercased()
    @State private var countdown: Int = 600
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Text("Ваш QR-код")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            
            if let qrCodeImage = qrCodeImage {
                Image(uiImage: qrCodeImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
            } else {
                ProgressView()
            }
            
            Text("Унікальний код: \(uniqueCode)")
                .font(.subheadline)
                .padding(.top, 10)
            
            Text(timeString(from: countdown))
                .font(.largeTitle)
                .foregroundColor(.green)
                .padding(.top, 10)
        }
        .padding()
        .onAppear {
            generateQRCode()
        }
        .onReceive(timer) { _ in
            if countdown > 0 {
                countdown -= 1
            }
        }
    }
    
    private func generateQRCode() {
        let filter = CIFilter.qrCodeGenerator()
        let data = "\(shop.name)-\(uniqueCode)".data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        if let outputImage = filter.outputImage {
            let uiImage = UIImage(ciImage: outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10)))
            self.qrCodeImage = uiImage
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
