//
//  TypedNotificationTests.swift
//  TypedNotificationTests
//
//  Copyright (c) 2019 Rocket Insights, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import TypedNotification
import XCTest

class TypedNotificationTests: XCTestCase {

    private var token: NotificationToken?

    struct TestNotification: TypedNotification {
        var value: String
    }

    override func tearDown() {
        super.tearDown()

        // Ordinarily this occurs when deallocating the object. Explicitly here to test deregistration.
        token = nil
    }

    func testBehavior() {
        let exp = expectation(description: "notification received")

        token = NotificationCenter.default.addObserver(for: TestNotification.self, queue: .main) { notification in
            XCTAssertEqual(notification.value, "foobar")
            exp.fulfill()
        }

        DispatchQueue.global(qos: .background).async {
            NotificationCenter.default.post(TestNotification(value: "foobar"), from: self)
        }

        wait(for: [exp], timeout: 5)
    }
}
