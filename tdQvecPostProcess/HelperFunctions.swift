//
//  HelperFunctions.swift
//  TDQvecLib
//
//  Created by Nile Ó Broin on 24/01/2019.
//  Copyright © 2019 Nile Ó Broin. All rights reserved.
//





func printError(_ text: String) {
    print("ERROR: ", text)
}

func printLog(_ text: String) {
    print("NOTE: ", text)
}



protocol DefaultValuable {
    static func defaultValue() -> Self
}

func sizeof<T>(_ t: T) -> Int {
    return MemoryLayout<T>.size
}



