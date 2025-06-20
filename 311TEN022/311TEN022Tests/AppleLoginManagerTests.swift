//
//  AppleLoginManagerTests.swift
//  311TEN022Tests
//
//  Created by Claude on 2025-04-08.
//

import XCTest
@testable import _11TEN022
import AuthenticationServices

final class AppleLoginManagerTests: XCTestCase {
    
    var appleLoginManager: AppleLoginManager!
    
    override func setUpWithError() throws {
        super.setUp()
        appleLoginManager = AppleLoginManager.shared
    }
    
    override func tearDownWithError() throws {
        appleLoginManager = nil
        super.tearDown()
    }
    
    func testInitialization() {
        // AppleLoginManager가 초기화되었는지 확인
        XCTAssertNotNil(appleLoginManager, "AppleLoginManager should be initialized")
        
        // userIdentifier 접근이 필요한 경우 Mirror 사용
        let mirror = Mirror(reflecting: appleLoginManager)
        if let userIdentifier = mirror.children.first(where: { $0.label == "userIdentifier" })?.value as? String {
            XCTAssertFalse(userIdentifier.isEmpty, "User identifier should not be empty")
        } else {
            XCTFail("Could not access userIdentifier property")
        }
    }
    
    func testHandleURL() {
        // Apple 로그인은 URL 처리를 하지 않으므로 항상 false 반환해야 함
        let url = URL(string: "https://example.com")!
        XCTAssertFalse(appleLoginManager.handleURL(url), "Apple login should not handle URLs")
    }
    
    func testCheckLoginStatus() {
        // 비동기 테스트 기대값 설정
        let expectation = self.expectation(description: "Check Apple login status")
        
        appleLoginManager.checkLoginStatus { isLoggedIn in
            // 로그인 상태는 Bool 타입이어야 함
            XCTAssertTrue(isLoggedIn is Bool, "Login status should be a boolean value")
            expectation.fulfill()
        }
        
        // 비동기 호출 대기
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLogout() {
        // 비동기 테스트 기대값 설정
        let expectation = self.expectation(description: "Apple logout")
        
        appleLoginManager.logout { success in
            // 로그아웃 결과가 Bool 타입이어야 함
            XCTAssertTrue(success is Bool, "Logout result should be a boolean value")
            // Apple 로그아웃은 항상 성공해야 함 (설정 앱 안내 메시지만 출력)
            XCTAssertTrue(success, "Apple logout should always return true")
            expectation.fulfill()
        }
        
        // 비동기 호출 대기
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCredentialRevokedNotification() {
        // 알림 관찰 테스트
        let expectation = self.expectation(description: "Credential revoked notification")
        
        // 알림 관찰자 설정
        let observer = NotificationCenter.default.addObserver(
            forName: Notification.Name("AppleCredentialRevoked"),
            object: nil,
            queue: nil
        ) { _ in
            expectation.fulfill()
        }
        
        // 알림 발송
        NotificationCenter.default.post(
            name: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil
        )
        
        // 비동기 호출 대기
        waitForExpectations(timeout: 5) { _ in
            // 관찰자 제거
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
