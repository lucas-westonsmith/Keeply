import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "fileInput",
    "fileName",
    "photoInput",
    "photoFileName",
    "loading",
    "message",
    "title",
    "price",
    "issuer",
    "purchaseDate",
    "warrantyExpiryDate"
  ];

  connect() {
    if (this.hasConnected) {
      console.warn("⚠️ OCR Controller already connected, aborting!");
      return;
    }
    this.hasConnected = true;
    console.log("✅ OCR Stimulus Controller connected 🚀");

    setTimeout(() => {
      this.debugCheckTargets();
    }, 500);

    document.addEventListener("turbo:load", () => {
      console.log("🔥 Turbo:load detected, rechecking...");
      setTimeout(() => this.debugCheckTargets(), 500);
    });

    document.addEventListener("turbo:frame-load", () => {
      console.log("🔄 Turbo Frame Loaded! Forced rechecking.");
      setTimeout(() => this.debugCheckTargets(), 500);
    });

    if (this.hasFileInputTarget) {
      this.fileInputTarget.addEventListener("change", this.updateFileName.bind(this));
      this.fileInputTarget.addEventListener("change", this.processInvoice.bind(this));
    }

    if (this.hasPhotoInputTarget) {
      this.photoInputTarget.addEventListener("change", this.updatePhotoFileName.bind(this));
    }
  }

  debugCheckTargets() {
    console.log("📌 Advanced target verification...");

    this.checkTarget("fileInput");
    this.checkTarget("fileName");
    this.checkTarget("photoInput");
    this.checkTarget("photoFileName");
    this.checkTarget("title");
    this.checkTarget("price");
    this.checkTarget("issuer");
    this.checkTarget("purchaseDate");
    this.checkTarget("warrantyExpiryDate");

    console.log("🔍 OCR Elements Summary:", {
      fileInput: this.hasFileInputTarget,
      fileName: this.hasFileNameTarget,
      photoInput: this.hasPhotoInputTarget,
      photoFileName: this.hasPhotoFileNameTarget,
      title: this.hasTitleTarget,
      price: this.hasPriceTarget,
      issuer: this.hasIssuerTarget,
      purchaseDate: this.hasPurchaseDateTarget,
      warrantyExpiryDate: this.hasWarrantyExpiryDateTarget
    });
  }

  updateFileName(event) {
    const file = event.target.files[0];
    this.fileNameTarget.textContent = file ? file.name : "No file chosen";
  }

  updatePhotoFileName(event) {
    const file = event.target.files[0];
    this.photoFileNameTarget.textContent = file ? file.name : "No file chosen";
  }

  processInvoice(event) {
    console.log("📸 processInvoice() called!", event.target.files);

    if (!this.hasFileInputTarget) {
      console.error("🚨 ERROR: fileInputTarget not found!");
      return;
    }

    const file = event.target.files[0];
    if (!file) {
      console.warn("⚠️ No file detected!");
      return;
    }

    // ✅ Show only the loading message, without modifying `messageTarget`
    this.loadingTarget.classList.remove("hidden");
    this.messageTarget.textContent = "";

    const formData = new FormData();
    formData.append("invoice", file);

    fetch("/items/extract_invoice_data", {
      method: "POST",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      }
    })
      .then(response => response.json())
      .then(data => {
        this.loadingTarget.classList.add("hidden");

        if (data.error) {
          console.error("❌ OCR Error:", data.error);
          this.messageTarget.textContent = "❌ OCR Error.";
          return;
        }

        console.log("✅ OCR Extraction Successful:", data);

        // 🔥 Correction du prix pour s'assurer qu'il est bien au format float et sans erreurs de parsing
        let formattedPrice = data.price;
        if (formattedPrice) {
          formattedPrice = formattedPrice
            .replace(",", ".") // Remplace la virgule par un point pour éviter les erreurs
            .replace(/[^0-9.]/g, ""); // Supprime tout sauf les chiffres et le point
        }

        this.updateField("title", data.title);
        this.updateField("price", formattedPrice);
        this.updateField("issuer", data.issuer);
        this.updateField("purchaseDate", data.purchase_date);
        this.updateField("warrantyExpiryDate", data.warranty_expiry_date);

        this.messageTarget.textContent = "✅ Data successfully extracted!";
      })
      .catch(error => {
        console.error("🚨 OCR Error:", error);
        this.loadingTarget.classList.add("hidden");
        this.messageTarget.textContent = "❌ OCR Processing Failed.";
      });
  }

  updateField(targetName, value) {
    if (this[`has${this.capitalize(targetName)}Target`]) {
      this[`${targetName}Target`].value = value || "";
      console.log(`✅ ${targetName} updated with:`, value);
    } else {
      console.warn(`⚠️ Unable to update ${targetName}, target not found.`);
    }
  }

  checkTarget(targetName) {
    if (!this[`has${this.capitalize(targetName)}Target`]) {
      console.warn(`⚠️ ${targetName} Target not detected! Manual verification...`);
      const element = this.element.querySelector(`[data-ocr-target='${targetName}']`);
      if (element) {
        console.log(`✅ ${targetName} detected via querySelector.`);
        this[`${targetName}Target`] = element;
      } else {
        console.error(`🚨 ${targetName} still not found.`);
      }
    }
  }

  capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  }
}
