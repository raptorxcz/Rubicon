//
//  SourceEditorCommand.swift
//  RubiconExtension
//
//  Created by Kryštof Matěj on 08/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation
import Generator
import XcodeKit

class GenerateSpy: NSObject, XCSourceEditorCommand {

    fileprivate var invocation: XCSourceEditorCommandInvocation?
    private var output: GeneratorOutput?

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        switch invocation.commandIdentifier {
        case "GeneratePrivateSpy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(with: invocation, visibility: "private", generatorOutput: output, completionHandler: completionHandler)
        case "GenerateSpy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(with: invocation, visibility: nil, generatorOutput: output, completionHandler: completionHandler)
        case "GenerateSpyToPasteboard":
            let output = PasteboardGeneratorOutput(invocation: invocation)
            perform(with: invocation, visibility: nil, generatorOutput: output, completionHandler: completionHandler)
        default:
            break
        }
    }

    private func perform(with invocation: XCSourceEditorCommandInvocation, visibility: String?, generatorOutput: GeneratorOutput, completionHandler: @escaping (Error?) -> Void) {
        self.invocation = invocation

        guard var lines = invocation.buffer.lines as? [String] else {
            fatalError("not lines: \(invocation.buffer.lines)")
        }

        if invocation.buffer.selections.count == 1, let range = invocation.buffer.selections.firstObject as? XCSourceTextRange {
            if isEmptyRange(range) {
                let start = range.start.line
                let end = range.end.column == 0 ? max(range.end.line - 1, 0) : range.end.line
                lines = Array(lines[start ... end])
            }
        }

        let text = lines.reduce("", { $0 + "\n" + $1 })

        output = generatorOutput
        let mocksController = MocksGeneratorControllerImpl(output: generatorOutput, visibility: visibility)
        mocksController.run(texts: [text])
        completionHandler(nil)
    }

    private func isEmptyRange(_ range: XCSourceTextRange) -> Bool {
        return range.start.line != range.end.line || (range.start.line == range.end.line && range.start.column != range.end.column)
    }
}
