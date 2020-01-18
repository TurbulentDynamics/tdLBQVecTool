//
//  InputFilesV4URL.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation

public enum diskErrors: Error {
    case fileNotFound
    case directoryNotFound
    case fileNotReadable
    case fileNotJsonParsable
    case OtherDiskError
}

public enum DirType {
    case XYplane
    case XZplane
    case YZplane
    case rotational
    case volume
//    case sector
    case None
}





public extension URL {



    func dirExists(atPath: URL) {
        
    }



    private func selfVersion() -> Int {
        return 4
    }

    private func format(step: Int) -> String {
        return String(format: "%08d", step)
    }

    private func formatDirRoot(name: String = "plot", type: DirType, QLength: Int, step: Int) -> String {
        return "\(name).\(type).V_\(selfVersion()).Q_\(QLength).step_\(format(step: step))"
    }



    // MARK: Make new directories



    func formatXYPlane(name: String = "plot_vertical_axis", QLength: Int, step: Int, atK: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.XYplane, QLength: QLength, step: step)
        return "\(root).cut_\(atK)"

        //        FileManager.createDirectory(dir)
    }


    func formatXZPlane(name: String = "plot_slice", QLength: Int, step: Int, atJ: Int) -> String{

        let root = formatDirRoot(name: name, type: DirType.XZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atJ)"
    }

    func formatYZPlane(name: String = "plot_axis", QLength: Int, step: Int, atI: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.YZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atI)"
    }


    func formatVolume(name: String = "volume", QLength: Int, step: Int) -> String {

        return formatDirRoot(name: name, type: DirType.volume, QLength: QLength, step: step)
    }



    func formatCaptureAtBladeAngle(name: String="plot", step: Int, angle: Int, bladeId: Int, QLength: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.rotational, QLength: QLength, step: step)
        return "\(root).angle_\(angle).blade_id_\(bladeId)"
    }

    func formatAxisWhenBladeAngle(name: String="plot", step: Int, angle: Int, QLength: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.YZplane, QLength: QLength, step: step)
        return "\(root).angle_\(angle)"
    }

    func formatRotatingSector(name: String="plot", step: Int, angle: Int, QLength: Int) {
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




    // MARK: Query Directories


    func name() -> String? {
        return self.lastPathComponent.components(separatedBy: ".")[0]
    }

    func dirType() -> DirType {
        let dir = self.lastPathComponent

        if dir.contains(".XYplane.") {return .XYplane}
        else if dir.contains(".XZplane.") {return .XZplane}
        else if dir.contains(".YZplane.") {return .YZplane}
        else if dir.contains(".volume.") {return .volume}
        else if dir.contains(".rotational_capture.") {return .rotational}
//        else if dir.contains(".sector.") {return .sector}
        else {
            return .None
        }
    }

    func dirType(is type: DirType) -> Bool {
        return type == dirType()
    }

    func dirType(isOneOf type: [DirType]) -> Bool {
        var ret = false
        if type.contains(self.dirType()) {
            ret = true
        }
        return ret
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



    // MARK: Working with bin and bin.json files



    private func formatQVecFileRoot(_ name: String, _ idi: Int, _ idj: Int, _ idk: Int) -> String {
        return "\(name).node.\(idi).\(idj).\(idk).V\(selfVersion())"
    }

    func formatQVecBin(name: String, idi: Int, idj: Int, idk: Int) -> String {
        return "\(formatQVecFileRoot(name, idi, idj, idk)).bin"
    }

    func formatNode000QVecBin(name: String) -> String {
        return formatQVecBin(name: name, idi: 0, idj: 0, idk: 0)
    }




    private func getFiles(withRegex regex: String) throws -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let fm = FileManager.default
        let directoryContents = try fm.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)

        let fileNames = directoryContents.map{ $0.lastPathComponent }

        let filteredBinFileNames = fileNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

        let filteredBinFileURLs = filteredBinFileNames.map{self.appendingPathComponent($0)}

        //        print(dirURL, directoryContents, fileNames, regex, filteredBinFileNames)

        return filteredBinFileURLs

    }


    private func qVecBinRegex() -> String {
        return "^Qvec\\.node\\..*\\.bin$"
    }

    private func F3BinRegex() -> String {
        return "^Qvec\\.F3\\.node\\..*\\.bin$"
    }

    private func faceDeltas() -> [facesIJK] {
        return facesIJK.allCases
    }

    private func qVecRotationBinRegex(delta: facesIJK) -> String {
        return "^Qvec\\.\(delta)\\.node\\..*\\.bin$"
    }

    private func F3RotationBinRegex(delta: facesIJK) -> String {
        return "^Qvec\\.F3\\.\(delta)\\.node\\..*\\.bin$"
    }



    func getQvecFiles() throws -> [URL] {
        return try getFiles(withRegex: qVecBinRegex())
    }

    func getF3Files() throws -> [URL] {
        return try getFiles(withRegex: F3BinRegex())
    }




    func getQvecRotationFiles(faceDelta: facesIJK) throws -> [URL] {
        return try getFiles(withRegex: qVecRotationBinRegex(delta: faceDelta))
    }

    func getF3RotationFiles(faceDelta: facesIJK) throws -> [URL] {
        return try getFiles(withRegex: F3RotationBinRegex(delta: faceDelta))
    }



    // MARK: Working with top level data dir


    private func getDirs(withRegex regex: String) -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let fm = FileManager.default
        do {
            let directoryContents = try fm.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)

            let dirNames = directoryContents.map{ $0.lastPathComponent }

            let filteredDirNames = dirNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

            let filteredDirsURLs = filteredDirNames.map{self.appendingPathComponent($0)}

            //        print(dirURL, directoryContents, fileNames, regex, filteredBinFileNames)

            return filteredDirsURLs

        } catch {
            return []
        }
    }



    func subDirsStep(at: Int) -> [URL] {
        return getDirs(withRegex: ".*step_\(format(step: at)).*")
    }
    func subDirsAllXYPlanes() -> [URL]  {
        return getDirs(withRegex: ".*XYplane.*")
    }
    func subDirsAllXZPlanes() -> [URL]  {
        return getDirs(withRegex: ".*XZplane.*")
    }
    func subDirsAllYZPlanes() -> [URL]  {
        return getDirs(withRegex: ".*YZplane.*")
    }
    func subDirsAllVolume() -> [URL]  {
        return getDirs(withRegex: ".*volume.*")
    }
    func subDirsAllRotational() -> [URL]  {
        return getDirs(withRegex: ".*rotational_capture.*")
    }
    func subDirsAll()  -> [URL] {
        return getDirs(withRegex: ".*")
    }



    // MARK: Loading Files

    func getPPDim() -> ppDim? {
        do {
            return try ppDim(dir: self)
        } catch {
            return nil
        }
    }




} //end of class
