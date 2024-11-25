import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone";

export default class extends Controller {
    static targets = ["progress"]

    connect() {
        console.log("Dropzone connected", this.element.id);
        this.dropzone = new Dropzone(this.element, {
            paramName: "content[files]",
            uploadMultiple: true,
            createImageThumbnails: false,
            addRemoveLinks: false,
            disablePreviews: true,
        });
        this.dropzone.on("addedfiles", () => {
            console.log('addedfiles');
            this.progressTarget.classList.remove("d-none");
        });
        this.dropzone.on("totaluploadprogress", (totalUploadProgress) => {
            const uploadProgress = Math.trunc(totalUploadProgress);
            this.updateProgress(uploadProgress);
        });
        this.dropzone.on("queuecomplete", async () => {
            console.log('queuecomplete');
            // Give the user a second to process the 100% progress
            await new Promise(r => setTimeout(r, 1000));
            this.dropzone.element.classList.remove("dz-started");
            this.progressTarget.classList.add("d-none");
            this.updateProgress(0);
          });
    }

    updateProgress(progress) {
        this.progressTarget.setAttribute("aria-valuenow", progress);
        const barElement = this.progressTarget.querySelector(".progress-bar");
        barElement.style.width = `${progress}%`;
    }
}