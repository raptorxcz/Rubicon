//
//  ArgumentsController.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 01/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public class ArgumentsController {

    private let fileReader: FileReader
    private let helpController: HelpController
    private let spyMocksController: MocksGeneratorController
    private let dummyMocksController: MocksGeneratorController

    public init(fileReader: FileReader, helpController: HelpController, spyMocksController: MocksGeneratorController, dummyMocksController: MocksGeneratorController) {
        self.fileReader = fileReader
        self.helpController = helpController
        self.spyMocksController = spyMocksController
        self.dummyMocksController = dummyMocksController
    }

    public func run(arguments: [String]) {
        guard arguments.indices.contains(2) else {
            helpController.run()
            return
        }

        let result = fileReader.readFiles(at: arguments[2])

        switch arguments[1] {
        case "--dummy":
            dummyMocksController.run(texts: result)
        default:
            spyMocksController.run(texts: result)
        }
    }
}
