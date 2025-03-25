import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this.href = window.location.href
    this.checkWait()
  }

  checkWait () {
    setTimeout(() => {
      fetch(this.href, { redirect: 'manual' })
        .then(response => {
        // Make sure the user hasn't navigated away from the page
          if (this.href !== window.location.href) return
          if (response.type === 'opaqueredirect') {
            window.location.reload()
          } else {
            this.checkWait()
          }
        })
    }, 1500)
  }
}
