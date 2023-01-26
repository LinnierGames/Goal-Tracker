//
//  ShareViewController.swift
//  TrackerImportShareExtension
//
//  Created by Erick Sanchez on 3/20/22.
//

import UIKit

extension NSItemProvider {
  func loadData(forTypeIdentifier typeIdentifer: String) async throws -> Data? {
    try await withCheckedThrowingContinuation { continuation in
      loadDataRepresentation(forTypeIdentifier: typeIdentifer) { data, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        continuation.resume(returning: data)
      }
    }
  }

  func loadFile(forTypeIdentifier typeIdentifer: String) async throws -> URL? {
    try await withCheckedThrowingContinuation { continuation in
      loadFileRepresentation(forTypeIdentifier: typeIdentifer) { url, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        continuation.resume(returning: url)
      }
    }
  }
}

class ShareViewController: UIViewController {
  @IBOutlet weak var statusLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
      return
    }

    guard let attachments = item.attachments else {
      return
    }

    Task {
      let fileManager = FileManager.default
      let ud = UserDefaults(suiteName: "group.com.linniergames.Tracker-Tracker")!
      
      for attachment in attachments {
        guard let fileData = try? await attachment.loadData(forTypeIdentifier: "public.comma-separated-values-text") else {
          continue
        }

        guard let file = try? await attachment.loadFile(forTypeIdentifier: "public.comma-separated-values-text") else {
          continue
        }

        let downloadsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let pdfFilename = file.lastPathComponent

        let destinationURL = downloadsURL.appendingPathComponent(pdfFilename)

        do {
          print(fileData, destinationURL, destinationURL.absoluteString)
//          let result = fileManager.createFile(atPath: destinationURL.absoluteString, contents: fileData)
//          assert(result)
          try fileData.write(to: destinationURL)

          var stagedFiles = (ud.array(forKey: "STAGED_FILES") as! [String]?) ?? []
          stagedFiles.append(destinationURL.absoluteString)
          print(stagedFiles.count)
          ud.set(stagedFiles, forKey: "STAGED_FILES")
        } catch {
          assertionFailure(error.localizedDescription)
          continue
        }
      }

      DispatchQueue.main.async {
        self.statusLabel.text = "Done"
      }
    }
  }
}

//import Social
//
//class ShareViewController: SLComposeServiceViewController {
//
//  override func isContentValid() -> Bool {
//    // Do validation of contentText and/or NSExtensionContext attachments here
//    return true
//  }
//
//  override func didSelectPost() {
//    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//
//    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//  }
//
//  override func configurationItems() -> [Any]! {
//    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//    return []
//  }
//
//}
