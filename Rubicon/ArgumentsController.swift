//
//  ArgumentsController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 01/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public protocol FileReader {
    func readFiles(at path: String) -> String
}

public protocol HelpController {
    func run()
}

public protocol MocksGeneratorController {
    func run(text: String)
}

public class ArgumentsController {

    private let fileReader: FileReader
    private let helpController: HelpController
    private let mocksController: MocksGeneratorController

    public init(fileReader: FileReader, helpController: HelpController, mocksController: MocksGeneratorController) {
        self.fileReader = fileReader
        self.helpController = helpController
        self.mocksController = mocksController
    }

    public func run(arguments: [String]) {
        guard arguments.indices.contains(1) else {
            helpController.run()
            return
        }

        let result = fileReader.readFiles(at: arguments[1])
        mocksController.run(text: result)
    }

}
