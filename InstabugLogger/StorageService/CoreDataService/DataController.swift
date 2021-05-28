//
//  DataController.swift
//  InstabugLogger
//
//  Created by mahmoud diab on 26/05/21.
//

import Foundation
import CoreData

class DataController {
    
    let persistenceContainer:NSPersistentContainer
    private let modelName:String
    private let storeType = "sqlite"
    private let url :URL
    
    init(modelName:String) {
        self.persistenceContainer = NSPersistentContainer(name: modelName)
        self.modelName = modelName
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("\(modelName).\(storeType)")
        self.url = url
        //   assert(FileManager.default.fileExists(atPath: url.path))
    }
    
    // Access the context
    var viewContext:NSManagedObjectContext {
        return persistenceContainer.viewContext
    }
    var backGroundContext:NSManagedObjectContext { 
        return persistenceContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backGroundContext.automaticallyMergesChangesFromParent = true
        backGroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    // Access persistence store
    func loadPersistenceStore (completion:(()->Void)? = nil ) {
        persistenceContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
            self.configureContexts()
        }
    }
    
    func destroyPersistentStore() {
        try! persistenceContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: storeType, options: nil) 
    }
}  

extension NSManagedObjectContext {
    public func saveIfNeeded() throws -> Bool {
        guard hasChanges else { return false }
        try save()
        return true
    }
    
    public func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws { 
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
