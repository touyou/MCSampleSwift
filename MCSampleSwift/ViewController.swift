//
//  ViewController.swift
//  MCSampleSwift
//
//  Created by 藤井陽介 on 2016/07/24.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import MultipeerConnectivity

final class ViewController: UIViewController {

    let serviceType = "LCOC-Chat"

    var browser: MCBrowserViewController!
    var assisant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!

    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var messageField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // セッションの設定
        peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        session = MCSession(peer: peerID)
        session.delegate = self
        // ブラウザーの設定
        browser = MCBrowserViewController(serviceType: serviceType, session: session)
        browser.delegate = self
        // アシスタントの設定
        assisant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        assisant.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: 送信
    @IBAction func sendChat(sender: UIButton) {
        let msg = messageField.text?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

        do {
            try session.sendData(msg!, toPeers: session.connectedPeers, withMode: .Unreliable)
        } catch let error as NSError {
            print("Error sending data: \(error.localizedDescription)")
        }

        updateChat(messageField.text ?? "", fromPeer: peerID)

        messageField.text = ""
    }
    // MARK: 更新
    func updateChat(text: String, fromPeer peerID: MCPeerID) {
        var name: String

        switch peerID {
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
        }

        let message = "\(name): \(text)\n"
        chatView.text = chatView.text + message
    }
    // MARK: ブラウザの表示
    @IBAction func showBrowser(sender: UIButton) {
        presentViewController(browser, animated: true, completion: nil)
    }
}
// MARK: - MCBrowserViewControllerDelegate
extension ViewController: MCBrowserViewControllerDelegate {
    // MARK: 完了が押された時
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: キャンセルが押された時
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
// MARK: - MCSessionDelegate
extension ViewController: MCSessionDelegate {
    // MARK: データを受信した時
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        dispatch_sync(dispatch_get_main_queue()) {
            let msg = NSString(data: data, encoding: NSUTF8StringEncoding)
            self.updateChat(msg as! String, fromPeer: peerID)
        }
    }
    // MARK: データを受信し始めた時
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
    }
    // MARK: データを受信し終わった時
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
    }
    // MARK: ストリームが確立ci された時
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    // MARK: 他のpeerの状態が変化した時
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
    }
}
