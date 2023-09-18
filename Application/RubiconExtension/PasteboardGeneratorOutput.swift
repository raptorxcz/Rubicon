import AppKit
import Foundation
import Rubicon
import XcodeKit

final class PasteboardGeneratorOutput: GeneratorOutput {
    private let invocation: XCSourceEditorCommandInvocation

    init(invocation: XCSourceEditorCommandInvocation) {
        self.invocation = invocation
    }

    func save(lines: [String]) {
        let text = lines.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(text, forType: .string)
    }
}
