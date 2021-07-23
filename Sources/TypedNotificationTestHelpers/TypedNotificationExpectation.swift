//
//  TypedNotificationExpectation.swift
//  TypedNotificationTestHelpers
//
//  Copyright (c) 2021 Rocket Insights, Inc.
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

/**
 Adapts XCTNSNotificationExpectation to be fulfilled when a particular TypedNotification is received. Adds a `typedHandler` property that handles unpackaging the notification into the appropriate subtype.
 */
public class TypedNotificationExpectation<T: TypedNotification>: XCTNSNotificationExpectation {

    public typealias Handler = (T) -> Bool

    /**
     Creates an expectation that is fulfilled when a TypedNotification of the specified type is posted to the specified notification center.

     - Parameters:
        - for type: the `TypedNotification` subtype
        - object: The object from which you want to receive notifications. Pass `nil` to receive all notifications.
        - notificationCenter: The notification center from which the notification must be posted.
     */
    public init(for type: T.Type, object: Any? = nil, notificationCenter: NotificationCenter = .default) {
        super.init(name: T.notificationName, object: object, notificationCenter: notificationCenter)
    }

    /**
     An optional handler that performs custom evaluation of matching notifications. Your implementation should return `true` if the expectation is considered fulfilled after the notification is received, otherwise false.
     */
    public var typedHandler: Handler? {
        didSet {
            handler = { [weak self] (notification) -> Bool in
                guard let unpacked = T.unpack(from: notification) else {
                    return false
                }

                return self?.typedHandler?(unpacked) ?? true
            }
        }
    }
}
