//
//  WebView.swift
//  Rentality
//
//  Created by Danylo Vladyka on 28.05.2024.
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    var link: String
    
    let webView: WKWebView = WKWebView()
    
    init(link: String) {
        self.link = link
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh), for: .valueChanged)
                
    // Встраиваем refreshControl в ScrollView WebView
        webView.scrollView.refreshControl = refreshControl
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: link) {
            uiView.load(URLRequest(url: url))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
                    if let webView = refreshControl.superview as? WKWebView {
                        webView.reload() // Перезагружаем WebView
                    }
                    refreshControl.endRefreshing() // Завершаем обновление
                }
                
                // Следим за завершением загрузки страницы, чтобы завершить обновление
                func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                    if let refreshControl = webView.scrollView.refreshControl, refreshControl.isRefreshing {
                        refreshControl.endRefreshing() // Завершаем анимацию обновления после загрузки
                    }
                }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.targetFrame == nil {
                        webView.load(navigationAction.request)
            }
            decisionHandler(.allow)
        }
        

    }
}





//struct WebView: UIViewRepresentable {
//    
//    var link: String
// 
//    let webView: WKWebView
//    
//    init(link: String) {
//        webView = WKWebView(frame: .zero)
//        self.link = link
//    }
//    
//    
//    func makeUIView(context: Context) -> WKWebView {
//        return webView
//    }
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        webView.load(URLRequest(url: URL(string: link)!))
////    }
//   
//}


struct Start: View {
    @State var howtoplay = false
    @State var countsss = [""]
    @State var candystring = ""
    @State var candyboolean = false
    @State var firstOpen = false
    @State var buttonvisibletwo = false
    @State var buttonvisible = UserDefaults.standard.bool(forKey: "buttonvisible")
    @ObservedObject var webViewStateModel: BbvsdujhgewGjvhsbdv = BbvsdujhgewGjvhsbdv()
    @State var orientationView = false
   @State var linkSaveFb = UserDefaults.standard.string(forKey: "linkSaveFb")
    var body: some View {
        LoadingView(isShowing: .constant(webViewStateModel.loading)) {
            Gugusdighkjf(url: URL(string: "https://app.rentality.xyz")!, webViewStateModel: self.webViewStateModel).edgesIgnoringSafeArea(.bottom)
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

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content
//    @StateObject var globalString = GlobalString()
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                //Image("background").resizable().ignoresSafeArea().disabled(self.isShowing).opacity(self.isShowing ? 1 : 0)
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



class BbvsdujhgewGjvhsbdv: ObservableObject {
    @Published var pageTitle: String = "Web View"
        @Published var loading: Bool = true
        @Published var canGoBack: Bool = false
        @Published var goBack: Bool = false
        @Published var homePage: Bool = false
        @Published var goHome: Bool = false
    @Published var testSaveLink: String = "Web View"
    @Published var saveLinkHome = UserDefaults.standard.string(forKey: "savelink")
    @Published var countpopup = UserDefaults.standard.integer(forKey: "counterpoup")
    @Published var firstOpenApp = UserDefaults.standard.bool(forKey: "firstOpenApp")
    @Published var buttonopen = UserDefaults.standard.bool(forKey: "buttonopen")
    @Published var bottonweb = UserDefaults.standard.bool(forKey: "bottonweb")
    @Published var counterSaveWebView: Int = 0
//    @Published var goForward: Bool = false
        @Published var canGoHome: Bool = false
}




struct Gugusdighkjf: View {
    @State var orientation = UIDevice.current.orientation

        let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
     enum NavigationAction {
           case decidePolicy(WKNavigationAction,  (WKNavigationActionPolicy) -> Void)
           case didRecieveAuthChallange(URLAuthenticationChallenge, (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
           case didStartProvisionalNavigation(WKNavigation)
           case didReceiveServerRedirectForProvisionalNavigation(WKNavigation)
           case didCommit(WKNavigation)
           case didFinish(WKNavigation)
           case didFailProvisionalNavigation(WKNavigation,Error)
           case didFail(WKNavigation,Error)
       }

    @ObservedObject var tquicsdujhbc: BbvsdujhgewGjvhsbdv
//    @StateObject var globalString = GlobalString()
    @State var paddingOrientation = 0
    private var actionDelegate: ((_ navigationAction: Gugusdighkjf.NavigationAction) -> Void)?
    let ytqwghjavsdb: URLRequest
    @State private var themeObservation: NSKeyValueObservation?
    @State private var isPortrait = false
    @Environment(\.colorScheme) var colorScheme
    var body: some View {

        ZStack{

            VStack{

            Ykbsdhjkbnsdf(hwgvfbdsfbvweghjb: tquicsdujhbc,
                           action: actionDelegate,
                           request: ytqwghjavsdb).zIndex(99)
            }

        }.onAppear(){
            //AppDelegate.orientationLock = UIInterfaceOrientationMask.all
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }

        .onReceive(orientationChanged) { _ in
            self.orientation = UIDevice.current.orientation
        }

    }

    init(uRLRequest: URLRequest, webViewStateModel: BbvsdujhgewGjvhsbdv) {
        self.ytqwghjavsdb = uRLRequest
        self.tquicsdujhbc = webViewStateModel
    }

    init(url: URL, webViewStateModel: BbvsdujhgewGjvhsbdv) {
        self.init(uRLRequest: URLRequest(url: url),
                  webViewStateModel: webViewStateModel)
    }


}


struct Ykbsdhjkbnsdf : UIViewRepresentable {

    @ObservedObject var ujhebfksdmfb: BbvsdujhgewGjvhsbdv
//    @StateObject var globalString = GlobalString()
    let action: ((_ navigationAction: Gugusdighkjf.NavigationAction) -> Void)?
    @State private var themeObservation: NSKeyValueObservation?
    @State var underPageBackgroundColor: UIColor!
    let request: URLRequest
  @State private var asvgujhdsbf: WKWebView?

    init(hwgvfbdsfbvweghjb: BbvsdujhgewGjvhsbdv,
    action: ((_ navigationAction: Gugusdighkjf.NavigationAction) -> Void)?,
    request: URLRequest) {
        self.action = action
        self.request = request
        self.ujhebfksdmfb = hwgvfbdsfbvweghjb
        self.asvgujhdsbf = WKWebView()
        self.asvgujhdsbf?.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.asvgujhdsbf?.scrollView.backgroundColor = UIColor(red:0.11, green:0.13, blue:0.19, alpha:1)
        self.asvgujhdsbf = WKWebView()

        self.asvgujhdsbf?.isOpaque = false
        viewDidLoad()

    }
    func viewDidLoad() {

        self.asvgujhdsbf?.backgroundColor = UIColor.black
        if #available(iOS 15.0, *) {
            themeObservation = asvgujhdsbf?.observe(\.themeColor) {  webView, _ in
                self.asvgujhdsbf?.backgroundColor = webView.themeColor ?? .systemBackground

            }
        } else {
            // Fallback on earlier versions
        }
     }
    func makeUIView(context: Context) -> WKWebView  {
        var view = WKWebView()
        let wkPreferences = WKPreferences()
        @ObservedObject var webViewStateModel: BbvsdujhgewGjvhsbdv
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true

        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.preferences = wkPreferences
        view = WKWebView(frame: .zero, configuration: configuration)
        view.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        view.load(request)



        return view
    }

     func updateUIView(_ uiView: WKWebView, context: Context) {


         self.asvgujhdsbf = WKWebView()

        if uiView.canGoBack, ujhebfksdmfb.goBack {
            uiView.goBack()
            ujhebfksdmfb.goBack = false

        }


    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(action: action, webViewStateModel: ujhebfksdmfb)
    }

    final class Coordinator: NSObject {
        var popupWebView: WKWebView?
        @AppStorage("FirstOpening") var firstOpen = true
        @AppStorage("DestinationLink") var destLink: String = ""
        @ObservedObject var wewhjfttyuwyjghbsd: BbvsdujhgewGjvhsbdv
        let action: ((_ navigationAction: Gugusdighkjf.NavigationAction) -> Void)?

        init(action: ((_ navigationAction: Gugusdighkjf.NavigationAction) -> Void)?,
             webViewStateModel: BbvsdujhgewGjvhsbdv) {
            self.action = action
            self.wewhjfttyuwyjghbsd = webViewStateModel
        }

    }
}

extension Ykbsdhjkbnsdf.Coordinator: WKNavigationDelegate, WKUIDelegate {
//    func webView(_ uyhdsfuygf: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//
//        uyhdsfuygf.evaluateJavaScript("window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open);", completionHandler: nil)
//        uyhdsfuygf.evaluateJavaScript("window.close = function() { window.location.href = 'myapp://closewebview'; }", completionHandler: nil)
//        
//        if let url = navigationAction.request.url {
//                    // Проверяем, является ли ссылка ссылкой на стороннее приложение
//                    if url.scheme == "trust" || url.scheme == "tel" || url.scheme == "tg" || url.scheme == "twitter" {
//                        // Открываем стороннее приложение
//                        if UIApplication.shared.canOpenURL(url) {
//                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                            decisionHandler(.cancel)
//                            return
//                        }
//                    }
//                }
//                
//                // Если ссылка не ведет на стороннее приложение, продолжаем загрузку в WebView
//                decisionHandler(.allow)
//        
////        if action == nil {
////            decisionHandler(.allow)
////        } else {
////            action?(.decidePolicy(navigationAction, decisionHandler))
////        }
//    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//
//        if navigationAction.targetFrame == nil {
//            webView.load(navigationAction.request)
//        }
//        decisionHandler(.allow)
//    }
    
    
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

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        action?(.didStartProvisionalNavigation(navigation))
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        action?(.didReceiveServerRedirectForProvisionalNavigation(navigation))

    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        wewhjfttyuwyjghbsd.loading = false
        wewhjfttyuwyjghbsd.canGoBack = webView.canGoBack
        action?(.didFailProvisionalNavigation(navigation, error))
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        action?(.didCommit(navigation))
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.uiDelegate = self
        if let frame = navigationAction.targetFrame,
            frame.isMainFrame {
            return nil
        }
//        webView.load(navigationAction.request)
        return nil


    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        wewhjfttyuwyjghbsd.loading = false

        wewhjfttyuwyjghbsd.buttonopen = true
        UserDefaults.standard.set(wewhjfttyuwyjghbsd.buttonopen, forKey: "buttonopen")

        webView.allowsBackForwardNavigationGestures = true
        wewhjfttyuwyjghbsd.canGoBack = webView.canGoBack
        if let title = webView.title {
            wewhjfttyuwyjghbsd.pageTitle = title
        }

        webView.configuration.mediaTypesRequiringUserActionForPlayback = .all
        webView.configuration.allowsInlineMediaPlayback = false
        webView.configuration.allowsAirPlayForMediaPlayback = false
        action?(.didFinish(navigation))

        guard let destinationUrl = webView.url?.absoluteURL.absoluteString else {

            return
        }


        destLink = destinationUrl


        var components = URLComponents(string: destinationUrl)!
        components.query = nil
        let cutUrl = components.url!.absoluteString

        if cutUrl == "https://www.google.com.com/" {
            UserDefaults.standard.set(false, forKey: "ShowPromo")
        } else {
            wewhjfttyuwyjghbsd.saveLinkHome = destLink
//            UserDefaults.standard.set(webViewStateModel.saveLinkHome, forKey: "savelink")
            if self.firstOpen {


                wewhjfttyuwyjghbsd.firstOpenApp = true
                UserDefaults.standard.set(wewhjfttyuwyjghbsd.firstOpenApp, forKey: "firstOpenApp")
                self.firstOpen = false

            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        wewhjfttyuwyjghbsd.loading = false
        action?(.didFail(navigation, error))
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if action == nil  {
            completionHandler(.performDefaultHandling, nil)
        } else {
            action?(.didRecieveAuthChallange(challenge, completionHandler))
        }

    }


    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            popupWebView?.removeFromSuperview()
            popupWebView = nil
        }
    }

}

