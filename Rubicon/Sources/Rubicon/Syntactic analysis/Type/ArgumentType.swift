//
//  ArgumentType.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 27/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct ArgumentType {
    public var label: String?
    public var name: String
    public var type: Type

    public init(label: String?, name: String, type: Type) {
        self.label = label
        self.name = name
        self.type = type
    }
}
