//
//  ViewController.swift
//  TheLuxuryShopper
//
//  Created by Omar Ezzat El-Etreby on 12/1/17.
//  Copyright © 2017 Etro. All rights reserved.
//

import UIKit
import MessageKit
import MapKit
import Alamofire

class ViewController: MessagesViewController {

    var messages: [MockMessage] = [] {
        didSet {
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    var uuid: String = "none"
    var api: Sender = Sender(id: "The Luxury Shopper", displayName: "The Luxury Shopper")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Alamofire.request("https://theluxuryshopper.herokuapp.com/welcome").responseJSON { response in
            if let json = response.result.value as? [String: AnyObject]{
                if let welcomeText = json["message"] as? String {
                    self.messages.append(MockMessage(text: welcomeText, sender: self.api, messageId: UUID().uuidString, date: Date()))
                }
                
                if let userId = json["uuid"] as? String {
                    self.uuid = userId
                }
            }
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        scrollsToBottomOnFirstLayout = true //default false
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: "Client", displayName: "You")
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    //Display Name
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    //Date
//    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        let dateString = formatter.string(from: message.sentDate)
//        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
//    }
}


// MARK: - MessagesDisplayDelegate

extension ViewController: MessagesDisplayDelegate, TextMessageDisplayDelegate {}

// MARK: - MessagesLayoutDelegate

extension ViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}


// MARK: - MediaMessageLayoutDelegate

extension ViewController: MediaMessageLayoutDelegate {}

// MARK: - MessageInputBarDelegate

extension ViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        messages.append(MockMessage(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date()))
        messagesCollectionView.scrollToBottom()
        
        //Sending reply
        let headers: HTTPHeaders = [
            "Authorization" : self.uuid,
            "Accept": "application/json"
        ]
        let parameters = ["message" : text]
        Alamofire.request("https://theluxuryshopper.herokuapp.com/chat", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let json = response.result.value as? [String: AnyObject] {
                if let response = json["message"] as? String {
                    //let modifiedResponse: String = response.replacingOccurrences(of: "<br>", with: "\n")
                    self.messages.append(MockMessage(text: response, sender: self.api, messageId: UUID().uuidString, date: Date()))
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }            
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom()
    }
    
}
