//
//  SourceEditorCommand.swift
//  RubiconExtension
//
//  Created by Kryštof Matěj on 08/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation
import XcodeKit
import Generator

class GenerateSpy: NSObject, XCSourceEditorCommand {

    fileprivate var invocation: XCSourceEditorCommandInvocation?
    fileprivate let indentFormatter = IndentationFormatter()
    fileprivate lazy var indent: String = {
        guard let buffer = self.invocation?.buffer else {
            return ""
        }

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

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        self.invocation = invocation

        let lines = invocation.buffer.lines as! [String]
        let text = lines.reduce("", { $0 + "\n" + $1 })

        let mocksController = MocksGeneratorControllerImpl(output: self)
        mocksController.run(texts: [text])
        completionHandler(nil)
    }

}

extension GenerateSpy: GeneratorOutput {

    func save(text: String) {
        guard let invocation = invocation else {
            return
        }

        let lines = indentFormatter.format(indent: indent, string: text).components(separatedBy: "\n")
        invocation.buffer.lines.addObjects(from: lines)
    }

}
