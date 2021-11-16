//
//  ApiCallListener.swift
//  
//
//  Created by Hüsnü Taş on 16.11.2021.
//

import Foundation

public protocol ApiCallListener {
    func onPreExecute()
    func onPostExecute()
}
