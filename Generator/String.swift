//
//  String.swift
//  Rubicon
//
//  Created by Kryštof Matěj on 26/06/2017.
//  Copyright © 2017 Kryštof Matěj. All rights reserved.
//

extension String {

    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }

}
