//
//  Type.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

public struct Type {
    public var name: String
    public var isOptional: Bool

    public init(name: String, isOptional: Bool) {
        self.name = name
        self.isOptional = isOptional
    }

    public func makeString() -> String {
        return name + (isOptional ? "?" : "")
    }
}
