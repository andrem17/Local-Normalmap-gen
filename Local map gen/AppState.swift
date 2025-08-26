import SwiftUI

class AppState: ObservableObject {
    @Published var searchText: String = ""
    @Published var exportFormat: String = "PNG"
    @Published var exportPath: String = ""
    
    func exportNow() {
        print("Exportando para \(exportPath) no formato \(exportFormat)")
        // Lógica de exportação aqui
    }
}
