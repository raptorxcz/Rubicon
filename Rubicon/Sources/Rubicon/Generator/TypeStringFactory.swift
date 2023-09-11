//
//  TypeStringFactory.swift
//  Generator
//
//  Created by Jan Halousek on 10.09.18.
//  Copyright © 2018 Kryštof Matěj. All rights reserved.
//

enum TypeStringFactory {
    static func makeSimpleString(_ type: TypeDeclaration) -> String {
        return "\(makeExistencial(for: type))\(type.name)\(type.isOptional ? "?" : "")"
    }

    private static func makeExistencial(for type: TypeDeclaration) -> String {
//        if let existencial = type.existencial {
//            return existencial + " "
//        } else {
            return ""
//        }
    }

    static func makeFunctionArgumentString(_ type: TypeDeclaration) -> String {
        let prefix = type.prefix.map { $0.rawValue + " " }.joined()
        return prefix + makeSimpleString(type)
    }

    static func makeInitString(_ type: TypeDeclaration) -> String {
        let prefix = type.prefix.map {
            type.isOptional ? "" : $0.rawValue + " "
        }.joined()
        return prefix + makeSimpleString(type)
    }
}

