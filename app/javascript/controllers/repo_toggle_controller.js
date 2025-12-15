import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="repo-toggle"
export default class extends Controller {
  static values = {
    repoName: String,
    repoId: String,
    githubRepoId: String,
    collectionDruid: String,
    linkUrl: String,
    unlinkUrl: String
  }

  processing = false

  async toggle(event) {
    if (this.processing) return
    this.processing = true

    const checkbox = event.target
    const isChecked = checkbox.checked
    checkbox.disabled = true

    try {
      if (isChecked) {
        // Link the repository
        await this.linkRepository()
        // After successful link, reload to get the work/DOI info
        window.location.reload()
      } else {
        // Unlink the repository
        const confirmed = confirm('Are you sure? This will stop automatic deposits from this repository.')
        if (confirmed) {
          await this.unlinkRepository()
          // Mark as unlinked in UI without reload
          checkbox.checked = false
          // Prevent accidental re-delete on any subsequent changes
          this.unlinkUrlValue = ''
          // Clear the work/DOI cell
          const row = checkbox.closest('tr')
          const workCell = row?.querySelector('td:nth-child(3)')
          if (workCell) workCell.textContent = ''
        } else {
          checkbox.checked = true
        }
      }
    } catch (error) {
      console.error('Error toggling repository:', error)
      alert('An error occurred. Please try again.')
    } finally {
      checkbox.disabled = false
      this.processing = false
    }
  }

  async linkRepository() {
    const formData = new FormData()
    formData.append('repo_name', this.repoNameValue)
    formData.append('repo_id', this.repoIdValue)

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    const response = await fetch(this.linkUrlValue, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken
      },
      body: formData
    })

    if (!response.ok) {
      throw new Error('Failed to link repository')
    }
  }

  async unlinkRepository() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    const response = await fetch(this.unlinkUrlValue, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': csrfToken
      }
    })
  }
}
