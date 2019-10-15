//
//  mQVecPostProcess.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation


public enum Options {
    case velocities
    case vorticity
    case overwrite
    case verbose
}




public class QVecProcess {
    var dirs = [URL]()
    var types = [DirType]()

    var xy = MultiOrthoVelocity2DPlanesXY()
    var xz = MultiOrthoVelocity2DPlanesXZ()
    var yz = MultiOrthoVelocity2DPlanesYZ()



    public init(dirs dirStrings: [String], dirTypes: [DirType]){

        self.dirs = getValidDirs(from: dirStrings, with:dirTypes)

        if dirTypes.contains(.None) || dirs.count == 0 {
            print("Incorrect Initialisaion")
            return
        }

        self.types = dirTypes

        print(types)
        print(dirs)

    }


    func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    public func getValidDirs(from dirStrings: [String], with types: [DirType]) -> [URL] {

        var validDirs = [URL]()
        for dir in dirStrings {

            if directoryExistsAtPath(dir) {

                let validDir = URL.init(fileURLWithPath: dir, isDirectory: true)

                if validDir.dirType(isOneOf: types) {

                    validDirs.append(validDir)

                } else {
                    print("Directory at \(dir) does not confirm to one of \(types)")
                }

            }
        }

        return validDirs
    }




    public func analyse(){

    }



    public func process(opts: [Options])
    {

        //for each step only
        for d in dirs {
            switch d.dirType(){
                case .XYplane:
                    xy.loadPlane(withDir: d)
                    print(opts)
                    if opts.contains(.velocities) {
                        xy.writeVelocity(to: d, at:d.cut()!)
                }
                case .XZplane:
                    xz.loadPlane(withDir: d)
                    if opts.contains(.velocities) {
                        xz.writeVelocity(to: d, at:d.cut()!)
                }
                case .YZplane:
                    yz.loadPlane(withDir: d)
                    if opts.contains(.velocities) {
                        yz.writeVelocity(to: d, at:d.cut()!)
                }
                default:
                    continue
            }
        }


        var keys = xy.p.keys
        for k in keys {
            if keys.contains(k-1) && keys.contains(k+1){
                let vort = xy.calcVorticity(at: k)
                let v = URL.init(fileURLWithPath: dirs[1].absoluteString + "/" + dirs[1].lastPathComponent)
                vort.writeVorticity(to: v)
            }
        }


        keys = xz.p.keys
        for k in keys {
            if keys.contains(k-1) && keys.contains(k+1){
                let vort = xz.calcVorticity(at: k)
                let v = URL.init(fileURLWithPath: dirs[1].absoluteString + "/" + dirs[1].lastPathComponent)
                vort.writeVorticity(to: v)
            }
        }


        keys = yz.p.keys
        for k in keys {
            if keys.contains(k-1) && keys.contains(k+1){
                let vort = yz.calcVorticity(at: k)
                let v = URL.init(fileURLWithPath: dirs[1].absoluteString + "/" + dirs[1].lastPathComponent)
                vort.writeVorticity(to: v)
            }
        }




    }


    //    func analyseRotation() -> [URL] {
    //        //TODO
    //        //Break into steps,
    //        //then break into types,
    //        //then into position groups.
    //
    //        var rotation = [URL]()
    //        for d in dirs {
    //            if d.dirType(is: .rotational){
    //
    //                //TODO: Load consecutive dirs.  Pass consecutive dirs into MultiOrthoVelocity2DPlanesXZ
    //                rotation.append(d)
    //            }
    //        }
    //
    //        return rotation
    //    }


    //        let rot = analyseRotation()
    //        if rot.count == 0 {
    //            return
    //        }
    //
    //        let dim = rot[0].getPPDim()!
    //        var p = AngleVelocity2DPlaneIK(cols: dim.fileHeight, rows: dim.fileWidth)
    //
    //        load(p: &p, dirs: rot)





}




