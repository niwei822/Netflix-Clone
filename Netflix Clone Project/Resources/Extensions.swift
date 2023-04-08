//
//  Extensions.swift
//  Netflix Clone Project
//
//  Created by cecily li on 4/7/23.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}
