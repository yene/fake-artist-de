// ViewController.swift

import UIKit
import WebKit
import GCDWebServers
import WKdova

class ViewController: UIViewController {
	var webView: WKWebView?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let fileManager = FileManager.default
		
		do {
			let publicFolder = Bundle.main.resourcePath! + "/dist"
			let fileURLs = try fileManager.contentsOfDirectory(atPath: publicFolder)
			print(fileURLs)
			
			
			GCDWebServer.setLogLevel(4)
			let webServer = GCDWebServer()
			
			webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
				return GCDWebServerDataResponse(html:"<html><body><h1>File not Found</h1></body></html>")
			})
			// Note: if your content does update, if you keep getting the same CSS, on each opening of the app you may want to use cacheAge: 0
			var cacheAge = 3600
			#if DEBUG
			cacheAge = 0
			#endif
			webServer.addGETHandler(forBasePath: "/", directoryPath: publicFolder, indexFilename: "index.html", cacheAge: 3600, allowRangeRequests: true)
			
			webServer.start(withPort: 9080, bonjourName: "GCD Web Server")
		} catch {
			print("Unexpected error: \(error).")
			return
		}
		
		// Note: Safari cache persists over restart, we have to clear it to see changes.
		#if DEBUG
		let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
		let date = Date(timeIntervalSince1970: 0)
		WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date, completionHandler:{ })
		#endif
		
		let contentController = WKUserContentController()
		let config = WKWebViewConfiguration()
		config.userContentController = contentController
		let webView = WKWebView(frame: .zero, configuration: config)
		webView.backgroundColor = .white
		view.addSubview(webView)
		
		webView.translatesAutoresizingMaskIntoConstraints = false
		webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		webView.scrollView.bounces = false;
		webView.isOpaque = false;
		
		if let url = URL(string: "http://localhost:9080/index.html") {
			webView.load(URLRequest(url: url))
		}

		self.webView = webView
		_ = WKdova(webView)
		
		// observer notification when keyboard will hide
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
		
	}
	// this method was trigger by selector keyboardWillHide from notification
	@objc func keyboardWillHide() {
		// BUG: 11.4.2019 There is a bug in iOS 12 where the keyboard does leave a gap after closing
		// https://github.com/apache/cordova-ios/issues/417
		if #available(iOS 12, *) {
			self.webView!.subviews.forEach { (subview) in
				if let scrollView = subview as? UIScrollView {
					scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
				}
			}
		}
	}
}

