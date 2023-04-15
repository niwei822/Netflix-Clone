//
//  DataPersistenceManager.swift
//  Netflix Clone Project
//
//  Created by cecily li on 4/14/23.
//

import Foundation
import UIKit
import CoreData

class DataPersistenceManager {
    
    enum DatabaseError: Error {
        case failToSaveData
        case failToFetchData
        case failToDeleteData
    }
    static let shared = DataPersistenceManager()
    
    func downloadTitleWith(model: Movie, completion: (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let item = MoviesItem(context: context)
        
        item.original_title = model.original_title
        item.id = Int64(model.id)
        item.name = model.name
        item.overview = model.overview
        item.poster_path = model.poster_path
        item.media_type = model.media_type
        item.release_date = model.release_date
        item.vote_count = Int64(model.vote_count)
        item.vote_average = model.vote_average
        
        do {
            try context.save()
            completion(.success(()))
        }catch {
            completion(.failure(DatabaseError.failToSaveData))
        }
    }
    
    func fetchingTitlesFromDatabase(completion: @escaping (Result<[MoviesItem], Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<MoviesItem>
        request = MoviesItem.fetchRequest()
        
        do {
            let titles = try context.fetch(request)
            completion(.success(titles))
            
        } catch {
            completion(.failure(DatabaseError.failToFetchData))
        }
    }
    
    func deleteTitleWith(model: MoviesItem, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        context.delete(model)
        
        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failToDeleteData))
        }
    }
}
