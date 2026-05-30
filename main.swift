import SwiftUI
import CoreImage
import UniformTypeIdentifiers
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

extension NSImage {
    func pngData() -> Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    
    func jpegData() -> Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .jpeg, properties: [:])
    }
}

struct DropZoneView: View {
    let isTargeted: Bool
    let pulseBorder: Bool
    let statusMessage: String
    let errorMessage: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isTargeted ? "arrow.down.doc.fill" : "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: isTargeted ? [Color.purple, Color.blue] : [Color.gray, Color.gray.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isTargeted ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTargeted)
            
            VStack(spacing: 6) {
                Text(isTargeted ? "Drop it here!" : statusMessage)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(isTargeted ? .primary : .secondary)
                
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                } else {
                    Text("PNG, JPG, WEBP formats")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isTargeted ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: isTargeted 
                            ? [Color.purple, Color.blue] 
                            : [Color.white.opacity(pulseBorder ? 0.3 : 0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: isTargeted ? 3 : 2,
                        dash: isTargeted ? [] : [8, 6]
                    )
                )
        )
    }
}

struct ContentView: View {
    @State private var originalImage: NSImage? = nil
    @State private var invertedImage: NSImage? = nil
    @State private var invertedImageURL: URL? = nil
    @State private var isTargeted = false
    @State private var isProcessing = false
    @State private var statusMessage = "Drag & Drop Image Here"
    @State private var errorMessage: String? = nil
    
    // Animation states
    @State private var pulseBorder = false
    @State private var animateBadge = false
    
    var body: some View {
        ZStack {
            // Visual Effect Background (Glassmorphism)
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("INVERTIFY")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .tracking(3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(nsColor: .systemPurple), Color(nsColor: .systemCyan)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Minimalist Color Inverter")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                
                // Main Content Zone
                ZStack {
                    if isProcessing {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Inverting colors...")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(16)
                    } else if let inverted = invertedImage {
                        // Success State
                        VStack(spacing: 16) {
                            ZStack(alignment: .topTrailing) {
                                Image(nsImage: inverted)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 260, maxHeight: 260)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                                    .onDrag {
                                        if let url = self.invertedImageURL {
                                            return NSItemProvider(contentsOf: url) ?? NSItemProvider()
                                        }
                                        return NSItemProvider()
                                    }
                                
                                // Drag indicator badge
                                Text("DRAG ME OUT")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(LinearGradient(
                                                colors: [Color.purple, Color.blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ))
                                    )
                                    .offset(x: 10, y: -10)
                                    .shadow(radius: 4)
                                    .scaleEffect(animateBadge ? 1.06 : 0.96)
                                    .onAppear {
                                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                            animateBadge = true
                                        }
                                    }
                            }
                            
                            Text("Drag the image back out to use it!")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Button(action: reset) {
                                Text("Reset")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(Color.white.opacity(0.15)))
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        // Empty / Drop Zone
                        DropZoneView(isTargeted: isTargeted, pulseBorder: pulseBorder, statusMessage: statusMessage, errorMessage: errorMessage)
                            .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
                                handleDrop(providers: providers)
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseBorder = true
            }
        }
    }
    
    private func reset() {
        originalImage = nil
        invertedImage = nil
        invertedImageURL = nil
        statusMessage = "Drag & Drop Image Here"
        errorMessage = nil
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        isProcessing = true
        errorMessage = nil
        
        _ = provider.loadObject(ofClass: URL.self) { url, error in
            if let url = url {
                let pathExtension = url.pathExtension.lowercased()
                let validExtensions = ["png", "jpg", "jpeg", "webp", "tiff", "bmp", "gif", "heic"]
                if validExtensions.contains(pathExtension) {
                    DispatchQueue.main.async {
                        self.processImage(at: url)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        self.errorMessage = "Unsupported file format"
                        self.statusMessage = "Drag & Drop Image Here"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Failed to load dropped file"
                    self.statusMessage = "Drag & Drop Image Here"
                }
            }
        }
        return true
    }
    
    private func processImage(at url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? Data(contentsOf: url),
                  let nsImage = NSImage(data: data) else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Could not load image file"
                }
                return
            }
            
            guard let tiffData = nsImage.tiffRepresentation,
                  let ciImage = CIImage(data: tiffData) else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Could not read image pixels"
                }
                return
            }
            
            let filter = CIFilter(name: "CIColorInvert")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            
            guard let outputImage = filter?.outputImage else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Color inversion failed"
                }
                return
            }
            
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Image rendering failed"
                }
                return
            }
            
            let size = NSSize(width: cgImage.width, height: cgImage.height)
            let invertedNSImage = NSImage(cgImage: cgImage, size: size)
            
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory
            
            let originalName = url.deletingPathExtension().lastPathComponent
            let ext = url.pathExtension.lowercased()
            let outputExt = ext.isEmpty ? "png" : ext
            
            let tempFileName = "\(originalName)_inverted.\(outputExt)"
            let tempFileURL = tempDir.appendingPathComponent(tempFileName)
            
            if fileManager.fileExists(atPath: tempFileURL.path) {
                try? fileManager.removeItem(at: tempFileURL)
            }
            
            let success: Bool
            if outputExt == "jpg" || outputExt == "jpeg" {
                if let jpegData = invertedNSImage.jpegData() {
                    do {
                        try jpegData.write(to: tempFileURL)
                        success = true
                    } catch {
                        success = false
                    }
                } else {
                    success = false
                }
            } else {
                if let pngData = invertedNSImage.pngData() {
                    do {
                        try pngData.write(to: tempFileURL)
                        success = true
                    } catch {
                        success = false
                    }
                } else {
                    success = false
                }
            }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                if success {
                    self.originalImage = nsImage
                    self.invertedImage = invertedNSImage
                    self.invertedImageURL = tempFileURL
                    self.statusMessage = "Inverted successfully!"
                } else {
                    self.errorMessage = "Failed to write output image"
                }
            }
        }
    }
}

@main
struct InvertApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 400, height: 450)
                .background(Color.clear)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
