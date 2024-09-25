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


import Foundation
import Intents

// PingIntentHandling：是由 Intents 中的配置自动生成
class OpenAIHandler:NSObject, OpenAIIntentHandling {
  
  // MARK:- OpenAIIntentHandling 代理
  func handle(intent: OpenAIIntent, completion: @escaping (OpenAIIntentResponse) -> Void) {
    if let prompt = intent.prompt, let system = intent.system {
        //获取捷径的数据
        let result = chatCmd(hostname: prompt)
        // 响应捷径的数据
        completion(OpenAIIntentResponse.success(result:result))
    }
  }
  
  /// <#Description#>
  /// - Parameter hostname: <#hostname description#>
  /// - Returns: <#description#>
  func chatCmd(hostname:String) -> String{
    //TODO: 要做的事情
    
    return ""
  }

  func resolvePrompt(for intent: OpenAIIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let prompt = intent.prompt else {
        completion(INStringResolutionResult.needsValue())
        return
    }
    completion(INStringResolutionResult.success(with: prompt))
  }
  
  func resolveSystem(for intent: OpenAIIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let system = intent.system else {
        completion(INStringResolutionResult.needsValue())
        return
    }
    completion(INStringResolutionResult.success(with: system))
  }

  
}
