//
//  BarcodeScannerView.swift
//  AdaptFitness
//
//  Created by AI Assistant on 10/16/25.
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
        setupCaptureSession()
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
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.scanningFailed(error: "Camera not available")
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.scanningFailed(error: "Camera access denied")
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            delegate?.scanningFailed(error: "Failed to add camera input")
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
        } else {
            delegate?.scanningFailed(error: "Failed to add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let preview = previewLayer {
            view.layer.addSublayer(preview)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
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

