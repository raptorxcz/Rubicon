import Foundation
import Rubicon
import XcodeKit

protocol GeneratorOutput {
    func save(lines: [String])
}

final class Generate: NSObject, XCSourceEditorCommand {
    enum MockType {
        case spy
        case stub
        case dummy
    }

    private var invocation: XCSourceEditorCommandInvocation?
    private var completionHandler: ((Error?) -> Void)?

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        self.invocation = invocation
        self.completionHandler = completionHandler

        switch invocation.commandIdentifier {
        case "GeneratePrivateSpy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .spy,
                accessLevel: .private,
                output: output
            )
        case "GenerateSpy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .spy,
                accessLevel: .internal,
                output: output
            )
        case "GeneratePublicSpy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .spy,
                accessLevel: .public,
                output: output
            )
        case "GenerateSpyToPasteboard":
            let output = PasteboardGeneratorOutput(invocation: invocation)
            perform(
                type: .spy,
                accessLevel: .internal,
                output: output
            )
        case "GeneratePrivateStub":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .stub,
                accessLevel: .private,
                output: output
            )
        case "GenerateStub":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .stub,
                accessLevel: .internal,
                output: output
            )
        case "GeneratePublicStub":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .stub,
                accessLevel: .public,
                output: output
            )
        case "GenerateStubToPasteboard":
            let output = PasteboardGeneratorOutput(invocation: invocation)
            perform(
                type: .stub,
                accessLevel: .private,
                output: output
            )
        case "GeneratePrivateDummy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .dummy,
                accessLevel: .private,
                output: output
            )
        case "GenerateDummy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .dummy,
                accessLevel: .internal,
                output: output
            )
        case "GeneratePublicDummy":
            let output = InvocationGeneratorOutput(invocation: invocation)
            perform(
                type: .dummy,
                accessLevel: .public,
                output: output
            )
        case "GenerateDummyToPasteboard":
            let output = PasteboardGeneratorOutput(invocation: invocation)
            perform(
                type: .dummy,
                accessLevel: .internal,
                output: output
            )
        case "AddTearDownMethod":
            processTearDown(with: invocation, completionHandler: completionHandler)
        default:
            break
        }
    }

    private func perform(
        type: MockType,
        accessLevel: AccessLevel,
        output: GeneratorOutput
    ) {
        guard let invocation, let completionHandler else {
            return
        }

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
        let indentStep = makeIndentation(from: invocation)
        let newLines = makeMock(type: type, code: text, accessLevel: accessLevel, indentStep: indentStep)
        output.save(lines: newLines)
        completionHandler(nil)
    }

    private func makeMock(type: MockType, code: String, accessLevel: AccessLevel, indentStep: String) -> [String] {
        switch type {
        case .spy:
            return Rubicon().makeSpy(code: code, accessLevel: accessLevel, indentStep: indentStep)
        case .stub:
            return Rubicon().makeStub(code: code, accessLevel: accessLevel, indentStep: indentStep)
        case .dummy:
            return Rubicon().makeDummy(code: code, accessLevel: accessLevel, indentStep: indentStep)
        }
    }

    private func makeIndentation(from invocation: XCSourceEditorCommandInvocation) -> String {
        let buffer = invocation.buffer
        var indent = ""

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
    }

    private func processTearDown(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        guard let lines = invocation.buffer.lines as? [String] else {
            completionHandler(GenerateError.missingLines)
            return
        }

        let text = lines.joined()

        do {
            let newFile = try Rubicon().updateTearDown(text: text, spacing: invocation.buffer.indentationWidth)
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
