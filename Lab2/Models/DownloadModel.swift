//
//  DownloadModel.swift
//  Lab2
//
//  Created by Konstantyn Byhkalo on 1/20/17.
//  Copyright © 2017 Gaponenko Dmitriy. All rights reserved.
//

import Foundation
import UIKit

protocol DownloadModelProtocol {
    
    func compleateDownloadCellBy(downloadModel: DownloadModel)
    
}

class DownloadModel: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
//    MARK: - Properties
    
    var linkString: String!
    var indexPath: IndexPath!
    var tableView: UITableView!
    
    var delegate: DownloadModelProtocol!
    var downloadTask: URLSessionDownloadTask?
    
    var isCompleated = false
    var image: UIImage?
    var fileName: String!
    
    let documentsUrlFile = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    var fileURL: URL {
        return documentsUrlFile.appendingPathComponent(self.fileName)
    }
    
//    MARK: - Initialization
    
    init(linkString: String,
         indexPath: IndexPath,
         tableView: UITableView,
         delegate: DownloadModelProtocol) {
        super.init()
        
        self.linkString = linkString
        self.indexPath = indexPath
        self.tableView = tableView
        self.delegate = delegate
        
        let components = linkString.components(separatedBy: "/")
        let fileName = components.last
        self.fileName = fileName!
    }
    
//    MARK: - First Start function
    
    func configurateDownloading() {
        guard !checkIsHasImage() else {
            downloadingIsFinish()
            return
        }
        let backgroundIdentifier = "backgroundIdentifier#\(indexPath.row)"
        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundIdentifier)
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        if let url = URL(string: Constants.links[indexPath.row]) {
            let downloadTask = session.downloadTask(with: url)
            downloadTask.resume()
            self.downloadTask = downloadTask
        }
    }
    
    private func checkIsHasImage() -> Bool {
        
        return UIImage(contentsOfFile: fileURL.path) != nil
    }
    
//    MARK: - URLSessionDownloadDelegate
    
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("Downloading failed. Error: \n\n\(error)\n\n")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.copyItem(at: location, to: fileURL)
                downloadingIsFinish()
        } catch {
            print("Error Copying Item from \(location.path) to \(fileURL.path)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesWritten == totalBytesExpectedToWrite {
            downloadingIsFinish()
        } else{
            configureCell()
        }
    }

//    MARK: - Finalize Downloading
    
    func downloadingIsFinish() {
        if !isCompleated && checkIsHasImage() {
            isCompleated = true
            configureCell()
            delegate.compleateDownloadCellBy(downloadModel: self)
        } else {
            configureCell()
        }
    }
    
//    MARK: - Cell Configuration
    
    func configureCell() {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        _ = configureCell(cell)
    }

    func configureCell(_ cell: UITableViewCell) -> UITableViewCell {
        
        var detailText = isCompleated ? "Compleated" : "Wait for download..."
        
        if let downloadTask = downloadTask, downloadTask.countOfBytesExpectedToReceive != 0 {
            let expect = Float(downloadTask.countOfBytesExpectedToReceive)
            let recieved = Float(downloadTask.countOfBytesReceived)
            let completedTask = (recieved / expect) * 100.0
            detailText = completedTask == 100 ? "Compleated" : "Downloading, \(completedTask)% done..."
        }
        
        DispatchQueue.main.async {
            cell.textLabel?.text = self.fileName
            cell.detailTextLabel?.text = detailText
        }
        
        if let image = image {
            DispatchQueue.main.async {
                cell.imageView?.image = image
            }
        } else {
            if let newImage = UIImage(contentsOfFile: fileURL.path) {
                self.image = newImage
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [self.indexPath], with: .automatic)
                }
            }
        }

        return cell
    }
    
}
