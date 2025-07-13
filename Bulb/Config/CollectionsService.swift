//
//  CollectionsService.swift
//  Bulb
//
//  Enhanced service for handling collections with action types support
//

import Foundation

class CollectionsService {
    static let shared = CollectionsService()
    
    private init() {}
    
    // MARK: - Public Collections (no auth required)
    
    func getTrendingCollections(limit: Int = 10, completion: @escaping (Result<[Collection], NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/collections/trending?limit=\(limit)",
            method: .GET,
            responseType: CollectionsResponse.self,
            requiresAuth: false
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAllCollections(page: Int = 1, size: Int = 10, completion: @escaping (Result<PaginationResponse, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/collections?page=\(page)&size=\(size)",
            method: .GET,
            responseType: PaginationResponse.self,
            requiresAuth: false
        ) { result in
            completion(result)
        }
    }
    
    func getCollection(id: UInt, completion: @escaping (Result<Collection, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/collections/\(id)",
            method: .GET,
            responseType: Collection.self,
            requiresAuth: false
        ) { result in
            completion(result)
        }
    }
    
    func getCollectionActions(id: UInt, completion: @escaping (Result<[Action], NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/collections/\(id)/actions",
            method: .GET,
            responseType: ActionsResponse.self,
            requiresAuth: false
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Collection Statistics
    
    func getCollectionStats(id: UInt, completion: @escaping (Result<CollectionStats, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/collections/\(id)/stats",
            method: .GET,
            responseType: CollectionStats.self,
            requiresAuth: false
        ) { result in
            completion(result)
        }
    }
    
    // MARK: - User Collections (auth required)
    
    func getUserCollections(completion: @escaping (Result<[Collection], NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/user/collections",
            method: .GET,
            responseType: CollectionsResponse.self,
            requiresAuth: true
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createCollection(name: String, description: String, imageUrl: String? = nil, completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void) {
        let request = CollectionRequest(
            name: name,
            description: description,
            imageUrl: imageUrl
        )
        
        NetworkManager.shared.request(
            endpoint: "/collections",
            method: .POST,
            body: request,
            responseType: SuccessResponse.self,
            requiresAuth: true
        ) { result in
            completion(result)
        }
    }
    
    // MARK: - Enhanced: Create Collection with Actions
    
    func createCollectionWithActions(
        name: String,
        description: String,
        actions: [GameCard],
        imageUrl: String? = nil,
        completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void
    ) {
        // Convert GameCard to API request format
        let apiActions = actions.enumerated().map { index, card in
            CreateActionRequest(
                text: card.text,
                type: card.type.rawValue, // "truth" or "dare"
                order: index + 1
            )
        }
        
        let request = CreateCollectionWithActionsRequest(
            name: name,
            description: description,
            imageUrl: imageUrl,
            actions: apiActions
        )
        
        NetworkManager.shared.request(
            endpoint: "/collections/with-actions",
            method: .POST,
            body: request,
            responseType: SuccessResponse.self,
            requiresAuth: true
        ) { result in
            completion(result)
        }
    }
    
    func updateCollection(id: UInt, name: String, description: String, imageUrl: String? = nil, completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void) {
        let request = CollectionRequest(
            name: name,
            description: description,
            imageUrl: imageUrl
        )
        
        NetworkManager.shared.request(
            endpoint: "/collections/\(id)",
            method: .PUT,
            body: request,
            responseType: SuccessResponse.self,
            requiresAuth: true
        ) { result in
            completion(result)
        }
    }
    
    func deleteCollection(id: UInt, completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/collections/\(id)",
            method: .DELETE,
            responseType: SuccessResponse.self,
            requiresAuth: true
        ) { result in
            completion(result)
        }
    }
    
    // MARK: - Actions Management
    
    func addAction(to collectionId: UInt, text: String, type: CardType, order: Int, completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void) {
        let request = ActionRequest(
            text: text,
            type: type.rawValue, // "truth" or "dare"
            order: order
        )
        
        NetworkManager.shared.request(
            endpoint: "/collections/\(collectionId)/actions",
            method: .POST,
            body: request,
            responseType: SuccessResponse.self,
            requiresAuth: true
        ) { result in
            completion(result)
        }
    }
    
    func removeAction(id: UInt, completion: @escaping (Result<SuccessResponse, NetworkError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/actions/\(id)",
            method: .DELETE,
            responseType: SuccessResponse.self,
            requiresAuth: true
        ) { result in
            completion(result)
        }
    }
    
    // MARK: - Helper Extensions
    func testConnection(completion: @escaping (Bool) -> Void) {
        APIConfig.testConnection(completion: completion)
    }
}
