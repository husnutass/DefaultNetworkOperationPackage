//
//  APIManager.swift
//  CartCodeCase
//
//  Created by Erkut Bas on 20.10.2020.
//

import Foundation
import Network

public class APIManager: APIManagerInterface {

    // Mark: - Session -
    private let session: URLSession

    // Mark: - JsonDecoder -
    private var jsonDecoder = JSONDecoder()
    
    private var apiCallListener: ApiCallListener?

    public init(apiCallListener: ApiCallListener? = nil) {
        self.apiCallListener = apiCallListener
        let config = URLSessionConfiguration.default
        if #available(iOS 11.0, *) {
            config.waitsForConnectivity = true
        } else {
            // Fallback on earlier versions
        }
        config.timeoutIntervalForResource = 300
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: config)
    }
    
    public func executeRequest<R>(urlRequest: URLRequest, completion: @escaping (Result<R, ErrorResponse>) -> Void) where R : Codable {
        apiCallListener?.onPreExecute()
        
        session.dataTask(with: urlRequest) { [weak self](data, urlResponse, error) in
            self?.dataTaskHandler(data, urlResponse, error, completion: completion)
        }.resume()
        
    }
    
    private func dataTaskHandler<R: Codable>(_ data: Data?, _ response: URLResponse?, _ error: Error?, completion: @escaping (Result<R, ErrorResponse>) -> Void) {
        
        if error != nil {
            // completion failure
            print("error : \(String(describing: error))")
            let errorResponse = ErrorResponse(serverResponse: ServerResponse(returnMessage: error!.localizedDescription, returnCode: error!._code), apiConnectionErrorType: .serverError(error!._code))
            completion(.failure(errorResponse))
        }
        
        if let data = data {
            
            do {
                print(String(data: data, encoding: .utf8)!)
                let dataDecoded = try jsonDecoder.decode(R.self, from: data)
                print("data : \(data)")
                completion(.success(dataDecoded))
            } catch let error {
                // completion failure
                print("error : \(error)")
                let errorResponse = ErrorResponse(serverResponse: ServerResponse(returnMessage: error.localizedDescription, returnCode: error._code), apiConnectionErrorType: .dataDecodedFailed(error.localizedDescription))
                completion(.failure(errorResponse))
            }
        }
        apiCallListener?.onPostExecute()
    }
    
    deinit {
        print("DEINIT APIMANAGER")
    }
    
}
