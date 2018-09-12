//
//  TypeStringFactory.swift
//  Generator
//
//  Created by Jan Halousek on 10.09.18.
//  Copyright © 2018 Kryštof Matěj. All rights reserved.
//

class TypeStringFactory {

    static func makeSimpleString(_ type: Type) -> String {
        return "\(type.name)\(type.isOptional ? "?" : "")"
    }

    static func makeFunctionArgumentString(_ type: Type) -> String {
        var prefix = ""
        if let prefixValue = type.prefix {
            prefix = prefixValue.rawValue + " "
        }
        return prefix + makeSimpleString(type)
    }

    static func makeInitString(_ type: Type) -> String {
        var prefix = ""
        if type.isClosure && !type.isOptional {
            prefix = TypePrefix.escaping.rawValue + " "
        }
        return prefix + makeSimpleString(type)
    }
}
