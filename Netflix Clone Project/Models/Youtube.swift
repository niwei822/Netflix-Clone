//
//  Youtube.swift
//  Netflix Clone Project
//
//  Created by cecily li on 4/8/23.
//

import Foundation

struct Youtube: Codable {
    let items:[VideoElement]
}

struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
