//////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////


import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

//你可以测试你的例子集成，说siri:
// "使用<my app>发送消息"
// "<my app>约翰说你好"
// "在<my app>中搜索消息"

class IntentHandler: INExtension {
  override func handler(for intent: INIntent) -> Any {
    //这是默认实现。如果你想让不同的对象处理不同的意图，你可以重写这个，并返回你想要的那个特定意图的处理程序。
    guard intent is PingIntent else {
      fatalError("Unhandled Intent error : \(intent)")
    }
    return PingIntentHandler()
  }
}

// PingIntentHandling：是由 Intents 中的配置自动生成
class PingIntentHandler:NSObject, PingIntentHandling {
  
  // MARK:- PingIntentHandling 代理
  // 处理完整的意图(必需的)
  func handle(intent: PingIntent, completion: @escaping (PingIntentResponse) -> Void) {
    // 在这里实现应用程序逻辑以发送消息
//    let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
//    let response = PingIntentResponse(code: .continueInApp, userActivity: userActivity) //.continueInApp
//    completion(response)
//    
    if let hostname = intent.hostname, let time = intent.times {
        //获取捷径的数据
        sshCmd(hostname: hostname)
        // 响应捷径的数据
        completion(PingIntentResponse.success(timeOfInvoices:time))
    }
  }
  
  func sshCmd(hostname:String) {
    //TODO: 要做的事情
    
  }
  // 解析参数
  // MARK: - INSendMessageIntentHandling 代理
  // 实现解析方法以提供有关您的意图的附加信息(可选)。
  func resolveHostname(for intent: PingIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let hostname = intent.hostname else {
        completion(INStringResolutionResult.needsValue())
        return
    }
    completion(INStringResolutionResult.success(with: hostname))
  }
  
  func resolveTimes(for intent: PingIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let times = intent.times else {
        completion(INStringResolutionResult.needsValue())
        return
    }
    completion(INStringResolutionResult.success(with: times))
  }
}

// 完成demo
class initdemo: INExtension, INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling{
  
  // MARK: - INSendMessageIntentHandling
    
    // 实现解析方法以提供有关您的意图的附加信息(可选)。
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
        if let recipients = intent.recipients {
            
            // 如果没有提供收件人，则需要提示输入值
            if recipients.count == 0 {
                completion([INSendMessageRecipientResolutionResult.needsValue()])
                return
            }
            
            var resolutionResults = [INSendMessageRecipientResolutionResult]()
            for recipient in recipients {
                let matchingContacts = [recipient] // Implement your contact matching logic here to create an array of matching contacts
                switch matchingContacts.count {
                case 2  ... Int.max:
                    // We need Siri's help to ask user to pick one from the matches.
                    resolutionResults += [INSendMessageRecipientResolutionResult.disambiguation(with: matchingContacts)]
                    
                case 1:
                    // We have exactly one matching contact
                    resolutionResults += [INSendMessageRecipientResolutionResult.success(with: recipient)]
                    
                case 0:
                    // We have no contacts matching the description provided
                    resolutionResults += [INSendMessageRecipientResolutionResult.unsupported()]
                    
                default:
                    break
                    
                }
            }
            completion(resolutionResults)
        } else {
            completion([INSendMessageRecipientResolutionResult.needsValue()])
        }
    }
    
    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    // 一旦解决完成，对意图执行验证并提供确认(可选)。
    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
        completion(response)
    }
    
    // Handle the completed intent (required).
    
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // 在这里实现应用程序逻辑以发送消息
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }
    
    // 为你想处理的每个意图实现处理程序。作为消息示例，您可能还希望处理消息搜索和设置消息属性。
    // MARK: - INSearchForMessagesIntentHandling
    func handle(intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
        // 实现应用程序逻辑以查找与意图中的信息匹配的消息。
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
        let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)
        // Initialize with found message's attributes
        response.messages = [INMessage(
            identifier: "identifier",
            content: "I am so excited about SiriKit!",
            dateSent: Date(),
            sender: INPerson(personHandle: INPersonHandle(value: "sarah@example.com", type: .emailAddress), nameComponents: nil, displayName: "Sarah", image: nil,  contactIdentifier: nil, customIdentifier: nil),
            recipients: [INPerson(personHandle: INPersonHandle(value: "+1-415-555-5555", type: .phoneNumber), nameComponents: nil, displayName: "John", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
            )]
        completion(response)
    }
    
    // MARK: - INSetMessageAttributeIntentHandling
    
    func handle(intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void) {
        // 实现应用程序逻辑，在这里设置消息属性。
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))
        let response = INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }
}
