//
//  ViewController.swift
//  RubiconApp
//
//  Created by Kryštof Matěj on 08/05/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

import Cocoa
import Rubicon

class ViewController: NSViewController {
    @IBOutlet weak var sourceTextField: NSTextView!
    @IBOutlet var resultLabel: NSTextView!

    @IBAction func generateSpy(_ sender: Any) {
        resultLabel.string = Rubicon().makeSpy(code: sourceTextField.string, accessLevel: .internal, indentStep: "    ").joined(separator: "\n\n")
    }

    @IBAction func generateStub(_ sender: Any) {
        resultLabel.string = Rubicon().makeStub(code: sourceTextField.string, accessLevel: .internal, indentStep: "    ").joined(separator: "\n\n")
    }

    @IBAction func generateDummy(_ sender: Any) {
        resultLabel.string = Rubicon().makeDummy(code: sourceTextField.string, accessLevel: .internal, indentStep: "    ").joined(separator: "\n\n")
    }
}
