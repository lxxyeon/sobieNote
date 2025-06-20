//
//  LoginManagerTests.swift
//  311TEN022Tests
//
//  Created by Claude on 2025-04-08.
//

import XCTest
@testable import _11TEN022

final class LoginManagerTests: XCTestCase {
    
    var loginManager: LoginManager!
    
    override func setUpWithError() throws {
        super.setUp()
        loginManager = LoginManager.shared
    }
    
    override func tearDownWithError() throws {
        loginManager = nil
        super.tearDown()
    }
    
    func testLoginManagerInitialization() {
        // 기본 로그인 매니저가 초기화되었는지 확인
        XCTAssertNotNil(loginManager, "LoginManager should be initialized")
        
        // 내부 구현 접근을 위한 테스트 확장 필요
        let mirror = Mirror(reflecting: loginManager)
        if let loginManagers = mirror.children.first(where: { $0.label == "loginManagers" })?.value as? [LoginManagerProtocol] {
            XCTAssertTrue(loginManagers.count >= 2, "LoginManager should have at least 2 login providers")
        } else {
            XCTFail("Could not access loginManagers property")
        }
    }
    
    func testHandleURL() {
        // 유효하지 않은 URL 테스트
        let invalidURL = URL(string: "https://example.com")!
        XCTAssertFalse(loginManager.handleURL(invalidURL), "Invalid URL should return false")
        
        // 카카오 로그인 URL은 실제 구현이 필요하므로 모킹이 필요
    }
    
    func testCheckAllLoginStatus() {
        // 비동기 테스트 기대값 설정
        let expectation = self.expectation(description: "Check all login statuses")
        
        loginManager.checkAllLoginStatus { results in
            // 결과 배열이 비어있지 않은지 확인
            XCTAssertFalse(results.isEmpty, "Login status results should not be empty")
            
            // 각 로그인 상태가 bool 값인지 확인
            for status in results {
                // 여기서는 단순히 값 타입 확인만 수행
                XCTAssertTrue(status is Bool, "Login status should be a boolean value")
            }
            
            expectation.fulfill()
        }
        
        // 비동기 호출 대기
        waitForExpectations(timeout: 5, handler: nil)
    }
}
