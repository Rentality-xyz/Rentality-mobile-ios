//
//  RentalityView.swift
//  Rentality
//
//  Created by Danylo Vladyka on 23.10.2024.
//

import Foundation

import SwiftUI
import WebKit
import UIKit
import Network

struct RentalityView: View {
    @State var isLoading = true
    @StateObject var networkMonitor = NetworkMonitor()
    @State var reloadTrigger = false
    
    var body: some View {
        if networkMonitor.isConnected {
            RentalityLoadingView(isShowing: .constant(isLoading)) {
                RentalityWebView(
                    url: URL(string: "https://app.rentality.io")!,
                    isLoading: $isLoading,
                    reloadTrigger: $reloadTrigger
                )
                .edgesIgnoringSafeArea(.bottom)
            }
        } else {
            VStack(spacing: 16) {
                        Text("There seems to be a problem with your internet connection") // Локализуйте через Localizable.strings при необходимости
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.center)

                        Text("Please check it and try again")
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        GradientButton(action: {reloadTrigger.toggle()}, title: "Try again")

                        Image("car_404")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .padding(.top, 16)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 24/255, green: 9/255, blue: 55/255))
        }
    }
}

struct GradientButton: View {
    
    var action: () -> Void
    var title: String

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .fontWeight(.medium)

                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
            }
            .padding()
            .frame(width: 280)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 135/255, green: 108/255, blue: 245/255), Color(red: 143/255, green: 83/255, blue: 238/255)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(30) // Полностью закруглённая кнопка
        }
        .padding(.horizontal)
    }
}




class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = true
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}



struct RentalityLoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content
    var body: some View {
            ZStack {
                content()

                if isShowing {
                    ZStack {
                        Color(red: 24/255, green: 9/255, blue: 55/255) // #180937
                                    .edgesIgnoringSafeArea(.all)
                        
                        GIFImage(name: "platform_loader").frame(width: 300, height: 300)
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                }
            }
        }
    

}

struct GIFImage: UIViewRepresentable {
    private let name: String

    init(name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
                let imageView = UIImageView()
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                imageView.image = UIImage.gifImageWithName(name)

                container.addSubview(imageView)

                // Привязка imageView к границам container (UIView)
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                    imageView.topAnchor.constraint(equalTo: container.topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Ничего не обновляем
    }
}

struct RentalityWebView: UIViewRepresentable {
    let url: URL
    let webView: WKWebView
    @Binding var isLoading: Bool
    @Binding var reloadTrigger: Bool
    
    init(url: URL, isLoading: Binding<Bool>, reloadTrigger: Binding<Bool>) {
        self.url = url
        self.webView = WKWebView(frame: .zero)
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1 RentalityApp"
        self._isLoading = isLoading
        self._reloadTrigger = reloadTrigger
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        loadWebPage()
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if reloadTrigger {
            loadWebPage()
        }
    }

    private func loadWebPage() {
        let request = URLRequest(url: url)
        webView.load(request)
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

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}

