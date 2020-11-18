/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ScanditBarcodeCapture

extension DataCaptureContext {
    private static let licenseKey = "Aa8/LCy3M7UTBgMouS+Czv0KrWueI64X51CaTsM3G63bd5oVe3ArG6VFo2yAIwHHtkkqpw0kmMpHW5WB3zcKYRR0+T5zdTSgaz/UfAZW86/FVM9PoUqIMYN0Noi1Sk+/hlZhw4Ew4Pn/cGIzlkfPZhZJQt2DbobKDlkmXJhYi5jBTLL5KSI6Uq9BTX69fJ90EGJnh8dpiOrfQs5160r3by9LQuQKQr6dkUrGcLEi4z6fYOP5fXsJe19gn8HmbpP5wEAOPapK3xl9eOFA7WWvl9RlI+s0KjviC2xkz0xAq4+jTFlDsSzsp2xssrGzUfOHUFiC2pJR4CPwVhzw8HeNUYh07quiYLma6FoAQ5BvN0udbP1On2cxSYl9uKNeW5XVaEXCSuhAtEUpRrSUbE54rYUr0rcBWEi/rVjLppho++wZW+yv1kIc3W9f22v/UjIzjFGa3JB5q/lxGuhAA1o1D+ViCRYaVpdEd2wTcL1iF8hbYIau0UdVgTYSNg27Lp4OdhrmOvsK21YtEJwW2xfraNCmVjHZ+EdvzL9rifsegwirXL8prmNuSnXFap/mZqqjmXrdNyOcRn9lz9F4RfYRDh51lEkdJjQFvQHEYkHb1xtVGwu635cTKdy1EquvInwoB252ClPL64ED575JFGFifnB9enGb9/Y76rMrqZAv7KlF677u/4DYjinQxl2Wp682suWXj2FVser0K0EuJ7IY/05tGQog5spS5gdvswRHQtiFDMCrB0/Hc7BTzj1FMkEUPbh9TuFzSQ5VwuBPrV7BUybNCYEWWCxeXb0k677auGVkWw1DaEO2dJeTrqNrs/wg0hRYYQkl3tVJ1yDdaTS6mnjERDOnBqI6zC3UDnZHx1EYHBBFN+mmXEKz0LBU7HOk2tgUMo4zOCmITH9kOp1XUqgDUKLqsvG/sysad9XuJDBFCmVKe5KWY+skBy5jmLhHXSk5t6kXMW4sN3OX3ssshaW63ZMec8O0ZYSepXUTJCsUVOAHxXkr4DFm2BDQXXIVKKSQP3PMmk1/9jj5ESoeC1Sz04XCRhDo0OQeKdyTyyr27ionMc9rU34ul6zNkDtE7c5hfSU/IG+N5YHtUx2XVoMoLdc07fjTFrVCxT6Rm+0Ji2c60eAS1UuzhqU3kapcSL41vEqubgoCdP0TNulObuU+fUOxvp22wmQnLZ4x9lD3v90jU3qKjfGEqEJdudw="

    // Get a licensed DataCaptureContext.
    static var licensed: DataCaptureContext {
        return DataCaptureContext(licenseKey: licenseKey)
    }
}

class ViewController: UIViewController {

    private var context: DataCaptureContext!
    private var camera: Camera?
    private var barcodeCapture: BarcodeCapture!
    private var captureView: DataCaptureView!
    private var overlay: BarcodeCaptureOverlay!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecognition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Switch camera on to start streaming frames. The camera is started asynchronously and will take some time to
        // completely turn on.
        barcodeCapture.isEnabled = true
        camera?.switch(toDesiredState: .on)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Switch camera off to stop streaming frames. The camera is stopped asynchronously and will take some time to
        // completely turn off. Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode capture as well.
        barcodeCapture.isEnabled = false
        camera?.switch(toDesiredState: .off)
    }

    func setupRecognition() {
        // Create data capture context using your license key.
        context = DataCaptureContext.licensed

        // Use the world-facing (back) camera and set it as the frame source of the context. The camera is off by
        // default and must be turned on to start streaming frames to the data capture context for recognition.
        // See viewWillAppear and viewDidDisappear above.
        camera = Camera.default
        context.setFrameSource(camera, completionHandler: nil)

        // Use the recommended camera settings for the BarcodeCapture mode.
        let recommenededCameraSettings = BarcodeCapture.recommendedCameraSettings
        camera?.apply(recommenededCameraSettings)

        // The barcode capturing process is configured through barcode capture settings  
        // and are then applied to the barcode capture instance that manages barcode recognition.
        let settings = BarcodeCaptureSettings()

        // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
        // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
        // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
        settings.set(symbology: .ean13UPCA, enabled: true)
        settings.set(symbology: .ean8, enabled: true)
        settings.set(symbology: .upce, enabled: true)
        settings.set(symbology: .qr, enabled: true)
        settings.set(symbology: .dataMatrix, enabled: true)
        settings.set(symbology: .code39, enabled: true)
        settings.set(symbology: .code128, enabled: true)
        settings.set(symbology: .interleavedTwoOfFive, enabled: true)

        // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
        // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
        // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
        // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
        // variable-length symbologies.
        let symbologySettings = settings.settings(for: .code39)
        symbologySettings.activeSymbolCounts = Set(7...20) as Set<NSNumber>

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture(context: context, settings: settings)

        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(self)

        // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
        // camera preview. The view must be connected to the data capture context.
        captureView = DataCaptureView(context: context, frame: view.bounds)
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(captureView)

        // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
        // the video preview. This is optional, but recommended for better visual feedback.
        overlay = BarcodeCaptureOverlay(barcodeCapture: barcodeCapture)
        overlay.viewfinder = RectangularViewfinder()
        captureView.addOverlay(overlay)
    }

    private func showResult(_ result: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: result, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion() }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

// MARK: - BarcodeCaptureListener

extension ViewController: BarcodeCaptureListener {

    func barcodeCapture(_ barcodeCapture: BarcodeCapture,
                        didScanIn session: BarcodeCaptureSession,
                        frameData: FrameData) {
        guard let barcode = session.newlyRecognizedBarcodes.first else {
            return
        }

        // Stop recognizing barcodes for as long as we are displaying the result. There won't be any new results until
        // the capture mode is enabled again. Note that disabling the capture mode does not stop the camera, the camera
        // continues to stream frames until it is turned off.
        barcodeCapture.isEnabled = false

        // If you are not disabling barcode capture here and want to continue scanning, consider setting the
        // codeDuplicateFilter when creating the barcode capture settings to around 500 or even -1 if you do not want
        // codes to be scanned more than once.

        // Get the human readable name of the symbology and assemble the result to be shown.
        let symbology = SymbologyDescription(symbology: barcode.symbology).readableName

        var result = "Scanned: "
        if let data = barcode.data {
            result += "\(data) "
        }
        result += "(\(symbology))"

        showResult(result) { [weak self] in
            // Enable recognizing barcodes when the result is not shown anymore.
            self?.barcodeCapture.isEnabled = true
        }
    }

}
