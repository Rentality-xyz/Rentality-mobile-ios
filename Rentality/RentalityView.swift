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
    var body: some View {
        RentalityWebView(url: URL(string: "https://app.rentality.xyz")!)
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct RentalityWebView: UIViewRepresentable {
    
    let url: URL
    
    // Создаем WKWebView
    func makeUIView(context: Context) -> WKWebView {
           let webView = WKWebView()
           webView.navigationDelegate = context.coordinator
           
           // Добавляем JavaScript для контроля прокрутки
           let scriptSource = """
           window.addEventListener('scroll', function() {
               const header = document.querySelector('header');
               if (window.scrollY > header.offsetHeight) {
                   window.webkit.messageHandlers.refreshHandler.postMessage('refresh');
               }
           });
           """
           let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
           webView.configuration.userContentController.addUserScript(script)
            webView.configuration.userContentController.add(context.coordinator as! WKScriptMessageHandler, name: "refreshHandler")

           // Загружаем начальный URL
           let request = URLRequest(url: url)
           webView.load(request)
           
           return webView
       }
    
    // Обновляем WKWebView, загружая нужный URL
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Координатор для делегирования событий WebView и управления обновлением
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: RentalityWebView
            
        init(_ parent: RentalityWebView) {
            self.parent = parent
        }
            
        // Обработка сообщений от JavaScript
               func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
                   if message.name == "refreshHandler", let _ = message.body as? String {
                       // Выполняем перезагрузку WebView
                       if let webView = message.webView {
                           webView.reload()
                       }
                   }
               }
            
        // Следим за завершением загрузки страницы, чтобы завершить обновление
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let refreshControl = webView.scrollView.refreshControl, refreshControl.isRefreshing {
                            refreshControl.endRefreshing()
            }
        }
    }
}
