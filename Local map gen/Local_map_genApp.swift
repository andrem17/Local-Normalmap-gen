import SwiftUI

@main
struct Local_map_genApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppState())
        }
    }
}
struct LocalMapGen3D: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.5))
            .overlay(Text("Preview 3D (em construção)").foregroundStyle(.white))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LocalMapGen3D_Previews: PreviewProvider {
    static var previews: some View {
        LocalMapGen3D()
    }
}
