//
//  ViewController.swift
//  Lab2
//
//  Created by Konstantyn Byhkalo on 1/20/17.
//  Copyright © 2017 Gaponenko Dmitriy. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DownloadModelProtocol {

//    MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    
    var downloadModels = [DownloadModel]()
    var countOfLoadedImages = 0
    var startTime: Date?
    
//    MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
//    MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cellIdentifier"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if downloadModels.count <= indexPath.row {
            let newDownloadModel = DownloadModel(linkString: Constants.links[indexPath.row],
                                              indexPath: indexPath,
                                              tableView: tableView,
                                              delegate: self)
            downloadModels.append(newDownloadModel)
            downloadLogs(isStartDownloading: true, fileNumber: indexPath.row+1)
            
            newDownloadModel.configurateDownloading()
        }
        
        return downloadModels[indexPath.row].configureCell(cell)
    }
    
//    MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//    MARK: - DownloadModelProtocol
    
    func compleateDownloadCellBy(downloadModel: DownloadModel) {
        downloadLogs(isStartDownloading: false, fileNumber: downloadModel.indexPath.row+1)
        countOfLoadedImages += 1
        if countOfLoadedImages == Constants.links.count {
            startFaceDetector()
        }
    }
    
//    MARK: - Help Methods
    
    func downloadLogs(isStartDownloading: Bool, fileNumber: Int) {
        if let startTime = startTime {
            let timeDelta = Date().timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
            let printTimeDelta = String(format: "%.3f", timeDelta)
            print("\(printTimeDelta) \(isStartDownloading ? "started" : "finished") download of file \(fileNumber)\n")
        } else {
            startTime = Date()
            downloadLogs(isStartDownloading: isStartDownloading, fileNumber: fileNumber)
        }
    }
    
    func presentAlert(text: String) {
        let alert = UIAlertController(title: "Information", message: text, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
//    MARK: - Face Detector
    
    func startFaceDetector() {
        print("\n\nStart Face Detector\n")
        let queue = DispatchQueue(label: "Gaponenko-Dmitriy.Lab2.queue1.faceDetecting")
        
        queue.async {
            var countFaces = 0
            
            for helpDownloadModel in self.downloadModels {
                if let inputImage = helpDownloadModel.image {
                    let ciImage = CIImage(cgImage: inputImage.cgImage!)
                    
                    let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
                    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
                    let faces = faceDetector.features(in: ciImage)
                    
                    print("in file \(helpDownloadModel.fileName) founded \(faces.count) faces\n")
                    countFaces += faces.count
                }
            }
            DispatchQueue.main.async {
                self.presentAlert(text: "\nGeneral Face Detector find \(countFaces) faces\n\n")
            }
            print("\nGeneral Face Detector find \(countFaces) faces\n\n")
        }
    }
    
}

