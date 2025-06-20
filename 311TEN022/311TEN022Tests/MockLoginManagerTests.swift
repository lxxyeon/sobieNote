//
//  MockLoginManagerTests.swift
//  311TEN022Tests
//
//  Created by Claude on 2025-04-08.
//

import XCTest
@testable import _11TEN022

// 목업 테스트를 위한 클래스
class MockLoginManager: LoginManagerProtocol {
    var initializeCalled = false
    var handleURLCalled = false
    var checkLoginStatusCalled = false
    var logoutCalled = false
    
    var handleURLResult = false
    var checkLoginStatusResult = false
    var logoutResult = false
    
    func initialize() {
        initializeCalled = true
    }
    
    func handleURL(_ url: URL) -> Bool {
        handleURLCalled = true
        return handleURLResult
    }
    
    func checkLoginStatus(completion: @escaping (Bool) -> Void) {
        checkLoginStatusCalled = true
        completion(checkLoginStatusResult)
    }
    
    func logout(completion: @escaping (Bool) -> Void) {
        logoutCalled = true
        completion(logoutResult)
    }
}

final class MockLoginManagerTests: XCTestCase {
    
    var mockLoginManager: MockLoginManager!
    
    override func setUpWithError() throws {
        super.setUp()
        mockLoginManager = MockLoginManager()
    }
    
    override func tearDownWithError() throws {
        mockLoginManager = nil
        super.tearDown()
    }
    
    func testInitialize() {
        // 초기화 호출 확인
        mockLoginManager.initialize()
        XCTAssertTrue(mockLoginManager.initializeCalled, "initialize() should have been called")
    }
    
    func testHandleURL() {
        // 기본 반환값 설정
        mockLoginManager.handleURLResult = true
        
        // URL 처리 호출 및 결과 확인
        let url = URL(string: "https://example.com")!
        let result = mockLoginManager.handleURL(url)
        
        XCTAssertTrue(mockLoginManager.handleURLCalled, "handleURL() should have been called")
        XCTAssertTrue(result, "handleURL() should return true when set to do so")
        
        // 실패 케이스 테스트
        mockLoginManager.handleURLCalled = false
        mockLoginManager.handleURLResult = false
        
        let failResult = mockLoginManager.handleURL(url)
        
        XCTAssertTrue(mockLoginManager.handleURLCalled, "handleURL() should have been called")
        XCTAssertFalse(failResult, "handleURL() should return false when set to do so")
    }
    
    func testCheckLoginStatus() {
        // 성공 케이스 테스트
        mockLoginManager.checkLoginStatusResult = true
        
        let expectation = self.expectation(description: "Check login status")
        
        mockLoginManager.checkLoginStatus { isLoggedIn in
            XCTAssertTrue(self.mockLoginManager.checkLoginStatusCalled, "checkLoginStatus() should have been called")
            XCTAssertTrue(isLoggedIn, "checkLoginStatus() should return true when set to do so")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        // 실패 케이스 테스트
        mockLoginManager.checkLoginStatusCalled = false
        mockLoginManager.checkLoginStatusResult = false
        
        let failExpectation = self.expectation(description: "Check login status fail")
        
        mockLoginManager.checkLoginStatus { isLoggedIn in
            XCTAssertTrue(self.mockLoginManager.checkLoginStatusCalled, "checkLoginStatus() should have been called")
            XCTAssertFalse(isLoggedIn, "checkLoginStatus() should return false when set to do so")
            failExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLogout() {
        // 성공 케이스 테스트
        mockLoginManager.logoutResult = true
        
        let expectation = self.expectation(description: "Logout")
        
        mockLoginManager.logout { success in
            XCTAssertTrue(self.mockLoginManager.logoutCalled, "logout() should have been called")
            XCTAssertTrue(success, "logout() should return true when set to do so")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        // 실패 케이스 테스트
        mockLoginManager.logoutCalled = false
        mockLoginManager.logoutResult = false
        
        let failExpectation = self.expectation(description: "Logout fail")
        
        mockLoginManager.logout { success in
            XCTAssertTrue(self.mockLoginManager.logoutCalled, "logout() should have been called")
            XCTAssertFalse(success, "logout() should return false when set to do so")
            failExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
