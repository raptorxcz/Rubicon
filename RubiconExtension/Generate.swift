//
//  SourceEditorCommand.swift
//  RubiconExtension
//
//  Created by Kryštof Matěj on 08/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Foundation
import Rubicon
import XcodeKit

class Generate: NSObject, XCSourceEditorCommand {
    fileprivate var invocation: XCSourceEditorCommandInvocation?
    private var output: GeneratorOutput?

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        switch invocation.commandIdentifier {
        case "GeneratePrivateSpy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateSpyInteractor(accessLevel: .private)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GenerateSpy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateSpyInteractor(accessLevel: .internal)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GeneratePublicSpy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateSpyInteractor(accessLevel: .public)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GenerateSpyToPasteboard":
            let output = PasteboardGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateSpyInteractor(accessLevel: .internal)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GeneratePrivateStub":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateStubInteractor(accessLevel: .private)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GenerateStub":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateStubInteractor(accessLevel: .internal)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GeneratePublicStub":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateStubInteractor(accessLevel: .public)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GenerateStubToPasteboard":
            let output = PasteboardGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateStubInteractor(accessLevel: .internal)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GeneratePrivateDummy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateDummyInteractor(accessLevel: .private)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GenerateDummy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateDummyInteractor(accessLevel: .internal)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GeneratePublicDummy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateDummyInteractor(accessLevel: .public)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "GenerateDummyToPasteboard":
            let output = PasteboardGeneratorOutput(invocation: invocation)
            let createMockInteractor = CreateDummyInteractor(accessLevel: .internal)
            perform(with: invocation, generatorOutput: output, createMockInteractor: createMockInteractor, completionHandler: completionHandler)
        case "AddTearDownMethod":
            processTearDown(with: invocation, completionHandler: completionHandler)
        default:
            break
        }
    }

    private func perform(with invocation: XCSourceEditorCommandInvocation, generatorOutput: GeneratorOutput, createMockInteractor: CreateMockInteractor, completionHandler: @escaping (Error?) -> Void) {
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

        let text = lines.joined()

        output = generatorOutput
        let mocksController = MocksGeneratorControllerImpl(output: generatorOutput, interactor: createMockInteractor)
        mocksController.run(texts: [text])
        completionHandler(nil)
    }

    private func processTearDown(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        guard let lines = invocation.buffer.lines as? [String] else {
            completionHandler(GenerateError.missingLines)
            return
        }

        let interactor = TearDownInteractor(nilableVariablesParser: NilableVariablesParserImpl())
        let text = lines.joined()

        do {
            let newFile = try interactor.execute(text: text, spacing: invocation.buffer.indentationWidth)
            invocation.buffer.lines.removeAllObjects()
            invocation.buffer.lines.addObjects(from: newFile.components(separatedBy: "\n").dropLast())
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    private func isEmptyRange(_ range: XCSourceTextRange) -> Bool {
        return range.start.line != range.end.line || (range.start.line == range.end.line && range.start.column != range.end.column)
    }
}

private enum GenerateError: Error {
    case missingLines
}
