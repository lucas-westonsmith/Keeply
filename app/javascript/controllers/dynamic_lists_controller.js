import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  updateLists(event) {
    const superListId = event.target.value;
    const url = `/items/update_lists?super_list_id=${superListId}`;
    fetch(url, {
      headers: { "X-Requested-With": "XMLHttpRequest" },
    })
      .then((response) => response.text())
      .then((html) => {
        document.getElementById("lists-container").innerHTML = html;
      })
      .catch((error) => console.error("Error updating lists:", error));
  }
}
