//
//  FileUploader.swift
//  RentGuru
//
//  Created by Workspace Infotech on 8/5/16.
//  Copyright © 2016 Workspace Infotech. All rights reserved.
//
import Foundation
import Alamofire

private struct FileUploadInfo {
    var name:String
    var mimeType:String
    var fileName:String
    var url:URL?
    var data:Data?
    
//    init( name: String, withFileURL url: URL, withMimeType mimeType: String? = nil ) {
//        self.name = name
//        self.url = url
//        self.fileName = name
//        self.mimeType = "application/octet-stream"
//        if mimeType != nil {
//            self.mimeType = mimeType!
//        }
//        if let _name = url.lastPathComponent {
//            fileName = _name
//        }
//        if mimeType == nil,let _extension = url.pathExtension {
//            switch _extension.lowercased() {
//                
//            case "jpeg", "jpg":
//                self.mimeType = "image/jpeg"
//                
//            case "png":
//                self.mimeType = "image/png"
//                
//            default:
//                self.mimeType = "application/octet-stream"
//            }
//        }
//    }
    
    init( name: String, withData data: Data, withMimeType mimeType: String , withFileName filename: String) {
        self.name = name
        self.data = data
        self.fileName = filename
        self.mimeType = mimeType
    }
}

class FileUploader {
    
    fileprivate var parameters = [String:String]()
    fileprivate var files = [FileUploadInfo]()
    fileprivate var headers = [String:String]()
    
    func setValue( _ value: String, forParameter parameter: String ) {
        parameters[parameter] = value
    }
    
    func setValue( _ value: String, forHeader header: String ) {
        headers[header] = value
    }
    
    func addParametersFrom( _ map: [String:String] ) {
        for (key,value) in map {
            parameters[key] = value
        }
    }
    
    func addHeadersFrom( _ map: [String:String] ) {
        for (key,value) in map {
            headers[key] = value
        }
    }
    
//    func addFileURL( _ url: URL, withName name: String, withMimeType mimeType:String? = nil ) {
//        files.append( FileUploadInfo( name: name, withFileURL: url, withMimeType: mimeType ) )
//    }
//    
    func addFileData( _ data: Data, withName name: String, withMimeType mimeType:String = "application/octet-stream" , withFileName filename: String ) {
        files.append( FileUploadInfo( name: name, withData: data, withMimeType: mimeType , withFileName : filename) )
    }
    
//    func uploadFile( request sourceRequest: URLRequest ) -> Request? {
//        let request = (sourceRequest as NSURLRequest).mutableCopy() as! NSMutableURLRequest
//        let boundary = "FileUploader-boundary-\(arc4random())-\(arc4random())"
//        request.setValue( "multipart/form-data;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let data = NSMutableData()
//        
//        for (name, value) in headers {
//            request.setValue(value, forHTTPHeaderField: name)
//        }
//        
//        // Amazon S3 (probably others) wont take parameters after files, so we put them first
//        for (key, value) in parameters {
//            data.append("\r\n--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
//            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
//        }
//        
//        for fileUploadInfo in files {
//            data.append( "\r\n--\(boundary)\r\n".data(using: String.Encoding.utf8)! )
//            data.append( "Content-Disposition: form-data; name=\"\(fileUploadInfo.name)\"; filename=\"\(fileUploadInfo.fileName)\"\r\n".data(using: String.Encoding.utf8)!)
//            data.append( "Content-Type: \(fileUploadInfo.mimeType)\r\n\r\n".data(using: String.Encoding.utf8)!)
//            if fileUploadInfo.data != nil {
//                data.append( fileUploadInfo.data! )
//            }
//            else if fileUploadInfo.url != nil, let fileData = try? Data(contentsOf: fileUploadInfo.url!) {
//                data.append( fileData )
//            }
//            else { // ToDo: report error
//                return nil
//            }
//        }
//        
//        data.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
//        return Alamofire.upload(data:data, to:)
//        //return Alamofire.upload( request, data: data )
//       // return Alamofire.upload(data, to: request.url as String)
//    }
    
}
