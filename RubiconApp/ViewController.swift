//
//  ViewController.swift
//  RubiconApp
//
//  Created by Kryštof Matěj on 08/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Cocoa
import Generator

class ViewController: NSViewController, GeneratorOutput {
    @IBOutlet weak var sourceTextField: NSTextField!
    @IBOutlet weak var resultLabel: NSTextField!

    @IBAction func generateSpy(_ sender: Any) {
        let spyMocksController = MocksGeneratorControllerImpl(output: self, interactor: CreateSpyInteractor(accessLevel: .internal))
        let texts = [sourceTextField.stringValue]
        spyMocksController.run(texts: texts)
    }

    @IBAction func generateStub(_ sender: Any) {
        let spyMocksController = MocksGeneratorControllerImpl(output: self, interactor: CreateStubInteractor(accessLevel: .internal))
        let texts = [sourceTextField.stringValue]
        spyMocksController.run(texts: texts)
    }

    @IBAction func generateDummy(_ sender: Any) {
        let spyMocksController = MocksGeneratorControllerImpl(output: self, interactor: CreateDummyInteractor(accessLevel: .internal))
        let texts = [sourceTextField.stringValue]
        spyMocksController.run(texts: texts)
    }

    // MARK: - GeneratorOutput

    func save(text: String) {
        resultLabel.stringValue = text
    }
}
