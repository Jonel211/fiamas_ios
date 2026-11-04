import SwiftUI
import AVFoundation
import UIKit

/// Vista representable de UIKit que encapsula AVCaptureSession para escanear códigos QR y barras.
struct QRScannerView: UIViewControllerRepresentable {
    var torchIsOn: Bool
    var onCodeScanned: (String) -> Void
    var onError: ((String) -> Void)?

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        context.coordinator.parent = self
        uiViewController.setTorch(on: torchIsOn)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, QRScannerViewControllerDelegate {
        var parent: QRScannerView

        init(_ parent: QRScannerView) {
            self.parent = parent
        }

        func didFind(code: String) {
            parent.onCodeScanned(code)
        }

        func didFail(with error: String) {
            parent.onError?(error)
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func didFind(code: String)
    func didFail(with error: String)
}

final class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isSessionRunning = false
    private var hasFoundCode = false
    private let simulatorCodeField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hasFoundCode = false
        startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }

    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Error al cambiar linterna: \(error.localizedDescription)")
        }
    }

    private func setupCamera() {
        #if targetEnvironment(simulator)
        setupSimulatorFallback()
        #else
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            setupSimulatorFallback()
            return
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFail(with: "No se pudo acceder a la cámara: \(error.localizedDescription)")
            setupSimulatorFallback()
            return
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        } else {
            delegate?.didFail(with: "No se pudo añadir la entrada de video.")
            setupSimulatorFallback()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13, .code128, .code39]
        } else {
            delegate?.didFail(with: "No se pudo configurar la salida de metadatos.")
            setupSimulatorFallback()
            return
        }

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.layer.bounds
        view.layer.addSublayer(layer)

        self.captureSession = session
        self.previewLayer = layer
        #endif
    }

    private func startSession() {
        guard let session = captureSession, !isSessionRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }

    private func stopSession() {
        guard let session = captureSession, isSessionRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasFoundCode else { return }

        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            hasFoundCode = true
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didFind(code: stringValue)
        }
    }

    private func setupSimulatorFallback() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Cámara no disponible en este dispositivo/simulador."
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)

        let testButton = UIButton(type: .system)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.setTitle("Usar código de tienda", for: .normal)
        testButton.backgroundColor = UIColor(red: 0.09, green: 0.58, blue: 0.55, alpha: 1.0)
        testButton.setTitleColor(.white, for: .normal)
        testButton.layer.cornerRadius = 10
        testButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        var buttonConfiguration = UIButton.Configuration.plain()
        buttonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        testButton.configuration = buttonConfiguration
        testButton.addTarget(self, action: #selector(didTapSimulateButton), for: .touchUpInside)

        view.addSubview(label)
        simulatorCodeField.translatesAutoresizingMaskIntoConstraints = false
        simulatorCodeField.placeholder = "Pega el enlace QR o token de la tienda"
        simulatorCodeField.textColor = .black
        simulatorCodeField.backgroundColor = .white
        simulatorCodeField.borderStyle = .roundedRect
        simulatorCodeField.autocapitalizationType = .none
        simulatorCodeField.autocorrectionType = .no
        view.addSubview(simulatorCodeField)
        view.addSubview(testButton)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            simulatorCodeField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            simulatorCodeField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            simulatorCodeField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            testButton.topAnchor.constraint(equalTo: simulatorCodeField.bottomAnchor, constant: 12),
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func didTapSimulateButton() {
        guard !hasFoundCode, let code = simulatorCodeField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !code.isEmpty else { return }
        hasFoundCode = true
        delegate?.didFind(code: code)
    }
}
