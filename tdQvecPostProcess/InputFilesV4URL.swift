//
//  main.swift
//  TDQVecLib
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation

enum diskErrors: Error {
    case fileNotFound
    case directoryNotFound
    case fileNotReadable
    case fileNotJsonParsable
    case OtherDiskError
}

enum DirType {
    case XYplane
    case XZplane
    case YZplane
    case rotational
    case volume
    case sector
}




extension URL {


    private func selfVersion() -> Int {
        return 4
    }

    private func format(step: Int) -> String {
        return String(format: "%08d", step)
    }

    private func formatDirRoot(name: String = "plot", type: DirType, QLength: Int, step: Int) -> String {
        return "\(name).\(type).V_\(selfVersion()).Q_\(QLength).step_\(format(step: step))"
    }







    func mkXYPlane(name: String = "plot_vertical_axis", QLength: Int, step: Int, atK: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.XYplane, QLength: QLength, step: step)
        return "\(root).cut_\(atK)"

//        FileManager.createDirectory(dir)
    }


    func mkXZPlane(name: String = "plot_slice", QLength: Int, step: Int, atJ: Int) -> String{

        let root = formatDirRoot(name: name, type: DirType.XZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atJ)"
    }

    func mkYZPlane(name: String = "plot_axis", QLength: Int, step: Int, atI: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.YZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atI)"
    }


    func mkVolume(name: String = "volume", QLength: Int, step: Int) -> String {

        return formatDirRoot(name: name, type: DirType.volume, QLength: QLength, step: step)
    }



    func mkCaptureAtBladeAngle(name: String="plot", step: Int, angle: Int, bladeId: Int, QLength: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.rotational, QLength: QLength, step: step)
        return "\(root).angle_\(angle).blade_id_\(bladeId)"
    }

    func mkAxisWhenBladeAngle(name: String="plot", step: Int, angle: Int, QLength: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.YZplane, QLength: QLength, step: step)
        return "\(root).angle_\(angle)"
    }

    func mkRotatingSector(name: String="plot", step: Int, angle: Int, QLength: Int) {
    }


    func formatCutDelta(delta: Int) throws -> String {
        if let cut = self.cut() {

            let replace: String = "cut_\(cut + delta)"

            let newDir = self.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)
            return newDir
        } else {
            throw diskErrors.OtherDiskError
        }
    }



    func formatCutDelta(replaceCut: Int) throws -> String {
        if let _ = self.cut() {

            let replace: String = "cut_\(replaceCut)"

            let newDir = self.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            //            print(fromDir, replace, newDir)
            return newDir
        } else {
            throw diskErrors.OtherDiskError
        }
    }




    //----------------------------------------------Query6 directories


    func name() -> String? {
        return self.lastPathComponent.components(separatedBy: ".")[0]
    }

    func dirType() -> DirType? {
        let dir = self.lastPathComponent

        if dir.contains(".XYplane.") {return .XYplane}
        else if dir.contains(".XZplane.") {return .XZplane}
        else if dir.contains(".YZplane.") {return .YZplane}
        else if dir.contains(".volume.") {return .volume}
        else if dir.contains(".rotational_capture.") {return .rotational}
        else if dir.contains(".sector.") {return .sector}
        else {
            return nil
        }
    }

    func version() -> Int? {
        let dir = self.lastPathComponent
        if let result = dir.range(of: #"V_([0-9]*)"#, options: .regularExpression){
            let i = dir[result].index(dir[result].startIndex, offsetBy: 2)
            return Int(dir[result][i...])
        } else {
            return nil
        }
    }

    func qLength() -> Int? {
        let dir = self.lastPathComponent
        if let result = dir.range(of: #"Q_([0-9]*)"#, options: .regularExpression){
            let i = dir[result].index(dir[result].startIndex, offsetBy: 2)
            return Int(dir[result][i...])
        } else {
            return nil
        }
    }

    func step() -> Int? {
        let dir = self.lastPathComponent
        if let result = dir.range(of: #"step_([0-9]*)"#, options: .regularExpression){
            let i = dir[result].index(dir[result].startIndex, offsetBy: 5)
            return Int(dir[result][i...])
        } else {
            return nil
        }
    }


    func cut() -> Int? {
        let dir = self.lastPathComponent
        if let result = dir.range(of: #"cut_([0-9]*)"#, options: .regularExpression){
            let i = dir[result].index(dir[result].startIndex, offsetBy: 4)
            return Int(dir[result][i...])
        } else {
            return nil
        }
    }



    //------------------------Working with bin and bin.json files



    private func formatQVecFileRoot(_ name: String, _ idi: Int, _ idj: Int, _ idk: Int) -> String {
        return "\(name).node.\(idi).\(idj).\(idk).V\(selfVersion())"
    }

    func formatQVecBin(name: String, idi: Int, idj: Int, idk: Int) -> String {
        return "\(formatQVecFileRoot(name, idi, idj, idk)).bin"
    }

    func formatNode000QVecBin(name: String) -> String {
        return formatQVecBin(name: name, idi: 0, idj: 0, idk: 0)
    }


    private func qVecBinRegex() -> String {
        return "^Qvec\\.node\\..*\\.bin$"
    }

    private func F3BinRegex() -> String {
        return "^Qvec\\.F3\\.node\\..*\\.bin$"
    }

    private func qVecRotationBinRegex(planeNum: Int) -> String {
        let regex = [".", ".im1.", ".ip1.", ".km1.", ".kp1."].map{"^Qvec\($0)node\\..*\\.bin$"}
        return regex[planeNum]
    }

    private func F3RotationBinRegex(planeNum: Int) -> String {
        let regex = [".", ".im1.", ".ip1.", ".km1.", ".kp1."].map{"^Qvec\\.F3\($0)node\\..*\\.bin$"}
        return regex[planeNum]
    }




    func getFiles(withRegex regex: String) throws -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let fm = FileManager.default
        let directoryContents = try fm.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)

        let fileNames = directoryContents.map{ $0.lastPathComponent }

        let filteredBinFileNames = fileNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

        let filteredBinFileURLs = filteredBinFileNames.map{self.appendingPathComponent($0)}

        //        print(dirURL, directoryContents, fileNames, regex, filteredBinFileNames)

        return filteredBinFileURLs

    }








} //end of class
