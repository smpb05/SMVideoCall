//
//  VideoCallViewController.swift
//  SMVideoCall
//
//  Created by smartex on 14.04.2021.
//

import UIKit
import WebKit
import WKWebViewRTC

public class VideoCallViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler{
    
    public var baseUrl: String?
    
    public weak var delegate: VideoCallResultDelegate?
    
    var webView: WKWebView!
    
    public override func loadView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "endCallWV")
        
        let webconfig = WKWebViewConfiguration()
        webconfig.allowsInlineMediaPlayback = true
        webconfig.mediaTypesRequiringUserActionForPlayback = []
        webconfig.userContentController = contentController
        webView = WKWebView(frame: .zero, configuration: webconfig)
        view = webView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        WKWebViewRTC(wkwebview: webView, contentController: webView.configuration.userContentController)
        webView.load(URLRequest(url: URL(string: baseUrl!)!))
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        if message.name == "endCallWV" {
            guard let dict = message.body as? [String: AnyObject],
                  let code = dict["code"] as? Int else{
                return
            }
            delegate?.videoCallResultAvailable(code)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
}

