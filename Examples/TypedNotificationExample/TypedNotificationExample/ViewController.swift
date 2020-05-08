//
//  ViewController.swift
//  TypedNotificationExample
//
//  Copyright (c) 2019-2020 Rocket Insights, Inc.
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
import UIKit

class ViewController: UITableViewController {

    private var token: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        token = NotificationCenter.default.addObserver(for: TestNotification.self, queue: .main) { [weak self] notification in
            switch notification {
            case .eventA:
                self?.showMessage("Received eventA")

            case .eventB:
                self?.showMessage("Received eventB")

            case .eventC:
                self?.showMessage("Received eventC")
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.global(qos: .background).async {
            switch indexPath.row {
            case 0:
                NotificationCenter.default.post(TestNotification.eventA, from: self)
            case 1:
                NotificationCenter.default.post(TestNotification.eventB, from: self)
            case 2:
                NotificationCenter.default.post(TestNotification.eventC, from: self)
            default:
                break
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

