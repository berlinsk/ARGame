import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var isSent: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("Відновити пароль")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 40)
            
            if isSent {
                Text("Лист з інструкцією відправлено на \(email)")
                    .foregroundColor(.green)
                    .padding(.bottom, 20)
            } else {
                TextField("Введіть email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.bottom, 30)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }
                
                Button(action: resetPassword) {
                    Text("Відновити")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding()
    }

    private func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Будь ласка, введіть email"
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isSent = true
            }
        }
    }
}
