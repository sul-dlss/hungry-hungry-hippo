// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from 'controllers/application'
import { eagerLoadControllersFrom } from '@hotwired/stimulus-loading'
import TabErrorController from 'sdr_view_components/tab_error_controller'
import TabLinkController from 'sdr_view_components/tab_link_controller'
import TabNavController from 'sdr_view_components/tab_nav_controller'
eagerLoadControllersFrom('controllers', application)

application.register('sdr-tab-error', TabErrorController)
application.register('sdr-tab-link', TabLinkController)
application.register('sdr-tab-nav', TabNavController)
