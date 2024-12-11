import { Application } from '@hotwired/stimulus'
import { Autocomplete } from 'stimulus-autocomplete'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
application.register('autocomplete', Autocomplete)

window.Stimulus = application

export { application }
