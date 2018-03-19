//
//  NotificationsTests.swift
//  NotificationsTests
//
//  Created by Alexandru Tudose on 19/03/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import XCTest
@testable import Notifications

extension Notifications {
    static let listDeleted = Notification<List, String>() // payload, identity of payload
    
    static let justAnEvent = Notification<Void, String>() // payload, identity of payload
    
    enum User {
        static let updated = Notification<User, String>() // payload, identity of payload
        static let deleted = Notification<User, String>() // payload, identity of payload
    }
}


struct List {
    var id: String
    var payload: String
}

class MyTesting {
    var observeListDeleted: Any?
    var observeJustAnEvent: Any?
    
    var identifier: String
    init(identifier: String) {
        self.identifier = identifier
    }
    
    var listDeletedTriggeredCount = 0
    var justAnEventTriggeredCount = 0
    func registerForNotifications() {
        observeListDeleted = Notifications.listDeleted.register(identifier: identifier) { [unowned self] list in
            print("Notifications.listDeleted")
            self.listDeletedTriggeredCount += 1
        }
        
        observeJustAnEvent = Notifications.justAnEvent.register { [unowned self] (_) in
            self.justAnEventTriggeredCount += 1
            print("Notifications.justAnEvent - no payload")
        }
        print(observeJustAnEvent!)
    }
    
    func registerForNotificationAsOwner() {
        Notifications.listDeleted.addObserver(self, identifier: identifier) { (self, list) in
            print("Notifications.listDeleted - registered by owner")
            self.listDeletedTriggeredCount += 1
        }
        
        Notifications.justAnEvent.addObserver(self) { (self) in
            self.justAnEventTriggeredCount += 1
        }
    }
    
    deinit {
        print("deinit", self)
    }
}


class NotificationsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testNotification() {
        var test: MyTesting! = MyTesting(identifier: "id")
        XCTAssert(test.listDeletedTriggeredCount == 0, "No events trigerred yet")
        test.registerForNotifications()
        XCTAssert(Notifications.listDeleted.observers.count == 1, "1 Observer registered")
        XCTAssert(Notifications.justAnEvent.observers.count == 1, "1 Observer registered")
        
        let list = List(id: "id", payload: "my payload")
        Notifications.listDeleted.post(list, identifier: list.id)
        XCTAssert(test.listDeletedTriggeredCount == 1, "listDeletedTriggeredCount = 1")
        Notifications.listDeleted.post(list, identifier: nil)
        XCTAssert(test.listDeletedTriggeredCount == 1, "listDeletedTriggeredCount = 1")
        Notifications.listDeleted.post(list, identifier: "2312")
        XCTAssert(test.listDeletedTriggeredCount == 1, "listDeletedTriggeredCount = 1")
        
        
        
        Notifications.justAnEvent.post()
        XCTAssert(test.justAnEventTriggeredCount == 1, "justAnEventTriggeredCount = 1")
        Notifications.justAnEvent.post(identifier: "custom_id")
        XCTAssert(test.justAnEventTriggeredCount == 2, "justAnEventTriggeredCount = 2")
        Notifications.justAnEvent.post((), identifier: nil)
        XCTAssert(test.justAnEventTriggeredCount == 3, "justAnEventTriggeredCount = 3")
        
        // test on deallocation
        test = nil
        XCTAssert(Notifications.listDeleted.observers.count == 0, "0 Observer registered")
        XCTAssert(Notifications.justAnEvent.observers.count == 0, "0 Observer registered")
        Notifications.listDeleted.post(list, identifier: list.id)
    }
    
    func testOwnerNotification() {
        var test: MyTesting! = MyTesting(identifier: "id")
        XCTAssert(test.listDeletedTriggeredCount == 0, "No events trigerred yet")
        test.registerForNotificationAsOwner()
        XCTAssert(Notifications.listDeleted.observers.count == 1, "1 Observer registered")
        XCTAssert(Notifications.justAnEvent.observers.count == 1, "0 Observer registered")
        
        let list = List(id: "id", payload: "my payload")
        Notifications.listDeleted.post(list, identifier: list.id)
        XCTAssert(test.listDeletedTriggeredCount == 1, "listDeletedTriggeredCount = 1")
        Notifications.listDeleted.post(list, identifier: nil)
        XCTAssert(test.listDeletedTriggeredCount == 1, "listDeletedTriggeredCount = 1")
        Notifications.listDeleted.post(list, identifier: "2312")
        XCTAssert(test.listDeletedTriggeredCount == 1, "listDeletedTriggeredCount = 1")
        
        Notifications.justAnEvent.post()
        XCTAssert(test.justAnEventTriggeredCount == 1, "justAnEventTriggeredCount = 1")
        
        // test on deallocation
        test = nil
        XCTAssert(Notifications.listDeleted.observers.count == 0, "0 Observer registered")
        XCTAssert(Notifications.justAnEvent.observers.count == 0, "0 Observer registered")
        Notifications.listDeleted.post(list, identifier: list.id)
    }
}
