//
//  HelpController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 06/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public protocol HelpController {
    func run()
}

public class HelpControllerImpl {

    fileprivate let output: ErrorGeneratorOutput

    public init(output: ErrorGeneratorOutput) {
        self.output = output
    }
}

extension HelpControllerImpl: HelpController {

    public func run() {
        var helpString = ""
        helpString += "Required arguments:\n"
        helpString += "--mocks path - generates spies (deprecated)\n"
        helpString += "--spy path - generates spies\n"
        helpString += "--dummy path - generates dummies\n"
        output.showError(text: helpString)
    }
}
