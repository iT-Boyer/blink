//
//  OpenAISpecs.swift
//  Blink
//
//  Created by boyer on 2023/11/14.
//  Copyright © 2023 Carlos Cabañero Projects SL. All rights reserved.
//

import Quick
import Nimble
@testable import Blink

class OpenAISpecs: QuickSpec {
    override class func spec() {
      beforeEach {
        let openAI = OpenAI(apiToken: "YOUR_TOKEN_HERE")

      }
    }
}
