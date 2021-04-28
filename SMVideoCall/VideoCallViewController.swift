//
//  VideoCallViewController.swift
//  SMVideoCall
//
//  Created by smartex on 14.04.2021.
//

import UIKit
import WebKit
import WKWebViewRTC
import AVFoundation

public class VideoCallViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler{
    
    public var baseUrl: String?
    
    public weak var delegate: VideoCallResultDelegate?
    
    var webView: WKWebView!
    var headphonesConnected: Bool = false
    
    public override func loadView() {
        if #available(iOS 14.3, *){}
        else{
            setupNotifications()
        }
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "endCallWV")
        contentController.add(self, name: "snapScreen")
        contentController.add(self, name: "switchToSpeaker")
        
        let webconfig = WKWebViewConfiguration()
        webconfig.allowsInlineMediaPlayback = true
        webconfig.mediaTypesRequiringUserActionForPlayback = []
        webconfig.userContentController = contentController
        webView = WKWebView(frame: .zero, configuration: webconfig)
        view = webView
    }
    
    func setupNotifications() {
        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleRouteChange),
                       name: AVAudioSession.routeChangeNotification,
                       object: nil)
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
               let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
               let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                   return
           }
           
           // Switch over the route change reason.
           switch reason {

           case .newDeviceAvailable: // New device found.
               let session = AVAudioSession.sharedInstance()
               headphonesConnected = hasHeadphones(in: session.currentRoute)
           
           case .oldDeviceUnavailable: // Old device removed.
               if let previousRoute =
                   userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                   headphonesConnected = hasHeadphones(in: previousRoute)
                   switchToSpeaker()
               }
           
           default: ()
           }
    }
    
    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        // Filter the outputs to only those with a port type of headphones.
        return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }
    
    
    func switchToSpeaker(){
        do{
           let session = AVAudioSession.sharedInstance()
           try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        }catch{
            print("SMVideoCall: \(error)")
         }
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.3, *){}
        else{
            WKWebViewRTC(wkwebview: webView, contentController: webView.configuration.userContentController)
        }
        let loadUrl = baseUrl!+"&sdk=ios&version=0.2.2"
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
        
        if message.name == "switchToSpeaker"{
            if #available(iOS 14.3, *){}
            else{
                if !headphonesConnected {
                    switchToSpeaker()
                }
            }
            
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

