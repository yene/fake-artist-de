// ViewController.swift

import UIKit
import WebKit
import Swifter
import WKdova

class ViewController: UIViewController {
	var webView: WKWebView?
		
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let publicFolder = Bundle.main.resourcePath! + "/dist"
		
		// You can server from iOS device with port 9080
		// or directly from the dev 8080
		guard let url = URL(string: "http://127.0.0.1:9080/index.html") else {
			print("Invalid URL")
			return
		}
		
		let server = HttpServer()
		server["/:path"] = shareFilesFromDirectory(publicFolder)
		server["/css/:path"] = shareFilesFromDirectory(publicFolder + "/css")
		server["/js/:path"] = shareFilesFromDirectory(publicFolder + "/js")
		server["/img/:path"] = shareFilesFromDirectory(publicFolder + "/img")
		
		// redirect to vue.js router (not in history mode) /404
		// vue router will handle non matches, for example: { path: '*', redirect: '/' }
		server.notFoundHandler = { request in
			print("Path not found", request.path)
			return .movedTemporarily("/index.html#/404")
		}
		
		do {
			try server.start(9080)
			print("Server has started ( port = \(try server.port()) ). Try to connect now...")
		} catch {
			print("Server start error: \(error)")
		}
		
		let webView = WKWebView(frame: .zero)
		webView.scrollView.contentInsetAdjustmentBehavior = .never;
		webView.backgroundColor = .white
		view.addSubview(webView)
		webView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
			webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
			webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
		])
		webView.scrollView.bounces = false;
		webView.isOpaque = false;
		webView.load(URLRequest(url: url))
		_ = WKdova(webView)
		
		// observer notification when keyboard will hide
		if #available(iOS 13, *) {
			// ios 13 or newer doesn't need the fix
		} else {
			NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
		}
		
	}
	
	// this method was trigger by selector keyboardWillHide from notification
	@objc func keyboardWillHide() {
		// BUG: 11.4.2019 There is a bug in iOS 12 where the keyboard does leave a gap after closing
		// https://github.com/apache/cordova-ios/issues/417
		self.webView!.subviews.forEach { (subview) in
			if let scrollView = subview as? UIScrollView {
				scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
			}
		}
	}
}

