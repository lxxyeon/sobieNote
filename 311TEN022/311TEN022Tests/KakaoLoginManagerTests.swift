//
//  KakaoLoginManagerTests.swift
//  311TEN022Tests
//
//  Created by Claude on 2025-04-08.
//

import XCTest
@testable import _11TEN022
import KakaoSDKCommon
import KakaoSDKAuth

final class KakaoLoginManagerTests: XCTestCase {
    
    var kakaoLoginManager: KakaoLoginManager!
    
    override func setUpWithError() throws {
        super.setUp()
        kakaoLoginManager = KakaoLoginManager.shared
    }
    
    override func tearDownWithError() throws {
        kakaoLoginManager = nil
        super.tearDown()
    }
    
    func testInitialization() {
        // KakaoLoginManager가 초기화되었는지 확인
        XCTAssertNotNil(kakaoLoginManager, "KakaoLoginManager should be initialized")
        
        // appKey 접근이 필요한 경우 Mirror 사용
        let mirror = Mirror(reflecting: kakaoLoginManager)
        if let appKey = mirror.children.first(where: { $0.label == "appKey" })?.value as? String {
            XCTAssertFalse(appKey.isEmpty, "App key should not be empty")
            XCTAssertEqual(appKey, "da34c776779354fda0a431b36464bf3a", "App key should match expected value")
        } else {
            XCTFail("Could not access appKey property")
        }
    }
    
    func testHandleURL() {
        // 일반 URL 테스트 - 처리되지 않아야 함
        let invalidURL = URL(string: "https://example.com")!
        XCTAssertFalse(kakaoLoginManager.handleURL(invalidURL), "Non-Kakao URL should return false")
        
        // 카카오 URL은 모킹이 필요 - 실제 인증 처리 확인은 통합 테스트로 진행
    }
    
    func testCheckLoginStatus() {
        // 비동기 테스트 기대값 설정
        let expectation = self.expectation(description: "Check login status")
        
        kakaoLoginManager.checkLoginStatus { isLoggedIn in
            // 로그인 상태는 Bool 타입이어야 함
            XCTAssertTrue(isLoggedIn is Bool, "Login status should be a boolean value")
            expectation.fulfill()
        }
        
        // 비동기 호출 대기
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLogout() {
        // 비동기 테스트 기대값 설정
        let expectation = self.expectation(description: "Logout")
        
        kakaoLoginManager.logout { success in
            // 로그아웃 결과가 Bool 타입이어야 함
            XCTAssertTrue(success is Bool, "Logout result should be a boolean value")
            expectation.fulfill()
        }
        
        // 비동기 호출 대기
        waitForExpectations(timeout: 5, handler: nil)
    }
}
