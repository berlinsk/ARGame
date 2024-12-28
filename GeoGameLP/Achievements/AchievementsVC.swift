import SwiftUI

struct Achievement: Identifiable, Decodable {
    let id: Int
    let title: String
    let shopId: Int
}

struct AchievementsView: View {
    @State private var achievements: [Achievement] = []
    @State private var shops: [ShopModel] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                Text("Досягнення")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(achievements) { achievement in
                            if let shop = shops.first(where: { $0.id == achievement.shopId }) {
                                AchievementRow(achievement: achievement, shop: shop)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear(perform: loadAchievements)
        }
    }

    private func loadAchievements() {
        isLoading = true
        errorMessage = nil
        
        loadShops { result in
            switch result {
            case .success(let shops):
                self.shops = shops
                
                loadAchievements { result in
                    isLoading = false
                    switch result {
                    case .success(let achievements):
                        self.achievements = achievements
                    case .failure(let error):
                        self.errorMessage = "Помилка завантаження досягнень: \(error.localizedDescription)"
                    }
                }
            case .failure(let error):
                isLoading = false
                self.errorMessage = "Помилка завантаження магазинів: \(error.localizedDescription)"
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    let shop: ShopModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(achievement.title)
                .font(.headline)
                .foregroundColor(.white)
            
            NavigationLink(destination: LoyaltyQRVC(shop: shop)) {
                Text("Використати")
                    .foregroundColor(.blue)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.9))
        .cornerRadius(10)
        .padding(.vertical, 5)
    }
}

extension AchievementsView {
    private func loadAchievements(completion: @escaping (Result<[Achievement], Error>) -> Void) {
        let url = URLBuilder.build(endpoint: GLPendpoint.shops)
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Дані не отримано", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                let achievements = try JSONDecoder().decode([Achievement].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(achievements))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func loadShops(completion: @escaping (Result<[ShopModel], Error>) -> Void) {
        let url = URLBuilder.build(endpoint: GLPendpoint.shops)
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Дані не отримано", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                let shopsResponse = try JSONDecoder().decode(ShopsResponseModel.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(shopsResponse.shops))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
