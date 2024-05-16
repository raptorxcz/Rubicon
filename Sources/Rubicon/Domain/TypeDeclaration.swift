//
//  TypeDeclaration.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/04/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//


struct TypeDeclaration: Equatable {
    enum Prefix: String, Equatable {
        case escaping = "@escaping"
        case autoclosure = "@autoclosure"
    }

    enum ComposedType {
        case plain
        case array
        case dictionary
        case optional
        case set
    }

    var name: String
    let prefix: [Prefix]
    let composedType: ComposedType
}
