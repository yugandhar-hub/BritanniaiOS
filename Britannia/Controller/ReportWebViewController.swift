//
//  ReportWebViewController.swift
//  Britannia
//
//  Created by Admin on 21/02/21.
//

import UIKit
import WebKit

class ReportWebViewController: UIViewController {

    var webView: WKWebView!
    @IBOutlet weak var btnItem: UIBarButtonItem!
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = webView
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
            webView.navigationDelegate = self
        }
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.viewController = self
        btnItem.image = UIImage(named: "FullScreen")
    }
    
    @IBAction func fullScreen(_ sender: Any) {
        let btn = sender as! UIBarButtonItem
        if btn.tag == 0{
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            btn.tag = 1
        } else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            btn.tag = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        let value = UIInterfaceOrientation.landscapeRight.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.viewController = nil
    }
    
}

extension ReportWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let user = "projectai@brtindia.com"
        let password = "AIBRIT@2020"
        let credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
        challenge.sender?.use(credential, for: challenge)
//        if let urlStr =  webView.url?.absoluteString, challenge.protectionSpace.host == urlStr {
//            let user = "projectai@brtindia.com"
//            let password = "AIBRIT@2020"
//            let credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
//            challenge.sender?.use(credential, for: challenge)
//        }
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if let url = webView.url, url.absoluteString.contains("signin") {
            let fillForm = "document.getElementsById('textbox-username-input')[0].value = 'projectai@brtindia.com'"
            let fillForm1 = "document.getElementsByName('Password')[0].value = 'AIBRIT@2020'"
            webView.evaluateJavaScript(fillForm, completionHandler: {_,_ in
                webView.evaluateJavaScript(fillForm1, completionHandler: nil)
            })
        }
    }
}


