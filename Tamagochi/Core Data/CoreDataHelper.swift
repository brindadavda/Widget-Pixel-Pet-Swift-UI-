import Foundation
import CoreData

final class CoreDataHelper {
    
    // MARK: - Properties
    
    var shouldSave = true
    
    static private var shared: CoreDataHelper?
    private let persistentContainer: NSPersistentContainer
    private var logic: TamagochiLogicEnt?
    private var allTamagochies = [TamagochiEntity]()
    private typealias constants = CoreDataHelperConstants
    
    // MARK: - Inits
    
    private init(isForWidget: Bool = false) {
        persistentContainer = NSPersistentContainer(name: constants.modelName)
        if var fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.groupName.rawValue) {
            fileContainer = fileContainer.appendingPathComponent("\(constants.modelName).sqlite")
            let description = NSPersistentStoreDescription(url: fileContainer)
            persistentContainer.persistentStoreDescriptions = [description]
        }
        persistentContainer.loadPersistentStores { description, error in
            guard error == nil else { print("Error of loading: \(error!.localizedDescription)"); return }
        }
        if !isForWidget {
            if let logics = arrayOf(TamagochiLogicEnt.self, context: persistentContainer.viewContext), !logics.isEmpty {
                logic = logics.first!
            }
            else {
                logic = TamagochiLogicEnt(context: persistentContainer.viewContext)
            }
            let sortDesc = NSSortDescriptor(key: "id", ascending: true)
            allTamagochies = arrayOf(TamagochiEntity.self, sortDescriptor: [sortDesc], context: persistentContainer.viewContext) ?? []
            saveAll()
        }
    }
    
    // MARK: - Methods
    
    static func getCoreData(isForWidget: Bool = false) -> CoreDataHelper {
        if shared == nil {
            shared = CoreDataHelper(isForWidget: isForWidget)
        }
        return shared!
    }
    
    private func arrayOf<T: NSManagedObject>(_ entity: T.Type,
                                             predicate: NSPredicate? = nil,
                                             sortDescriptor: [NSSortDescriptor]? = nil,
                                             context: NSManagedObjectContext) -> [T]? {
        let fetchRequest = NSFetchRequest<T>(entityName: NSStringFromClass(T.self))
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }
        if sortDescriptor != nil {
            fetchRequest.sortDescriptors = sortDescriptor!
        }
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let searchResult = try context.fetch(fetchRequest)
            if !searchResult.isEmpty {
                return searchResult
            } else {
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func saveAll() {
        if shouldSave {
            if persistentContainer.viewContext.hasChanges {
                do {
                    try persistentContainer.viewContext.save()
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteOldActionData(for tamagochiEntity: TamagochiEntity) {
        guard let actionDataSet = tamagochiEntity.actionData else { return }
        
        for actionData in actionDataSet {
            if let actionData = actionData as? TamagochiActionData {
                if let images = actionData.images {
                    for image in images {
                        persistentContainer.viewContext.delete(image as! NSManagedObject)
                    }
                }
                persistentContainer.viewContext.delete(actionData)
            }
        }
        
        saveAll()
    }
    
    @discardableResult
    private func getTamagochiEnt(from tamagochiObject: TamagochiObject) -> TamagochiEntity {
        let tamagochi = allTamagochies.first(where: { Int($0.id) == tamagochiObject.id })
        let tamagochiEnt = tamagochi ?? TamagochiEntity(context: persistentContainer.viewContext)
        if let tamagochi = tamagochi {
            deleteOldActionData(for: tamagochi)
        }
        tamagochiEnt.startName = tamagochiObject.startName.rawValue
        tamagochiEnt.lastTimePlayed = tamagochiObject.lastTimePlayed
        tamagochiEnt.lastTimeFed = tamagochiObject.lastTimeFed
        tamagochiEnt.scrolledEogether = tamagochiObject.scrolledEogether
        tamagochiEnt.health = Int64(tamagochiObject.health)
        tamagochiEnt.name = tamagochiObject.name
        tamagochiEnt.creationDate = tamagochiObject.creationDate
        tamagochiEnt.weight = tamagochiObject.weight
        tamagochiEnt.id = Int64(tamagochiObject.id)
        tamagochiEnt.normalImageData = tamagochiObject.normalImageData
        tamagochiEnt.lieImageData = tamagochiObject.lieImageData
        tamagochiEnt.sitImageData = tamagochiObject.sitImageData
        for (key, value) in tamagochiObject.imagesData {
            let actionEnt = TamagochiActionData(context: persistentContainer.viewContext)
            actionEnt.action = key.rawValue
            for image in value {
                let id = value.firstIndex(of: image) ?? 0
                let imageEnt = TamagochiImage(context: persistentContainer.viewContext)
                imageEnt.id = Int64(id)
                imageEnt.image = image
                actionEnt.addToImages(imageEnt)
            }
            tamagochiEnt.addToActionData(actionEnt)
        }
        if tamagochi == nil {
            allTamagochies.append(tamagochiEnt)
        }
        saveAll()
        return tamagochiEnt
    }
    
    func getTamagochiImages(with startName: Cats, and action: PixelPalAction) -> [Data] {
        let tamagochiPredicate = NSPredicate(format: "startName = %@", startName.rawValue)
        let actionPredicate = NSPredicate(format: "action = %@", action.rawValue)
        if let tamagochi = arrayOf(TamagochiEntity.self, predicate: tamagochiPredicate, context: persistentContainer.viewContext)?.first {
            if let action = tamagochi.actionData?.filtered(using: actionPredicate).first as? TamagochiActionData {
                if let tamagochiImages = action.images?.array as? [TamagochiImage] {
                    var result = [Data]()
                    for tamagochiImage in tamagochiImages {
                        result.append(tamagochiImage.image ?? Data())
                    }
                    return result
                }
            }
        }
        return []
    }
    
    func getTamagochies() -> [TamagochiObject] {
        allTamagochies.map({ TamagochiObject(from: $0) })
    }
    
    func getLogic() -> TamagochiLogic {
        let logics = arrayOf(TamagochiLogicEnt.self, context: persistentContainer.viewContext)
        if let logics, !logics.isEmpty {
            let logic = logics.first!
            if logic.currentTamagochi == nil {
                logic.currentTamagochi = allTamagochies.first(where: { $0.id == 1 })
            }
            return TamagochiLogic(from: logic)
        } else {
            fatalError()
        }
    }
    
    func updateLogic(with newValue: TamagochiLogic) {
        if newValue.currentTamagochi.id != -1 {
            logic?.currentTamagochi = getTamagochiEnt(from: newValue.currentTamagochi)
            saveAll()
        }
    }
    
    func addTamagochies(_ tamagochies: [TamagochiObject]) {
        for tamagochy in tamagochies {
            getTamagochiEnt(from: tamagochy)
        }
        saveAll()
    }
    
    func updateHealth(id: Int, newHealth: Int) {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                tamagochiEntity.health = Int64(newHealth)
                try persistentContainer.viewContext.save()
            }
        } catch {
            print("Ошибка сохранения здоровья в Core Data: \(error)")
        }
    }
    
    func getHealth(for id: Int) -> Int {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                return Int(tamagochiEntity.health)
            }
        } catch {
            print("Ошибка извлечения здоровья из Core Data: \(error)")
        }
        return TamagochiObjectConstants.defaultHealth
    }
    
    func getName(for id: Int) -> String? {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                return tamagochiEntity.name
            }
        } catch {
            print("Ошибка извлечения имени из Core Data: \(error)")
        }
        return nil
    }
    
    func getScrolledEogether(for id: Int) -> Double {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                return tamagochiEntity.scrolledEogether
            }
        } catch {
            print("Ошибка извлечения scrolledEogether из Core Data: \(error)")
        }
        return 0.0
    }
    
    func updateName(id: Int, newName: String) {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                tamagochiEntity.name = newName
                try persistentContainer.viewContext.save()
            }
        } catch {
            print("Ошибка сохранения имени в Core Data: \(error)")
        }
    }
    
    func updateScrolledEogether(id: Int, newValue: Double) {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                tamagochiEntity.scrolledEogether = newValue
                try persistentContainer.viewContext.save()
            }
        } catch {
            print("Ошибка сохранения scrolledEogether в Core Data: \(error)")
        }
    }
    
    func updateLastTimeFed(id: Int, newValue: Date) {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                tamagochiEntity.lastTimeFed = newValue
                try persistentContainer.viewContext.save()
            }
        } catch {
            print("Ошибка сохранения времени последнего кормления в Core Data: \(error)")
        }
    }
    
    func updateLastTimePlayed(id: Int, newValue: Date) {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                tamagochiEntity.lastTimePlayed = newValue
                try persistentContainer.viewContext.save()
            }
        } catch {
            print("Ошибка сохранения времени последней игры в Core Data: \(error)")
        }
    }
    
    func getLastTimeFed(for id: Int) -> Date {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                return tamagochiEntity.lastTimeFed ?? Date(timeIntervalSince1970: .zero)
            }
        } catch {
            print("Ошибка извлечения времени последнего кормления из Core Data: \(error)")
        }
        return Date(timeIntervalSince1970: .zero)
    }
    
    func getLastTimePlayed(for id: Int) -> Date {
        let fetchRequest: NSFetchRequest<TamagochiEntity> = TamagochiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            if let tamagochiEntity = results.first {
                return tamagochiEntity.lastTimePlayed ?? Date(timeIntervalSince1970: .zero)
            }
        } catch {
            print("Ошибка извлечения времени последней игры из Core Data: \(error)")
        }
        return Date(timeIntervalSince1970: .zero)
    }
    
}

// MARK: - Constants

private struct CoreDataHelperConstants {
    static let modelName = "TamagochiModel"
}
