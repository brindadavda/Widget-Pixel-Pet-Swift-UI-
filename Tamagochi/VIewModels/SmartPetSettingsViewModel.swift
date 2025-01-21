//
//  SettingsViewModel_TamagochiVVV.swift
//  Tamagochi
//
//  Created by Systems
//

import CoreLocation
import SwiftUI
import Combine
import WeatherKit
import ActivityKit

// view model for settings
class SmartPetSettingsViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    struct PhotoInfo: Identifiable, Equatable {
        let id: String
        let data: Data
    }
    
    private let locationManager = CLLocationManager()
    private let activityTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let soundPlayer = SoundPlayer.shared
    
    private var activity: Activity<TamagochiWidgetAttributes>?
    private var subscribers = Set<AnyCancellable>()
    private var defaultContent: ActivityContent<TamagochiWidgetAttributes.ContentState>?
    private var backgroundTask: UIBackgroundTaskIdentifier?
    
    private(set) var userLocation: CLLocation?
    
    @AppStorage("photoNames", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var photoNames = [String]()
    @AppStorage("availableWidgets", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var availableWidgets = WidgetType_TamagochiVVV.allCases
    @AppStorage("temperatureUnit", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var temperatureUnit = TemperatureUnit.celsius
    @AppStorage("alwaysShowPixelPal", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var alwaysShowPixelPal = false
    @AppStorage("showSecondPixelPal", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var showSecondPixelPal = false
    @AppStorage("pixelPalActionLA", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var pixelPalActionLA = PixelPalAction.run
    @AppStorage("secondPixelPalActionLA", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var secondPixelPalActionLA = PixelPalAction.run
    @AppStorage("firstPixelPal", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var firstPixelPal = Cats.luna
    @AppStorage("secondPixelPal", store: UserDefaults(suiteName: AppConstants.groupName.rawValue)) var secondPixelPal = Cats.luna
    
    @Published private(set) var requestingCity = false
    @Published private(set) var currentCity = "Unknown"
    @Published private(set) var availablePhotos = [PhotoInfo]()
    @Published private(set) var availableWidgetBGs = [PhotoInfo]()
    @Published private(set) var status = CLAuthorizationStatus.notDetermined
    @Published private(set) var allTamagochies = [TamagochiObject]()
    
    // MARK: - Inits
    
    convenience init(isForWidget: Bool) {
        self.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if let loadedLocation = UserDefaults(suiteName: AppConstants.groupName.rawValue)?.data(forKey: "savedLocation"),
           let decodedLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: loadedLocation) {
            userLocation = decodedLocation
        }
        if let loadedCity = UserDefaults(suiteName: AppConstants.groupName.rawValue)?.data(forKey: "savedCity"),
           let decodedCity = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSString.self, from: loadedCity) {
            currentCity = decodedCity as String
        }
        if !isForWidget {
            setupActivityTimer()
            availablePhotos = getPhotos(from: "Photos")
            getWidgetBGs()
        }
    }
    
    private override init() {
        super.init()
    }
    
    // MARK: - Methods
    
    @available(iOSApplicationExtension, unavailable)
    func startBGTask() {
        if backgroundTask != nil {
            UIApplication.shared.endBackgroundTask(backgroundTask!)
            backgroundTask = UIBackgroundTaskIdentifier.invalid
        }
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
            UIApplication.shared.endBackgroundTask(self.backgroundTask!)
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
        })
    }
    
    private func setupActivityTimer() {
        
        var imageIndexForFirstPal = 1
        var imageIndexForSecondPal = 1
        activityTimer
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                if self.alwaysShowPixelPal && self.activity != nil && !self.allTamagochies.isEmpty {
                    let firstTamagochi = self.allTamagochies.first(where: {$0.startName == self.firstPixelPal}) ?? self.allTamagochies.first!
                    let secondTamagochi = self.showSecondPixelPal ? self.allTamagochies.first(where: {$0.startName == self.secondPixelPal}) : nil
                    let firstData = firstTamagochi.imagesData[pixelPalActionLA]
                    let secondData = secondTamagochi?.imagesData[secondPixelPalActionLA]
                    if let firstData {
                        if imageIndexForFirstPal >= firstData.count {
                            imageIndexForFirstPal = 0
                        }
                        let firstCurrentData = firstData[imageIndexForFirstPal]
                        if imageIndexForFirstPal != firstData.count - 1 {
                            imageIndexForFirstPal += 1
                        } else {
                            imageIndexForFirstPal = 0
                        }
                        var secondCurrentData: Data?
                        if let secondData {
                            if imageIndexForSecondPal >= secondData.count {
                                imageIndexForSecondPal = 0
                            }
                            secondCurrentData = secondData[imageIndexForSecondPal]
                            if imageIndexForSecondPal != secondData.count - 1 {
                                imageIndexForSecondPal += 1
                            } else {
                                imageIndexForSecondPal = 0
                            }
                        }
                        let state = TamagochiWidgetAttributes.ContentState(firstTamagochiImageData: firstCurrentData, secondTamagochiImageData: secondCurrentData)
                        let content = ActivityContent(state: state, staleDate: nil)
                        Task {
                            await self.activity?.update(content)
                        }
                    }
                }
            })
            .store(in: &subscribers)
        soundPlayer.timer = activityTimer
    }
    
    func setAllTamagochies(_ newValue: [TamagochiObject]) {
        allTamagochies = newValue
    }
    
    func setActivity() {
        Task {
            if activity == nil && !allTamagochies.isEmpty {
                let firstTamagochi = allTamagochies.first(where: {$0.startName == firstPixelPal}) ?? allTamagochies.first!
                let secondTamagochi = showSecondPixelPal ? allTamagochies.first(where: {$0.startName == secondPixelPal}) : nil
                let attributes = TamagochiWidgetAttributes(firstTamagochiName: firstTamagochi.startName.rawValue, secondTamagochiName: secondTamagochi?.startName.rawValue)
                let firstData = firstTamagochi.imagesData[pixelPalActionLA]
                let secondData = secondTamagochi?.imagesData[secondPixelPalActionLA]
                if let firstData {
                    let firstCurrentData = firstData[0]
                    var secondCurrentData: Data?
                    if let secondData {
                        secondCurrentData = secondData[0]
                    }
                    let state = TamagochiWidgetAttributes.ContentState(firstTamagochiImageData: firstCurrentData, secondTamagochiImageData: secondCurrentData)
                    defaultContent = ActivityContent(state: state, staleDate: nil)
                    await startActivity(with: attributes)
                }
            }
        }
    }
    
    private func startActivity(with attributes: TamagochiWidgetAttributes) async {
        if let defaultContent {
            let currentAppActivities = Activity<TamagochiWidgetAttributes>.activities
            for currentAppActivity in currentAppActivities {
                await currentAppActivity.end(defaultContent, dismissalPolicy: .immediate)
            }
            do {
                activity = try Activity<TamagochiWidgetAttributes>.request(attributes: attributes, content: defaultContent)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func endActivity() {
        Task {
            if let defaultContent {
                await activity?.end(defaultContent, dismissalPolicy: .immediate)
                activity = nil
            }
        }
    }
    
    func restartActivity() {
        Task {
            if let defaultContent {
                await activity?.end(defaultContent, dismissalPolicy: .immediate)
                activity = nil
                setActivity()
            }
        }
    }
    
    private func getWidgetBGs() {
        guard let directoryToDelete = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.groupName.rawValue) else { return }
        let fileURL = directoryToDelete.appendingPathComponent("WidgetBackgrounds")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            availableWidgetBGs = getPhotos(from: "WidgetBackgrounds")
        }
        else {
            for i in 1...18 {
                let image = UIImage(named: "widgetPhoto\(i)")?.resized(toWidth: 300)
                if let data = image?.pngData() {
                    availableWidgetBGs.append(PhotoInfo(id: "widgetPhoto\(i)", data: data))
                    saveImage(folderName: "WidgetBackgrounds", imageName: "widgetPhoto\(i)", imageData: data)
                }
            }
        }
    }
    
    private func saveImage(folderName: String, imageName: String, imageData: Data) {
        guard let directoryToSave = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.groupName.rawValue) else { return }
        var fileURL = directoryToSave.appendingPathComponent(folderName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            deleteImage(folderName: folderName, imageName: imageName)
        }
        else {
            do {
                try FileManager.default.createDirectory(atPath: fileURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        fileURL = fileURL.appendingPathComponent(imageName)
        do {
            try imageData.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    private func deleteImage(folderName: String, imageName: String) {
        guard let directoryToDelete = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.groupName.rawValue) else { return }
        var fileURL = directoryToDelete.appendingPathComponent(folderName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            fileURL = fileURL.appendingPathComponent(imageName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                    print("Removed old image")
                } catch let removeError {
                    print("couldn't remove file at path", removeError)
                }
            }
        }
    }
    
    private func loadImageFromDiskWith(folderName: String, fileName: String) -> Data? {
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.groupName.rawValue)?.appendingPathComponent(folderName).appendingPathComponent(fileName)
        if let url {
            do {
                return try Data(contentsOf: url)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func getPhotos(from folder: String) -> [PhotoInfo] {
        var result = [PhotoInfo]()
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.groupName.rawValue)?.appendingPathComponent(folder)
        if let url {
            let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)
            if let enumerator {
                for url in enumerator.allObjects {
                    if let data = try? Data(contentsOf: (url as! NSURL) as URL) {
                        let photoInfo = PhotoInfo(id: ((url as! NSURL) as URL).lastPathComponent, data: data)
                        result.append(photoInfo)
                    }
                }
            }
        }
        return result.sorted(by: {$0.id < $1.id})
    }
    
    func getWidgetBG(with id: Int) -> PhotoInfo? {
        if let photoInfo = availableWidgetBGs.first(where: {$0.id == "widgetPhoto\(id)"}) {
            return photoInfo
        }
        return nil
    }
    
    func getWidgetBGForWidget(with id: Int) -> Data? {
        loadImageFromDiskWith(folderName: "WidgetBackgrounds", fileName: "widgetPhoto\(id)")
    }
    
    func getUserBG(with id: String) -> PhotoInfo? {
        if let photoInfo = availablePhotos.first(where: {$0.id == id}) {
            return photoInfo
        }
        return nil
    }
    
    func getUserBGForWidget(with id: String) -> Data? {
        loadImageFromDiskWith(folderName: "Photos", fileName: id)
    }
    
    // MARK: - Intents
    
    func getWeather() async throws -> [Temperature] {
        if let userLocation {
            let weatherService = WeatherService()
            do {
                let weatherData = try await weatherService.weather(for: userLocation).hourlyForecast
                let currentDate = Date.now
                let calendar = Calendar.current
                let currentComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
                let currentHour = calendar.component(.hour, from: currentDate)
                let hourRange = currentHour..<(currentHour + 4)
                let filteredTempData = weatherData.filter { value in
                    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: value.date)
                    return dateComponents.year == currentComponents.year &&
                        dateComponents.month == currentComponents.month &&
                        dateComponents.day == currentComponents.day &&
                        hourRange.contains(dateComponents.hour!)
                }
                let extractedValues = filteredTempData.map { tempData in
                    var tempDataValue = tempData.temperature
                    switch temperatureUnit {
                    case .celsius:
                        tempDataValue.convert(to: UnitTemperature.celsius)
                    case .fahrenheit:
                        tempDataValue.convert(to: UnitTemperature.fahrenheit)
                    }
                    return Temperature(date: tempData.date, symbolName: tempData.symbolName, value: Int(tempDataValue.value))
                }
                return extractedValues
            } catch {
                throw error
            }
        }
        return []
    }
    
    func requestLocation() {
        if status != .denied {
            requestingCity = true
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func getTransparentBG() -> Data? {
        loadImageFromDiskWith(folderName: "", fileName: "transparentBG")
    }
    
    func saveTransparentBG(_ imageData: Data) {
        saveImage(folderName: "", imageName: "transparentBG", imageData: imageData)
    }
    
    func savePhoto(_ imageData: Data, with name: String) {
        saveImage(folderName: "Photos", imageName: name, imageData: imageData)
        if let index = availablePhotos.firstIndex(where: {$0.id == name}) {
            availablePhotos.remove(at: index)
        }
        availablePhotos.append(PhotoInfo(id: name, data: imageData))
        availablePhotos.sort(by: {$0.id < $1.id})
        if !photoNames.contains(name) {
            photoNames.append(name)
        }
    }
    
    func deletePhoto(with offsets: IndexSet) {
        for index in offsets {
            let photo = availablePhotos[index]
            deleteImage(folderName: "Photos", imageName: photo.id)
            if let index = photoNames.firstIndex(of: photo.id) {
                photoNames.remove(at: index)
            }
        }
        availablePhotos.remove(atOffsets: offsets)
    }
    
}

// MARK: - CLLocationManagerDelegate

extension SmartPetSettingsViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            if let error = error {
                self.requestingCity = false
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                self.currentCity = placemark.locality ?? "Unknown"
            }
            if let encodedLocation = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false) {
                UserDefaults(suiteName: AppConstants.groupName.rawValue)?.set(encodedLocation, forKey: "savedLocation")
            }
            if let encodedLocation = try? NSKeyedArchiver.archivedData(withRootObject: self.currentCity, requiringSecureCoding: false) {
                UserDefaults(suiteName: AppConstants.groupName.rawValue)?.set(encodedLocation, forKey: "savedCity")
            }
            self.requestingCity = false
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = locationManager.authorizationStatus
        if locationManager.authorizationStatus == .denied {
            requestingCity = false
            locationManager.stopUpdatingLocation()
        }
    }
    
}
