//
//  TypedNotification.swift
//  TypedNotification
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

import Foundation

// Roughly based on https://github.com/alexjohnj/TypedNotification

/// The actual TypedNotification object is passed in the Foundation `Notification` object's `userInfo` dictionary under this key.
let kNotificationKey = "notification"

/// The `TypedNotification` protocol defines the properties of a strongly typed notification. The `name` property will be automatically generated from the type's name, but can be modified if needed.
public protocol TypedNotification {

    /// The name of the notification to be used as an identifier
    static var name: String { get }
}

/// Default implementation of protocol
extension TypedNotification {

    /// The name of the notification, defaulting to the type name
    public static var name: String {
        return "\(Self.self)"
    }

    /// The name of the notification for Foundation methods. Defaults to the value of the static `name` field.
    static var notificationName: Notification.Name {
        return Notification.Name(Self.name)
    }

    /// Creates a Foundation `Notification` with the specified sender.
    func notification(withSender sender: Any) -> Notification {
        return Notification(name: Self.notificationName, object: sender, userInfo: [kNotificationKey: self])
    }
}

/// An opaque `NotificationToken` used to add and remove observers of typed notifications. The object retains the token returned by `NotificationCenter.addObserver(for:object:queue:)` as well as the `NotificationCenter`. When the object is deallocated, we deregister the observer from the retained `NotificationCenter` using the retained token.
public class NotificationToken {

    /// The token returned by `NotificationCenter`.
    fileprivate let token: NSObjectProtocol

    /// The `NotificationCenter` that the handler was registered with.
    fileprivate let center: NotificationCenter

    /// Creates a new `NotificationToken` with the specified values.
    fileprivate init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }

    /// Deregisters the observer from the retained notification center using the retained token.
    deinit {
        center.removeObserver(token: self)
    }
}

/// TypedNotification extensions to NotificationCenter
extension NotificationCenter {

    /**
     Post a `TypedNotification` from the specified sender.

     - Parameters:
         - notification: the notification to post
         - sender: the sender of the notification
     */
    public func post<T: TypedNotification>(_ notification: T, from sender: Any) {
        post(notification.notification(withSender: sender))
    }

    /**
     Register a block to be executed when the specified `TypedNotification` type is posted.

     The API works like `NotificationCenter.addObserver(forName:object:queue:using:)`. Note that the returned `NotificationToken` must be retained. Once it is deallocated, the observer is deregistered.

     If the closure passed to this function references `self`, you must add `[weak self]` to the closure's capture list.

     Example:

     ```
     struct MyNotification: TypedNotification { ... }

     class MyViewController: UIViewController {
         private var notificationToken: NotificationToken?

         override func viewDidLoad() {
             super.viewDidLoad()

             notificationToken = NotificationCenter.default.addObserver(for: MyNotification.self) { [weak self] (notification) in
             self?.received(notification)
             }
         }

         private func received(_ notification: MyNotification) {
             ...
         }
     }
     ```

     In the example, `MyViewController` retains the `NotificationToken` returned by `NotificationCenter.addObserver()`. When the `MyViewController` instance is deallocated, the `NotificationToken` is deallocated and the observer is deregistered. The `[weak self]` capture list is important. Without it, there will be a retain cycle.

     - Parameters:
         - for: the `TypedNotification` subtype
         - object: The object from which you want to receive notifications. Pass `nil` to receive all notifications.
         - queue: The queue on which to execute the block. Per `NotificationCenter` documentation, if you pass `nil`, the block is run synchronously on the posting thread.
         - block: The block to be executed when the notification is received. The block takes a single instance of the `type` as an argument.

     - Returns:
         A `NotificationToken` object. The observer is automatically deregistered when this token object is deallocated, so be sure to retain a reference to it.
     */
    public func addObserver<T: TypedNotification>(for type: T.Type,
                                                  object: Any? = nil,
                                                  queue: OperationQueue? = nil,
                                                  using block: @escaping (T) -> Void) -> NotificationToken {

        let token = addObserver(forName: T.notificationName, object: object, queue: queue) { (notification) in
            guard let typedNotification = notification.userInfo?[kNotificationKey] as? T else {
                return
            }

            block(typedNotification)
        }

        return NotificationToken(token: token, center: self)
    }

    /**
     Filters incoming notifications, delivering only those that pass the `filter` block.

     This works similarly to `addObserver(for:object:queue:using:)` except that every incoming notification is passed to the `filter` block. If that block returns `true`, the handler block (i.e., the `using` parameter block) will be invoked.

     - Parameters:
         - for: the `TypedNotification` subtype
         - object: The object from which you want to receive notifications. Pass `nil` to receive all notifications.
         - queue: The queue on which to execute the block. Per `NotificationCenter` documentation, if you pass `nil`, the block is run synchronously on the posting thread.
         - filter: Filters incoming notifications. If `true` is returned, the notification is passed to `block`. If `false` is returned, the notification is dropped.
         - block: The block to be executed when the notification is received. The block takes a single instance of the `type` as an argument.

     - Returns:
         A `NotificationToken` object. The observer is automatically deregistered when this token object is deallocated, so be sure to retain a reference to it.
     */
    public func addObserver<T: TypedNotification>(for type: T.Type,
                                                  object: Any? = nil,
                                                  queue: OperationQueue? = nil,
                                                  filter: @escaping (T) -> Bool,
                                                  using block: @escaping (T) -> Void) -> NotificationToken {

        return addObserver(for: type, object: object, queue: queue) { notification in
            guard filter(notification) else {
                return
            }
            block(notification)
        }
    }

    /**
     Transforms incoming notifications.

     This works similarly to `addObserver(for:object:queue:using:)` except that every incoming notification is passed to the `map` block. The result of the `map` block is passed to the handler block (i.e., the `using` parameter block).

     - Parameters:
         - for: the `TypedNotification` subtype
         - object: The object from which you want to receive notifications. Pass `nil` to receive all notifications.
         - queue: The queue on which to execute the block. Per `NotificationCenter` documentation, if you pass `nil`, the block is run synchronously on the posting thread.
         - map: Transforms incoming notifications.
         - block: The block to be executed when the notification is received. The block takes a single instance of the output type of `map` as an argument.

     - Returns:
         A `NotificationToken` object. The observer is automatically deregistered when this token object is deallocated, so be sure to retain a reference to it.
     */
    public func addObserver<T: TypedNotification, V>(for type: T.Type,
                                                     object: Any? = nil,
                                                     queue: OperationQueue? = nil,
                                                     map transform: @escaping (T) -> V,
                                                     using block: @escaping (V) -> Void) -> NotificationToken {

        return addObserver(for: type, object: object, queue: queue) { notification in
            block(transform(notification))
        }
    }

    /**
     Transforms incoming notifications, filtering out `nil` values.

     This works similarly to `addObserver(for:object:queue:using:)` except that every incoming notification is passed to the `compactMap` block. Non-nil results of the `compactMap` block are passed to the handler block (i.e., the `using` parameter block).

     - Parameters:
         - for: the `TypedNotification` subtype
         - object: The object from which you want to receive notifications. Pass `nil` to receive all notifications.
         - queue: The queue on which to execute the block. Per `NotificationCenter` documentation, if you pass `nil`, the block is run synchronously on the posting thread.
         - compactMap: Transforms incoming notifications.  If a non-nil value is returned, that value is passed to `block`. If `nil` is returned, the notification is dropped.
         - block: The block to be executed when the notification is received. The block takes a single instance of the non-optional output type of `compactMap` as an argument.

     - Returns:
         A `NotificationToken` object. The observer is automatically deregistered when this token object is deallocated, so be sure to retain a reference to it.
     */
    public func addObserver<T: TypedNotification, V>(for type: T.Type,
                                                     object: Any? = nil,
                                                     queue: OperationQueue? = nil,
                                                     compactMap transform: @escaping (T) -> V?,
                                                     using block: @escaping (V) -> Void) -> NotificationToken {

        return addObserver(for: type, object: object, queue: queue) { notification in
            guard let value = transform(notification) else {
                return
            }
            block(value)
        }
    }

    /**
     Deregisters the observer associated with the specified token.

     - Parameters:
         - token: the token returned when adding the observer
     */
    public func removeObserver(token: NotificationToken) {
        removeObserver(token.token)
    }
}
