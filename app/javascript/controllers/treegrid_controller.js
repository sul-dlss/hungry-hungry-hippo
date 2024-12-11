import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['table']

  get visibleRows () {
    return this.tableTarget.querySelectorAll('tbody > tr:not([hidden])')
  }

  toggle (event) {
    const dirTrElement = event.target.closest('tr')
    if (dirTrElement.getAttribute('aria-expanded') === 'true') {
      // Contract
      dirTrElement.setAttribute('aria-expanded', 'false')
      this.childTrElements(dirTrElement).forEach((childTrElement) => {
        childTrElement.dataset.expandHidden = true
        this.toggleHide(childTrElement)
      })
    } else {
      // Expand
      dirTrElement.setAttribute('aria-expanded', 'true')
      let closedBranchLevel = null
      this.childTrElements(dirTrElement).forEach((childTrElement) => {
        // Keeps nested closed branches closed and children hidden.
        if (closedBranchLevel && childTrElement.getAttribute('aria-level') > closedBranchLevel) return

        delete childTrElement.dataset.expandHidden
        this.toggleHide(childTrElement)

        if (this.isClosedBranch(childTrElement)) {
          closedBranchLevel = childTrElement.getAttribute('aria-level')
        } else {
          closedBranchLevel = null
        }
      })
    }
  }

  childTrElements (trElement) {
    const childTrElements = []
    let nextTrElement = trElement.nextElementSibling
    while (nextTrElement) {
      childTrElements.push(nextTrElement)
      nextTrElement = nextTrElement.nextElementSibling
      if (nextTrElement && nextTrElement.getAttribute('aria-level') <= trElement.getAttribute('aria-level')) {
        nextTrElement = null
      }
    }
    return childTrElements
  }

  navigate (event) {
    switch (true) {
      case event.key === 'Enter' && this.isBranch(event.target):
        event.preventDefault()
        this.toggle(event)
        break
      case event.key === 'Enter' && this.isLeaf(event.target):
        // Perform the default action (remove the file)
        const removeElement = this.removeElement(event.target) // eslint-disable-line no-case-declarations
        if (!removeElement) break

        event.preventDefault()
        removeElement.click()
        break
      case event.key === 'ArrowRight' && this.isClosedBranch(event.target):
        // When a closed node, opens the node
        event.preventDefault()
        this.toggle(event)
        break
      case event.key === 'ArrowRight' && this.isOpenBranch(event.target):
        // When an open node, moves focus to the first child node
        event.preventDefault()
        event.target.nextElementSibling.focus()
        break
      case event.key === 'ArrowLeft' && this.isOpenBranch(event.target):
        // When an open node, closes the node
        event.preventDefault()
        this.toggle(event)
        break
      case event.key === 'ArrowLeft' && event.target.getAttribute('aria-level') > 1:
        // When a closed node, moves focus to the node's parent node
        const parentBranchRowElement = this.parentBranchRowElement(event.target) // eslint-disable-line no-case-declarations
        if (!parentBranchRowElement) break

        event.preventDefault()
        parentBranchRowElement.focus()
        break
      case event.key === 'ArrowUp':
        // Move to the previous node without opening or closing
        const previousRowElement = this.previousBranchRowElement(event.target) // eslint-disable-line no-case-declarations
        if (!previousRowElement) break

        event.preventDefault()
        previousRowElement.focus()
        break
      case event.key === 'ArrowDown':
        // Move to the next node without opening or closing
        const nextRowElement = this.nextBranchRowElement(event.target) // eslint-disable-line no-case-declarations
        if (!nextRowElement) break

        event.preventDefault()
        nextRowElement.focus()
        break
      case event.key === 'Home':
        // Move to the first node without opening or closing
        event.preventDefault()
        this.visibleRows[0].focus()
        break
      case event.key === 'End':
        // Move to the last node without opening or closing
        event.preventDefault()
        const rowElements = this.visibleRows // eslint-disable-line no-case-declarations
        rowElements[rowElements.length - 1].focus()
        break
    }
  }

  isBranch (element) {
    return element.dataset.treeRole === 'branch'
  }

  isClosedBranch (element) {
    return this.isBranch(element) && element.getAttribute('aria-expanded') !== 'true'
  }

  isOpenBranch (element) {
    return this.isBranch(element) && element.getAttribute('aria-expanded') === 'true'
  }

  isLeaf (element) {
    return element.dataset.treeRole === 'leaf'
  }

  parentBranchRowElement (rowElement) {
    let previousElementSibling = rowElement.previousElementSibling
    while (previousElementSibling) {
      if (previousElementSibling.getAttribute('aria-level') === rowElement.getAttribute('aria-level') - 1) {
        return previousElementSibling
      }
      previousElementSibling = previousElementSibling.previousElementSibling
    }
    return null
  }

  nextBranchRowElement (rowElement) {
    let siblingElement = rowElement.nextElementSibling
    while (siblingElement) {
      if (!siblingElement.hidden) {
        return siblingElement
      }
      siblingElement = siblingElement.nextElementSibling
    }
    return null
  }

  previousBranchRowElement (rowElement) {
    let siblingElement = rowElement.previousElementSibling
    while (siblingElement) {
      if (!siblingElement.hidden) {
        return siblingElement
      }
      siblingElement = siblingElement.previousElementSibling
    }
    return null
  }

  toggleHide (trElement) {
    if (trElement.dataset.searchHidden === 'true' || trElement.dataset.expandHidden === 'true') {
      trElement.hidden = true
    } else {
      trElement.hidden = false
    }
  }

  removeElement (element) {
    return element.querySelector('a')
  }
}
