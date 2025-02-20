import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["firstName", "moveInDate", "firstNameSpans", "moveInDateSpan"]

  connect() {
    this.updateFirstName()
    this.updateMoveInDate()
  }

  updateFirstName() {
    this.firstNameSpansTargets.forEach(span => {
      span.textContent = this.firstNameTarget.value || "<First Name>"
    });
  }

  updateMoveInDate() {
    this.moveInDateSpanTarget.textContent = this.moveInDateTarget.value || "<some date>"
  }
}
