//
//  WebView.swift
//  PaymentToolsDemo
//
//  Created by Andrei on 10.10.2025.
//

import SwiftUI
import WebKit
import Observation
import WebKit

typealias OnDidClose = (URL?) -> Void

struct PTWebView: View {

	let url: URL

	let onDidClose: OnDidClose?

	var body: some View {
		WebViewWrapper(url: url, onDidClose: onDidClose)
	}

}

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    let onDidClose: OnDidClose?

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.navigationDelegate = context.coordinator
        webview.uiDelegate = context.coordinator
        let request = URLRequest(url: url)
        webview.load(request)

        return webview
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Intentionally empty
    }

    func makeCoordinator() -> Coordinator {
        Coordinator { url in
            onDidClose?(url)
        }
    }
}

class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {

	let onDidClose: OnDidClose?

	var popupWebView: WKWebView?

	init(_ onDidClose: OnDidClose? = nil) {
		self.onDidClose = onDidClose
	}

	func webViewDidClose(_ webView: WKWebView) {
		onDidClose?(nil)
	}

	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
		if navigationAction.navigationType == .other {

			if let redirectedUrl = navigationAction.request.url {
				//do what you need with url
				//self.delegate?.openURL(url: redirectedUrl)
				print(redirectedUrl)

				if redirectedUrl.scheme == "finapi" {
					onDidClose?(redirectedUrl)
					decisionHandler(.cancel)
					return
				}
			}

			decisionHandler(.allow)

			return
		}
		
		decisionHandler(.allow)
	}

//	open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//		UIApplication.shared.isNetworkActivityIndicatorVisible = true
//	}
//
//	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//		UIApplication.shared.isNetworkActivityIndicatorVisible = false
//	}

}
