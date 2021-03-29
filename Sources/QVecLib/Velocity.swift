//  VelocityStructs.swift
//  tdLBApi
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation

/// Three component Velocity type with an extra value for Density rho (ρ)
///
struct Velocity<T: BinaryFloatingPoint> {

    //TODO
    //    var v = simd_float4(rho, ux, uy, uz)

//    public var ρ: T

    var rho: T
    var ux: T
    var uy: T
    var uz: T

    init() {
        rho = T.zero
        ux = T.zero
        uy = T.zero
        uz = T.zero
    }

    init(rho: T, ux: T, uy: T, uz: T) {
        self.rho = rho
        self.ux = ux
        self.uy = uy
        self.uz = uz
    }
}

/// A dense 3D grid of Velocity types.
///
struct Velocity3DGrid<T: BinaryFloatingPoint> {

    var g: [[[Velocity<T>]]]

    /// Initialise a 3D Velocity grid of size x, y, z
    ///
    /// - parameters
    ///   - x, y, z Size of the grid
    init(x: Int, y: Int, z: Int) {

        //Some files may have been written with the halo.
        self.g = Array(repeating: Array(repeating: Array(repeating: Velocity(), count: z + 2), count: y + 2), count: x + 2)
    }

    subscript(i: Int, j: Int, k: Int) -> Velocity<T> {
        get {
            return g[i][j][k]
        }
        set(newValue) {
            g[i][j][k] = newValue
        }
    }

}
