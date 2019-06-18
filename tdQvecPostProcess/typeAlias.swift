//
//  typealias.swift
//  TDQvecLib
//
//  Created by Niall P. O'Byrnes on 19/22/11.
//  Copyright © 2019 Niall P. O'Byrnes. All rights reserved.
//



typealias tNi = Int32
typealias  let_tNi = Int32



typealias tQvec_Double = Double
typealias tQvec = Float
typealias tForce = Float

extension Float: DefaultValuable {

    static func defaultValue() -> Float {
        return 0.0
    }
}

extension Double: DefaultValuable {

    static func defaultValue() -> Double {
        return 0.0
    }
}

typealias t3d = Int
typealias let_t3d = Int


typealias tGeomShape = Float
typealias let_tGeomShape = Float


typealias tGeomIndex = Int32


typealias tStep = Int;


