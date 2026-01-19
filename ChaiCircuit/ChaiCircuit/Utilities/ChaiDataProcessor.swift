import Foundation

// MARK: - Chai Data Processor
// Уникальный класс для обфускации данных (XOR + Base64)
final class ChaiDataProcessor {
    
    // Уникальный ключ для проекта ChaiCircuit
    private static let chaiTransformKey = "ChaiCircuit_DataTransform_2024_Key!"
    
    /// Обфускация строки (XOR + Base64)
    static func chaiTransform(_ chaiInput: String) -> String? {
        guard !chaiInput.isEmpty else {
            print("📝 [ChaiDataProcessor] Empty input received")
            return nil
        }
        
        let chaiKeyBytes = Array(chaiTransformKey.utf8)
        let chaiInputBytes = Array(chaiInput.utf8)
        var chaiOutputBytes = [UInt8]()
        
        for (chaiIndex, chaiByte) in chaiInputBytes.enumerated() {
            let chaiKeyByte = chaiKeyBytes[chaiIndex % chaiKeyBytes.count]
            chaiOutputBytes.append(chaiByte ^ chaiKeyByte)
        }
        
        let chaiResult = Data(chaiOutputBytes).base64EncodedString()
        print("📝 [ChaiDataProcessor] Data transformed, length: \(chaiResult.count)")
        return chaiResult
    }
    
    /// Деобфускация строки (Base64 + XOR)
    static func chaiRestore(_ chaiInput: String) -> String? {
        guard let chaiData = Data(base64Encoded: chaiInput) else {
            print("📝 [ChaiDataProcessor] Failed to decode input")
            return nil
        }
        
        let chaiKeyBytes = Array(chaiTransformKey.utf8)
        let chaiInputBytes = Array(chaiData)
        var chaiOutputBytes = [UInt8]()
        
        for (chaiIndex, chaiByte) in chaiInputBytes.enumerated() {
            let chaiKeyByte = chaiKeyBytes[chaiIndex % chaiKeyBytes.count]
            chaiOutputBytes.append(chaiByte ^ chaiKeyByte)
        }
        
        guard let chaiResult = String(bytes: chaiOutputBytes, encoding: .utf8) else {
            print("📝 [ChaiDataProcessor] Failed to convert bytes to string")
            return nil
        }
        
        print("📝 [ChaiDataProcessor] Data restored successfully")
        return chaiResult
    }
}
