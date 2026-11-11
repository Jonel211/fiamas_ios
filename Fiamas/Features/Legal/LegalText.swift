import Foundation

// MARK: - Modelos de Datos
struct LegalDataModel: Codable {
    let terms: TermsContent
    let privacy: PrivacyContent
}

struct TermsContent: Codable {
    let intro: String
    let description: String
    let features: [String]
    let responsibility: String
    let accuracy: String
    let internalUse: String
    let consent: String
    let reports: String
    let noInvoice: String
    let property: String
    let balance: String
    let availability: String
    let updates: String
    let contact: String
}

struct PrivacyContent: Codable {
    let intro: String
    let collectIntro: String
    let collectedData: [String]
    let purposesIntro: String
    let purposes: [String]
    let dataSecurity: String
    let retention: String
    let thirdPartiesIntro: String
    let thirdParties: [String]
    let rights: String
    let updates: String
    let contactIntro: String
    let contactChannels: [String]
}

// MARK: - Cargador de JSON y Fachada LegalText
enum LegalText {
    private static let loadedData: LegalDataModel = {
        guard let url = Bundle.main.url(forResource: "LegalData", withExtension: "json") else {
            fatalError("No se encontró el archivo LegalData.json en el bundle de la app.")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(LegalDataModel.self, from: data)
        } catch {
            fatalError("Error decodificando LegalData.json: \(error)")
        }
    }()

    static var Terms: TermsContent {
        loadedData.terms
    }

    static var Privacy: PrivacyContent {
        loadedData.privacy
    }
}
