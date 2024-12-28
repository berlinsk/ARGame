import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            Text("Авторизація")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 40)
            
            TextField("Пошта", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.bottom, 15)
            
            SecureField("Пароль", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 30)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                } else {
                    Text("Увійти")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)
            .padding(.bottom, 20)
            
            NavigationLink("Відновити пароль", destination: ForgotPasswordView())
                .foregroundColor(.blue)
                .padding(.bottom, 10)
            
            NavigationLink("Увійти як адміністратор", destination: AdminLoginView())
                .foregroundColor(.blue)
        }
        .padding()
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Будь ласка, заповніть усі поля"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            guard let window = UIApplication.shared.windows.first else { return }
                        let storyboard = UIStoryboard.main
                        if let shopsVC = storyboard.instantiateViewController(withIdentifier: "ShopsViewController") as? ShopsViewController {
                            let navigationController = UINavigationController(rootViewController: shopsVC)
                            window.rootViewController = navigationController
                            window.makeKeyAndVisible()
                        }
        }
    }
}
