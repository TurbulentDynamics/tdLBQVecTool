//
//  Process.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation
import tdLBApi


public enum Options {
    case velocities
    case vorticity
    case overwrite
    case verbose
}





public struct QVecProcess {

    var plotDirByStep = [Int: [PlotDir]]()


    var xy = MultiOrthoVelocity2DPlanesXY()
    var xz = MultiOrthoVelocity2DPlanesXZ()
    var yz = MultiOrthoVelocity2DPlanesYZ()



    public init(plotDirs dirs: [PlotDir]) {
        let fm = FileManager.default
        var isDirectory = ObjCBool(true)

        var root: URL?

        var validatedDirs = [PlotDir]()
        for d in dirs {
            if !fm.fileExists(atPath: d.absoluteString, isDirectory: &isDirectory) {
                print("Dir do not exist")
                fatalError()
            }

            if root == nil {
                root = d.deletingLastPathComponent()
                validatedDirs.append(d)
            } else if root != d.deletingLastPathComponent() {
                print("Ignoring Plot Dirs \(d)")
            } else {
                validatedDirs.append(d)
            }
        }

        groupByStep(plotDirs: validatedDirs)
    }





    public init(rootDir: URL, kind: [PlotDirKind]) throws {

        let O: OutputDir

        do {
            O = try OutputDir(rootDir: rootDir)
        } catch diskErrors.PlotDir {
            print("Fail. init with root dir and options")
            fatalError()
        }

        var validatedDirs = [PlotDir]()
        for k in kind {
            validatedDirs.append(contentsOf: O.plotDirs(withKind: k))
        }

        groupByStep(plotDirs: validatedDirs)

    }



    private mutating func groupByStep(plotDirs: [PlotDir]) {


        for p in plotDirs {
            if plotDirByStep.keys.contains(p.step()!) {
                plotDirByStep[p.step()!]?.append(p)
            } else {
                plotDirByStep[p.step()!] = [p]

            }

        }
    }



    /// Function to estimate the amount of time to process the files.  There could be 1000's
    public func analyse(){


        //DEBUG
        for (step, plotDirs) in plotDirByStep {
            for p in plotDirs {
                print(step, p)
            }
        }


    }



    public mutating func process(opts: [Options]) {


        for (_, plotDirs) in plotDirByStep {

            for plotDir in plotDirs {

                switch plotDir.dirType() {
                    case .XYplane:
                        xy.loadPlane(withDir: plotDir)
                        if opts.contains(.velocities) {xy.writeVelocity(to: plotDir, at: plotDir.cut()!)}
                    case .XZplane:
                        xz.loadPlane(withDir: plotDir)
                        if opts.contains(.velocities) {xz.writeVelocity(to: plotDir, at: plotDir.cut()!)}
                    case .YZplane:
                        yz.loadPlane(withDir: plotDir)
                        if opts.contains(.velocities) {yz.writeVelocity(to: plotDir, at: plotDir.cut()!)}

                    case .rotational:
                        continue
                    //                        yz.loadPlane(withDir: plotDir)
                    case .volume:
                        continue
                    //                        yz.loadPlane(withDir: plotDir)
                    case .none:
                    continue
                }




                if (opts.contains(.vorticity)){


                    var keys = xy.p.keys
                    for k in keys {
                        if !(keys.contains(k-1)) {
                            try! xy.loadPlane(withDir: plotDir.formatCutDelta(delta: -1))
                        }
                        if !(keys.contains(k+1)){
                            try! xy.loadPlane(withDir: plotDir.formatCutDelta(delta: +1))
                        }

                        let vort = xy.calcVorticity(at: k)
                        vort.writeVorticity(to: plotDir)
                    }



                    keys = xz.p.keys
                    for k in keys {
                        if !(keys.contains(k-1)) {
                            try! xz.loadPlane(withDir: plotDir.formatCutDelta(delta: -1))
                        }
                        if !(keys.contains(k+1)){
                            try! xz.loadPlane(withDir: plotDir.formatCutDelta(delta: +1))
                        }
                        let vort = xz.calcVorticity(at: k)
                        vort.writeVorticity(to: plotDir)
                    }



                    keys = yz.p.keys
                    for k in keys {
                        if !(keys.contains(k-1)) {
                            try! yz.loadPlane(withDir: plotDir.formatCutDelta(delta: -1))
                        }
                        if !(keys.contains(k+1)){
                            try! yz.loadPlane(withDir: plotDir.formatCutDelta(delta: +1))
                        }
                        let vort = yz.calcVorticity(at: k)
//                        let v = URL.init(fileURLWithPath: self.root[1].absoluteString + "/" + root[1].lastPathComponent)
                        vort.writeVorticity(to: plotDir)
                    }
                }//end of if opts.vorticity

            }//end of for plotDir in steps


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





}//end of struct


}

