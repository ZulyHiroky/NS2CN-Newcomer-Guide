const buger = document.querySelector(".burger");
const navMenu = document.querySelector(".nav-menu");

const navMenuItems = document.querySelectorAll(".nav-menu li");

buger.addEventListener("click", () => {
  buger.classList.toggle("active");
  navMenu.classList.toggle("open");


  });


