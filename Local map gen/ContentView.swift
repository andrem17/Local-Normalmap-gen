import SwiftUI
import AppKit
import SceneKit

// MARK: - Cores (laterais mais claras que o centro)
private let centerBG = Color(nsColor: .windowBackgroundColor)
private let sidebarBG = Color(nsColor: .controlBackgroundColor)
private let tileBG = Color(nsColor: .separatorColor).opacity(0.15)
private let dottedColor = Color.white.opacity(0.25)
private let headerFont = Font.headline.weight(.semibold)

// MARK: - Botão reutilizável (círculo preenchido com azul a 20%)
struct SidebarToggleButton: View {
    var systemName: String = "sidebar.leading"
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .imageScale(.large)
                .padding(6)
                .background(Circle().fill(Color.accentColor.opacity(0.2)))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
        .help("Mostrar/ocultar barra lateral")
    }
}

// MARK: - Left Sidebar (busca + rodapé de excluir)
struct LeftSidebar: View {
    @Binding var searchText: String
    var onHide: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Buscar no histórico...", text: $searchText)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 10)
                        .frame(height: 26)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(nsColor: .textBackgroundColor))
                                )
                        )
                }
                .frame(maxWidth: .infinity)
                SidebarToggleButton(systemName: "sidebar.leading", action: onHide)
            }
            .padding([.top, .horizontal], 10)
            Spacer()
            Text("Sem itens no histórico")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {} label: {
                Label("Excluir", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
    }
}

// MARK: - Right Sidebar
struct RightSidebar: View {
    @EnvironmentObject var state: AppState
    var onHide: () -> Void
    private var exportFormatBinding: Binding<String> {
        Binding(get: { state.exportFormat }, set: { state.exportFormat = $0 })
    }
    private var exportPathBinding: Binding<String> {
        Binding(get: { state.exportPath }, set: { state.exportPath = $0 })
    }
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                SidebarToggleButton(systemName: "sidebar.trailing", action: onHide)
                Text("Preview")
                    .font(headerFont)
                Spacer()
            }
            .padding([.top, .horizontal], 12)
            .padding(.bottom, 8)
            Preview3DController()
                .frame(maxHeight: 160)
                .background(centerBG)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Divider()
            Text("Exportar")
                .font(headerFont)
                .frame(maxWidth: .infinity, alignment: .leading)
            Picker("Formato", selection: exportFormatBinding) {
                ForEach(["PNG", "JPG", "TIF", "EXR"], id: \.self) { Text($0) }
            }
            HStack {
                TextField("/caminho/da/pasta…", text: exportPathBinding)
                    .textFieldStyle(.roundedBorder)
                Button("Escolher…") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.prompt = "Escolher"
                    if panel.runModal() == .OK, let url = panel.url {
                        exportPathBinding.wrappedValue = url.path
                    }
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button("Exportar…") { state.exportNow() }
                    .keyboardShortcut(.return)
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

// MARK: - Grade de mapas
struct MapsGrid: View {
    let titles: [String]
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 110), spacing: 16), count: 5)
    }
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
            ForEach(titles, id: \.self) { name in
                VStack(alignment: .leading, spacing: 6) {
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(tileBG)
                        .overlay(Text("–").font(.title3).foregroundStyle(.secondary))
                        .frame(minHeight: 120)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }
}

// MARK: - DropZone
struct OriginalDropZone: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 6]))
                        .foregroundStyle(dottedColor)
                )
            VStack(spacing: 10) {
                Image(systemName: "tray.and.arrow.down")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(.secondary)
                Text("Arraste uma imagem aqui")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Resizable Sidebar Modifier
struct ResizableSidebar: ViewModifier {
    @Binding var width: CGFloat
    let minWidth: CGFloat = 200
    let maxWidth: CGFloat = 400

    func body(content: Content) -> some View {
        content
            .frame(minWidth: minWidth, idealWidth: width, maxWidth: maxWidth)
            .overlay(
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        Spacer().frame(width: geo.size.width - 5)
                        Rectangle()
                            .frame(width: 5)
                            .foregroundStyle(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let newWidth = width + value.translation.width
                                        width = min(max(newWidth, minWidth), maxWidth)
                                    }
                            )
                            .highPriorityGesture(
                                DragGesture()
                                    .onChanged { _ in }
                            )
                    }
                }
                .frame(maxHeight: .infinity)
            )
    }
}

extension View {
    func resizableSidebar(width: Binding<CGFloat>) -> some View {
        self.modifier(ResizableSidebar(width: width))
    }
}

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var state = AppState()
    @State private var isLeftSidebarVisible: Bool = true
    @State private var isRightSidebarVisible: Bool = true
    @State private var leftSidebarWidth: CGFloat = 280
    @State private var rightSidebarWidth: CGFloat = 280

    private let mapTitles = [
        "Normal", "AO", "Roughness", "Gloss", "Specular",
        "Displacement", "Diffuse", "Reflection", "Cavity", "Height"
    ]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // ===== ESQUERDA =====
                if isLeftSidebarVisible {
                    LeftSidebar(
                        searchText: $state.searchText,
                        onHide: { withAnimation(.easeInOut(duration: 0.25)) { isLeftSidebarVisible.toggle() } }
                    )
                    .resizableSidebar(width: $leftSidebarWidth)
                    .background(sidebarBG)
                    .layoutPriority(0.2)
                }

                // ===== CENTRO =====
                VStack(spacing: 0) {
                    // Linha de Títulos
                    HStack(alignment: .top) {
                        if !isLeftSidebarVisible {
                            SidebarToggleButton(systemName: "sidebar.leading") {
                                withAnimation(.easeInOut(duration: 0.25)) { isLeftSidebarVisible.toggle() }
                            }
                        }

                        Text("Mapas gerados")
                            .font(headerFont)
                            .frame(maxWidth: .infinity)

                        if !isRightSidebarVisible {
                            SidebarToggleButton(systemName: "sidebar.trailing") {
                                withAnimation(.easeInOut(duration: 0.25)) { isRightSidebarVisible.toggle() }
                            }
                        }
                    }
                    .padding([.top, .horizontal], 12)
                    .padding(.bottom, 8)

                    // Conteúdo Principal
                    VStack(spacing: 0) {
                        // Seção Mapas Gerados
                        VStack(alignment: .leading, spacing: 0) {
                            MapsGrid(titles: mapTitles)
                                .padding(.horizontal, 12)
                        }
                        .layoutPriority(1)

                        // Divisor Central
                        Divider().overlay(Color(nsColor: .separatorColor))
                            .padding(.vertical, 12)

                        // Seção Original
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Original").font(headerFont)
                                Spacer()
                                Button("Adicionar imagem") {
                                    let panel = NSOpenPanel()
                                    panel.canChooseFiles = true
                                    panel.canChooseDirectories = false
                                    panel.allowedContentTypes = [.image]
                                    if panel.runModal() == .OK, let url = panel.url {
                                        print("Imagem adicionada: \(url.path)")
                                    }
                                }
                            }
                            .padding(.horizontal, 12)

                            OriginalDropZone()
                                .padding(.horizontal, 12)
                                .padding(.bottom, 12)
                        }
                        .layoutPriority(1)
                    }
                }
                .background(centerBG)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(1)

                // ===== DIREITA =====
                if isRightSidebarVisible {
                    RightSidebar(
                        onHide: { withAnimation(.easeInOut(duration: 0.25)) { isRightSidebarVisible.toggle() } }
                    )
                    .resizableSidebar(width: $rightSidebarWidth)
                    .background(sidebarBG)
                    .layoutPriority(0.2)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(minWidth: 1060, minHeight: 750) // Minimum size to keep elements readable
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
