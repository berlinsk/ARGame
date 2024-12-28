import SwiftUI
import FirebaseAuth

struct RegistrationView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            Text("Реєстрація")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 40)
            
            TextField("Ім'я", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 15)
            
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
            
            Button(action: register) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                } else {
                    Text("Зареєструватися")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)
            .padding(.bottom, 20)
            
            Spacer()
            
            NavigationLink("Вже маєте акаунт? Увійти", destination: LoginView())
                .foregroundColor(.blue)
        }
        .padding()
    }
    
    private func register() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Будь ласка, заповніть усі поля"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user else {
                errorMessage = "Помилка реєстрації. Спробуйте ще раз."
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
