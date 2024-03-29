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
import AlamofireImage
import AudioToolbox

class ViewController: MessagesViewController {

    var messages: [MockMessage] = [] {
        didSet {
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    var uuid: String = "none"
    var isConnected: String = "false"
    var lastMessage: String = "none"
    var resultsCounter: Int = 0
    var api: Sender = Sender(id: "The Luxury Shopper", displayName: "The Luxury Shopper")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = [
            makeButton(named: "ic_hashtag").onTouchUpInside { _ in
                if(self.isConnected.isEqual("true")){
                    self.messages.append(MockMessage(text: "Done", sender: self.currentSender(), messageId: UUID().uuidString, date: Date()))
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                    //Setting up headers and parameters
                    let headers: HTTPHeaders = [
                        "Authorization" : self.uuid,
                        "Accept": "application/json"
                    ]
                    let parameters = ["message" : "Done"]
                    
                    Alamofire.request("https://theluxuryshopper.herokuapp.com/chat", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                        if let json = response.result.value as? [String: String] {
                            self.messages.append(MockMessage(text: json["message"]!, sender: self.api, messageId: UUID().uuidString, date: Date()))
                            self.lastMessage = json["message"]!
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom()
                        }
                        
                    }
                } else {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            },
            makeButton(named: "question").onTouchUpInside{_ in
                var reply = ""
                let arrayItems = ["Gucci t-shirt","Louis Vuitton belt", "Gucci hoodie", "gucci sneakers","Balenciaga sneakers","Fendi bag","Dsquared jeans"] as [String]
                let arrayConditions=["New","Used","None"] as [String]
                let arrayMinPrices=["none","100","200","300"] as [String]
                let arrayMaxPrices=["400","500","600"] as [String]
                if (self.lastMessage).isEqual("Welcome to The Luxury Shopper.\nWhat are you looking for? say something like 'Gucci Tshirt' ") || (self.lastMessage).hasSuffix("What else would you like to search for? ") || (self.lastMessage).hasSuffix("What else would you like to search for?") || (self.lastMessage).hasSuffix("What are you looking for? say something like 'Gucci Tshirt'"){
                    let index = Int(arc4random_uniform(UInt32(arrayItems.count)))
                    reply = arrayItems[index]
                }
                if (self.lastMessage).isEqual("Please specify the condition of the required item. (New, Used or None)"){
                    let index = Int(arc4random_uniform(UInt32(arrayConditions.count)))
                    reply = arrayConditions[index]
                }
                if (self.lastMessage).isEqual("Please specify the minimum price of the required item. (None in case you dont want to filter with minimum price)"){
                    let index = Int(arc4random_uniform(UInt32(arrayMinPrices.count)))
                    reply = arrayMinPrices[index]
                }
                if (self.lastMessage).isEqual("Please specify the maximum price of the required item. (None in case you dont want to filter with maximum price)"){
                    let index = Int(arc4random_uniform(UInt32(arrayMaxPrices.count)))
                    reply = arrayMaxPrices[index]
                }
                
                if(self.isConnected.isEqual("true")){
                    self.messages.append(MockMessage(text: reply, sender: self.currentSender(), messageId: UUID().uuidString, date: Date()))
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                    //Setting up headers and parameters
                    let headers: HTTPHeaders = [
                        "Authorization" : self.uuid,
                        "Accept": "application/json"
                    ]
                    let parameters = ["message" : reply]
                    
                    Alamofire.request("https://theluxuryshopper.herokuapp.com/chat", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                        if let json = response.result.value as? [String: AnyObject] {
                                if let items = json["items"] as? [[String: String]] {
                                    var responseString: String = ""
                                    var itemsArray: [String: UIImage] = [:]
                                    for (index,item) in items.enumerated() {
                                        var imageURL: String = item["GalleryURL"]!
                                        var modifiedImageURL: String = imageURL.replacingOccurrences(of:"http", with:"https")
                                        Alamofire.request(modifiedImageURL).responseImage { responseImage in
                                            if let image = responseImage.result.value {
                                                responseString = "Title: " + item["Title"]! + "\nCondition: " + item["Condition"]! + "\nPrice: " + item["Price"]! + " " + item["Currency"]! + "\nItem URL: " + item["ItemURL"]!.replacingOccurrences(of:"http", with:"https")+"\n"
                                                self.messages.append(MockMessage(text: responseString, sender: self.api, messageId: UUID().uuidString, date: Date()))
                                                self.messages.append(MockMessage(image: image, sender: self.api, messageId: UUID().uuidString, date: Date()))
                                                self.lastMessage = responseString
                                                self.messagesCollectionView.reloadData()
                                                self.messagesCollectionView.scrollToBottom()
                                                self.resultsCounter+=1
                                                if(self.resultsCounter>=items.count) {
                                                    self.messages.append(MockMessage(text: "What else would you like to search for?", sender: self.api, messageId: UUID().uuidString, date: Date()))
                                                    self.lastMessage = "What else would you like to search for?"
                                                    self.messagesCollectionView.reloadData()
                                                    self.messagesCollectionView.scrollToBottom()
                                                    self.resultsCounter = 0
                                                }
                                            }
                                        }
                                        
                                    }
                                } else if let response = json["message"] as? String {
                                    self.messages.append(MockMessage(text: response, sender: self.api, messageId: UUID().uuidString, date: Date()))
                                    self.lastMessage = response
                                    self.messagesCollectionView.reloadData()
                                    self.messagesCollectionView.scrollToBottom()
                                }
                            
                        }
                        
                    }
                } else {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                
                
                
            }
        ]
        //let rightItems = [makeButton(named: "generate").onTouchUpInside{_ in}] 26
            
        
        messageInputBar.setLeftStackViewWidthConstant(to: 60, animated: false)
        messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
       // messageInputBar.setRightStackViewWidthConstant(to: 26, animated: false)
       // messageInputBar.setStackViewItems(rightItems, forStack: .right, animated: false)
        
        // Do any additional setup after loading the view, typically from a nib.
        messages.append(MockMessage(text: "Connecting...", sender: self.api, messageId:UUID().uuidString, date: Date()))
        Alamofire.request("https://theluxuryshopper.herokuapp.com/welcome").responseJSON { response in
            if let json = response.result.value as? [String: AnyObject]{
                if let welcomeText = json["message"] as? String {
                    self.messages.remove(at: 0)
                    self.messages.append(MockMessage(text: welcomeText, sender: self.api, messageId: UUID().uuidString, date: Date()))
                    self.isConnected = "true"
                    self.lastMessage = welcomeText
                    print(self.isConnected)
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
    
    // MARK: - Helpers
    
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
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
    
//    Date
//    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        let dateString = formatter.string(from: message.sentDate)
//        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
//    }
}


// MARK: - MessagesDisplayDelegate

extension ViewController: MessagesDisplayDelegate, TextMessageDisplayDelegate {
    //Adding bubble tail
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .pointedEdge)
    }
    
    
}

// MARK: - MessagesLayoutDelegate

extension ViewController: MessagesLayoutDelegate {
    //Removing avatar by setting itts size to zero
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}


// MARK: - MediaMessageLayoutDelegate

extension ViewController: MediaMessageLayoutDelegate {}

// MARK: - MessageInputBarDelegate

extension ViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        if(self.isConnected.isEqual("true")){
            messages.append(MockMessage(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date()))
            inputBar.inputTextView.text = String()
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToBottom()
            
            //Setting up headers and parameters
            let headers: HTTPHeaders = [
                "Authorization" : self.uuid,
                "Accept": "application/json"
            ]
            let parameters = ["message" : text]
            
            //Sending reply
            Alamofire.request("https://theluxuryshopper.herokuapp.com/chat", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if let json = response.result.value as? [String: AnyObject] {
                    if let items = json["items"] as? [[String: String]] {
                        var responseString: String = ""
                        var itemsArray: [String: UIImage] = [:]
                        for (index,item) in items.enumerated() {
                            var imageURL: String = item["GalleryURL"]!
                            var modifiedImageURL: String = imageURL.replacingOccurrences(of:"http", with:"https")
                            Alamofire.request(modifiedImageURL).responseImage { responseImage in
                                if let image = responseImage.result.value {
                                    responseString = "Title: " + item["Title"]! + "\nCondition: " + item["Condition"]! + "\nPrice: " + item["Price"]! + " " + item["Currency"]! + "\nItem URL: " + item["ItemURL"]!.replacingOccurrences(of:"http", with:"https") + "\n"
                                    self.messages.append(MockMessage(text: responseString, sender: self.api, messageId: UUID().uuidString, date: Date()))
                                    self.messages.append(MockMessage(image: image, sender: self.api, messageId: UUID().uuidString, date: Date()))
                                    self.messagesCollectionView.reloadData()
                                    self.messagesCollectionView.scrollToBottom()
                                    self.resultsCounter+=1
                                    if(self.resultsCounter>=items.count) {
                                        self.messages.append(MockMessage(text: "What else would you like to search for?", sender: self.api, messageId: UUID().uuidString, date: Date()))
                                        self.lastMessage = "What else would you like to search for?"
                                        self.messagesCollectionView.reloadData()
                                        self.messagesCollectionView.scrollToBottom()
                                        self.resultsCounter = 0
                                    }
                                }
                            }
                            
                        }
                    } else if let response = json["message"] as? String {
                        self.messages.append(MockMessage(text: response, sender: self.api, messageId: UUID().uuidString, date: Date()))
                        self.lastMessage = response
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
            }
        } else {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
