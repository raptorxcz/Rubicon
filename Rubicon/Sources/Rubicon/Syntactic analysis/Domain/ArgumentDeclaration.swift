//
//  ArgumentDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 27/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct ArgumentDeclaration {
    public var label: String?
    public var name: String
    public var type: TypeDeclaration

    public init(label: String?, name: String, type: TypeDeclaration) {
        self.label = label
        self.name = name
        self.type = type
    }
}
