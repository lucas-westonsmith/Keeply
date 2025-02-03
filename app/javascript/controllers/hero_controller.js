import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";

export default class extends Controller {
  connect() {
    console.log("🚀 Hero animations initialized!");

    gsap.to(".animate-text", {
      opacity: 1,
      y: 0,
      duration: 1.2,
      stagger: 0.4,
      ease: "power2.out",
    });

    gsap.fromTo(
      ".animate-button",
      { opacity: 0, y: 40, scale: 0.9 },
      {
        opacity: 1,
        y: 0,
        scale: 1,
        duration: 1.5,
        delay: 1.5,
        ease: "elastic.out(1, 0.5)",
      }
    );

    gsap.from(".check-item", {
      opacity: 0,
      x: -20,
      duration: 1,
      stagger: 0.3,
      ease: "power2.out",
    });
  }
}
