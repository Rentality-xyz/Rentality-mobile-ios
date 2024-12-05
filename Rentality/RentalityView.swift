//
//  RentalityView.swift
//  Rentality
//
//  Created by Danylo Vladyka on 23.10.2024.
//

import Foundation


import SwiftUI
import WebKit

struct RentalityView: View {
    
    @State var isLoading = true
    var body: some View {
        RentalityLoadingView(isShowing: .constant(isLoading)) {
            RentalityWebView(url: URL(string: "https://app.rentality.xyz")!, isLoading: $isLoading)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct RentalityLoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                ActivityIndicator(isAnimating: $isShowing, style: .large)

                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct RentalityWebView: UIViewRepresentable {

    
    let url: URL
    
    let webView: WKWebView
    
    @Binding var isLoading: Bool
        
    init(url: URL, isLoading: Binding<Bool>) {
        self.url = url
        self.webView = WKWebView(frame: .zero)
        self.webView.allowsBackForwardNavigationGestures = true
        self._isLoading = isLoading
    }
        
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.reloadWebView(_:)), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, isLoading: $isLoading)
    }
    
   
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        
        var parent: RentalityWebView
        @Binding var isLoading: Bool
            
        init(_ parent: RentalityWebView, isLoading: Binding<Bool>) {
            self.parent = parent
            self._isLoading = isLoading
        }
        
        @objc func reloadWebView(_ sender: UIRefreshControl) {
            parent.webView.reload()
            sender.endRefreshing()
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                let url = navigationAction.request.url?.absoluteString ?? ""
            
                if navigationAction.targetFrame == nil {
                    webView.load(navigationAction.request)
                }
                if url.starts(with: "http://") || url.starts(with: "https://") {
                    decisionHandler(.allow)
                } else {
                    if let url = navigationAction.request.url {
                        if url.scheme == "intent" {
                            // Handle intent scheme if necessary
                        } else {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                    decisionHandler(.cancel)
                }
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }

            return nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.isLoading = false
        }
        
            
    }
}
