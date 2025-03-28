import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static outlets = ['nested-form', 'tab-error']
  static targets = ['input', 'invalidFeedbackContainer', 'invalidFeedbackTemplate']
  static values = { url: String }

  async lookup (event) {
    event.preventDefault()

    if (this.inputTarget.value === '') return

    this.invalidFeedbackContainerTarget.innerHTML = ''
    const ids = this.inputTarget.value.split(/[,;]? |\n/)
    await Promise.all(ids.map(id => this.lookupId(id)))
      .then((errorIds) => {
        this.inputTarget.value = ''
        if (!errorIds.filter(Boolean).length) {
          this.invalidFeedbackContainerTarget.innerHTML = ''
        } else {
          errorIds.filter(Boolean).map(id => this.addError(id))
          this.inputTarget.value = errorIds.filter(id => id).join('\n')
        }
      })
  }

  async lookupId (id) {
    const sunetid = id.replaceAll('@stanford.edu', '')
    return fetch(`${this.urlValue}?id=${sunetid}`)
      .then(response => {
        if (response.status === 404) return null
        if (!response.ok) throw new Error(response.status)
        return response.json()
      })
      .then(data => {
        if (!data) {
          return id
        }
        this.addParticipant(data)
        return null
      })
      .catch(error => console.dir(error))
  }

  addError (sunetid) {
    this.invalidFeedbackContainerTarget.insertAdjacentHTML(
      'beforeend',
      this.invalidFeedbackTemplateTarget.innerHTML.replace(/ID/, sunetid)
    )
  }

  addParticipant (accountData) {
    const formInstanceEl = this.nestedFormOutlet.add()
    formInstanceEl.querySelector('.participant-label').innerHTML = `${accountData.sunetid}: ${accountData.name}`
    formInstanceEl.querySelector('input[name$="[sunetid]"]').value = accountData.sunetid
    formInstanceEl.querySelector('input[name$="[name]"]').value = accountData.name
    this.tabErrorOutlet.clearInvalidStatus('participants')
  }
}
