////
////  File.swift
////  
////
////  Created by Niall Ó Broin on 30/05/2020.
////
//
//import Foundation
//
//
//public struct Size3d {
//    public var x, y, z: Int
//
//    public init(x:Int, y:Int, z:Int){
//        self.x = x
//        self.y = y
//        self.z = z
//    }
//}
//
//public enum Direction3D {
//    case x, y, z
//}
//
//public struct Pos3d {
//    public var i, j, k: Int
//
//    public init(i:Int, j:Int, k:Int){
//        self.i = i
//        self.j = j
//        self.k = k
//    }
//
//}
//
//public struct Size2d {
//    public var cols, rows: Int
//
//    public init(cols:Int, rows:Int){
//        self.cols = cols
//        self.rows = rows
//    }
//
//}
//
//public enum Direction2D {
//    case col, row
//}
//
//public struct Pos2d {
//    public var c, r: Int
//
//    public init(c:Int, r:Int){
//        self.c = c
//        self.r = r
//    }}
//
//
//
//public enum QVecType {
//    case Double
//    case Single
//    case Half
//
//    public var sizeInBytes: Int {
//        switch self{
//            case .Double: return MemoryLayout<Double>.size
//            case .Single: return MemoryLayout<Float32>.size
//
//            //Half not yet available in MacOS
//            case .Half: return 2
//
//        }
//    }
//
//
//}
//
//
//
//
//public enum QLen: Int {
//    case q27 = 27
//    case q19 = 19
//    case q7 = 7
//}
//
//
//
//
