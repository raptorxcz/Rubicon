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

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        self.invocation = invocation

        let lines = invocation.buffer.lines as! [String]
        let text = lines.reduce("", {$0 + "\n" + $1})

        let mocksController = MocksGeneratorControllerImpl(output: self)
        mocksController.run(text: text)
         completionHandler(nil)
    }
    
}

extension GenerateSpy: GeneratorOutput {

    func save(text: String) {
        let lines = text.components(separatedBy: "\n")
        invocation?.buffer.lines.addObjects(from: lines)
    }

}
