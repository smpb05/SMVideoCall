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
        contentController.add(self, name: "snapScreen")
        
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
        let loadUrl = baseUrl!+"&sdk=ios&version=0.1.1"
        webView.load(URLRequest(url: URL(string: loadUrl)!))
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
        
        if message.name == "snapScreen" {
            takeScreenShot()
        }
    }
    
    func takeScreenShot(){
        let bounds = UIScreen.main.bounds
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        self.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
        let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let base64 = convertImageToBase64String(img: screenshotImage!)
        let script = "window.onSnapScreen(\"\(base64)\")"
        webView.evaluateJavaScript(script) { (result, error) in
            if let result = result {
                print("Result: \(result)")
            } else if let error = error {
                print("An error occurred: \(error)")
            }
        }
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
}

