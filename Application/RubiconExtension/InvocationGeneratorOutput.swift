//
//  InvocationGeneratorOutput.swift
//  RubiconExtension
//
//  Created by Kryštof Matěj on 03/02/2018.
//  Copyright © 2018 Kryštof Matěj. All rights reserved.
//

import Foundation
import Rubicon
import XcodeKit

class InvocationGeneratorOutput {
    private let invocation: XCSourceEditorCommandInvocation
    private lazy var indent: String = {
        let buffer = self.invocation.buffer
        var indent: String = ""

        if buffer.usesTabsForIndentation {
            for _ in 0 ..< buffer.tabWidth {
                indent += "\t"
            }
        } else {
            for _ in 0 ..< buffer.indentationWidth {
                indent += " "
            }
        }

        return indent
    }()

    init(invocation: XCSourceEditorCommandInvocation) {
        self.invocation = invocation
    }

    func save(text: String) {
        
//        invocation.buffer.lines.addObjects(from: lines)
    }
}
