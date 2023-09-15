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

    var name: String
    var isOptional: Bool
    let prefix: [Prefix]
}
