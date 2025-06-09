//
//  AuthManagerTests.swift
//  BulbTests
//
//  Unit тесты для AuthManager
//

import XCTest
@testable import Bulb

class AuthManagerTests: XCTestCase {
    
    var authManager: AuthManager!
    
    override func setUpWithError() throws {
        authManager = AuthManager.shared
        // Очищаем UserDefaults перед каждым тестом
        authManager.clearTokens()
    }
    
    override func tearDownWithError() throws {
        authManager.clearTokens()
    }
    
    // MARK: - Token Storage Tests
    
    func testSaveTokens() {
        // Given
        let tokenResponse = TokenResponse(
            accessToken: "test_access_token",
            refreshToken: "test_refresh_token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        // When
        authManager.saveTokens(response: tokenResponse)
        
        // Then
        XCTAssertEqual(authManager.accessToken, "test_access_token")
        XCTAssertEqual(authManager.refreshToken, "test_refresh_token")
        XCTAssertTrue(authManager.isLoggedIn)
        XCTAssertFalse(authManager.isTokenExpired)
    }
    
    func testClearTokens() {
        // Given
        let tokenResponse = TokenResponse(
            accessToken: "test_access_token",
            refreshToken: "test_refresh_token",
            expiresAt: Date().addingTimeInterval(3600)
        )
        authManager.saveTokens(response: tokenResponse)
        
        // When
        authManager.clearTokens()
        
        // Then
        XCTAssertNil(authManager.accessToken)
        XCTAssertNil(authManager.refreshToken)
        XCTAssertFalse(authManager.isLoggedIn)
    }
    
    func testTokenExpiration() {
        // Given - токен с истекшим сроком
        let expiredTokenResponse = TokenResponse(
            accessToken: "expired_token",
            refreshToken: "refresh_token",
            expiresAt: Date().addingTimeInterval(-3600) // час назад
        )
        
        // When
        authManager.saveTokens(response: expiredTokenResponse)
        
        // Then
        XCTAssertTrue(authManager.isTokenExpired)
        XCTAssertTrue(authManager.isLoggedIn) // токен есть, но истек
    }
}

// MARK: - UserService Tests

class UserServiceTests: XCTestCase {
    
    var userService: UserService!
    
    override func setUpWithError() throws {
        userService = UserService.shared
    }
    
    func testUpdateProfileLocally() {
        // Given
        let name = "Тест"
        let surname = "Пользователь"
        let email = "test@example.com"
        let phone = "+7900123456"
        let description = "Тестовое описание"
        
        // When
        userService.updateProfileLocally(
            name: name,
            surname: surname,
            email: email,
            phone: phone,
            description: description
        )
        
        // Then
        let savedUser = userService.getCurrentUserFromStorage()
        XCTAssertNotNil(savedUser)
        XCTAssertEqual(savedUser?.name, name)
        XCTAssertEqual(savedUser?.surname, surname)
        XCTAssertEqual(savedUser?.email, email)
        XCTAssertEqual(savedUser?.phone, phone)
        XCTAssertEqual(savedUser?.description, description)
    }
}

// MARK: - Game Logic Tests

class GameLogicTests: XCTestCase {
    
    func testTruthOrDareModeSelection() {
        // Given
        let modes: Set<TruthOrDareMode> = [.truth, .dare]
        
        // When & Then
        XCTAssertTrue(modes.contains(.truth))
        XCTAssertTrue(modes.contains(.dare))
        XCTAssertEqual(modes.count, 2)
    }
    
    func testSelectionModeTypes() {
        // Given & When
        let fingersMode = SelectionMode.fingers
        let arrowMode = SelectionMode.arrow
        
        // Then
        XCTAssertEqual(fingersMode.rawValue, "Пальцы")
        XCTAssertEqual(arrowMode.rawValue, "Стрелка")
    }
    
    func testCardTypeColors() {
        // Given & When
        let truthType = CardType.truth
        let dareType = CardType.dare
        
        // Then
        XCTAssertEqual(truthType.rawValue, "Правда")
        XCTAssertEqual(dareType.rawValue, "Действие")
        XCTAssertNotNil(truthType.color)
        XCTAssertNotNil(dareType.color)
    }
}

// MARK: - Mock Classes

class MockNetworkManager {
    var shouldSucceed = true
    var mockResponse: Any?
    var mockError: NetworkError?
    
    func mockRequest<T: Codable>(
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        if shouldSucceed, let response = mockResponse as? T {
            completion(.success(response))
        } else {
            completion(.failure(mockError ?? .networkError("Mock error")))
        }
    }
}

class MockTests: XCTestCase {
    
    var mockNetworkManager: MockNetworkManager!
    
    override func setUpWithError() throws {
        mockNetworkManager = MockNetworkManager()
    }
    
    func testMockSuccess() {
        // Given
        let expectation = self.expectation(description: "Mock success")
        let mockToken = TokenResponse(
            accessToken: "mock_token",
            refreshToken: "mock_refresh",
            expiresAt: Date()
        )
        
        mockNetworkManager.shouldSucceed = true
        mockNetworkManager.mockResponse = mockToken
        
        // When
        mockNetworkManager.mockRequest(responseType: TokenResponse.self) { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertEqual(response.accessToken, "mock_token")
                expectation.fulfill()
            case .failure:
                XCTFail("Ожидался успех")
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testMockFailure() {
        // Given
        let expectation = self.expectation(description: "Mock failure")
        
        mockNetworkManager.shouldSucceed = false
        mockNetworkManager.mockError = .unauthorized
        
        // When
        mockNetworkManager.mockRequest(responseType: TokenResponse.self) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Ожидалась ошибка")
            case .failure(let error):
                XCTAssertEqual(error, .unauthorized)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
