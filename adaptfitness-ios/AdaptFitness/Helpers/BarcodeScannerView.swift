//
//  BarcodeScannerView.swift
//  AdaptFitness
//
//  Created by OzzieC8 on 10/16/25.
//
//  Native iOS barcode scanner using AVFoundation
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var scannedCode: String?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Camera preview
                BarcodeScannerRepresentable(
                    scannedCode: $scannedCode,
                    showError: $showingError,
                    errorMessage: $errorMessage
                )
                .edgesIgnoringSafeArea(.all)
                
                // Overlay with scanning frame
                VStack {
                    Spacer()
                    
                    // Scanning frame
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 300, height: 300)
                    
                    Text("Position barcode within frame")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Scanner Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: scannedCode) {
                if scannedCode != nil {
                    // Dismiss automatically when a code is scanned
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Barcode Scanner Representable

struct BarcodeScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let controller = BarcodeScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            scannedCode: $scannedCode,
            showError: $showError,
            errorMessage: $errorMessage
        )
    }
    
    class Coordinator: NSObject, BarcodeScannerDelegate {
        @Binding var scannedCode: String?
        @Binding var showError: Bool
        @Binding var errorMessage: String
        
        init(scannedCode: Binding<String?>, showError: Binding<Bool>, errorMessage: Binding<String>) {
            self._scannedCode = scannedCode
            self._showError = showError
            self._errorMessage = errorMessage
        }
        
        func barcodeScanned(code: String) {
            scannedCode = code
        }
        
        func scanningFailed(error: String) {
            errorMessage = error
            showError = true
        }
    }
}

// MARK: - Barcode Scanner Delegate

protocol BarcodeScannerDelegate: AnyObject {
    func barcodeScanned(code: String)
    func scanningFailed(error: String)
}

// MARK: - Barcode Scanner View Controller

class BarcodeScannerViewController: UIViewController {
    weak var delegate: BarcodeScannerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraPermission()
    }
    
    private func requestCameraPermission() {
        // Force permission request by checking status first
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("Camera permission status: \(status.rawValue)")
        
        switch status {
        case .authorized:
            print("Camera already authorized")
            setupCaptureSession()
        case .notDetermined:
            print("Requesting camera permission...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                print("Camera permission granted: \(granted)")
                DispatchQueue.main.async {
                    if granted {
                        self.setupCaptureSession()
                    } else {
                        self.delegate?.scanningFailed(error: "Camera access denied. Please enable camera permissions in Settings.")
                    }
                }
            }
        case .denied:
            print("Camera permission denied")
            delegate?.scanningFailed(error: "Camera access denied. Please enable camera permissions in System Preferences > Security & Privacy > Camera.")
        case .restricted:
            print("Camera permission restricted")
            delegate?.scanningFailed(error: "Camera access restricted. Please check parental controls or system restrictions.")
        @unknown default:
            print("Camera permission unknown status")
            delegate?.scanningFailed(error: "Camera access error.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let session = captureSession, !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        
        guard let session = captureSession else { return }
        
        // Real camera setup for all devices (including macOS)
        setupRealCamera(session: session)
    }
    
    private func setupRealCamera(session: AVCaptureSession) {
        // Find and use the real camera
        var cameraDevice: AVCaptureDevice?
        
        // Try different camera detection methods
        if let defaultDevice = AVCaptureDevice.default(for: .video) {
            cameraDevice = defaultDevice
            print("Found default camera: \(defaultDevice.localizedName)")
        }
        
        // If no default camera, try discovery session
        if cameraDevice == nil {
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera],
                mediaType: .video,
                position: .unspecified
            )
            
            for device in discoverySession.devices {
                print("Found camera: \(device.localizedName)")
            }
            
            cameraDevice = discoverySession.devices.first
        }
        
        // Try specific positions
        if cameraDevice == nil {
            cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        
        if cameraDevice == nil {
            cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }
        
        guard let device = cameraDevice else {
            delegate?.scanningFailed(error: "No camera found. Please check camera permissions in System Preferences > Security & Privacy > Camera.")
            return
        }
        
        print("Using camera: \(device.localizedName)")
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                print("Successfully added camera input")
            } else {
                delegate?.scanningFailed(error: "Cannot add camera input to capture session")
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [
                    .ean8,
                    .ean13,
                    .pdf417,
                    .qr,
                    .code128,
                    .code39,
                    .code93,
                    .upce,
                    .aztec,
                    .interleaved2of5,
                    .itf14,
                    .dataMatrix
                ]
                print("Successfully added metadata output")
            } else {
                delegate?.scanningFailed(error: "Failed to add metadata output")
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.frame = view.layer.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            
            if let preview = previewLayer {
                view.layer.addSublayer(preview)
                print("Successfully added preview layer")
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
                print("Camera session started")
            }
            
        } catch {
            delegate?.scanningFailed(error: "Failed to access camera: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

// MARK: - Metadata Output Delegate

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        // Stop scanning after first successful scan
        captureSession?.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            // Haptic feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            delegate?.barcodeScanned(code: stringValue)
        }
    }
}

// MARK: - Preview

struct BarcodeScannerView_Previews: PreviewProvider {
    @State static var scannedCode: String? = nil
    
    static var previews: some View {
        BarcodeScannerView(scannedCode: $scannedCode)
    }
}

