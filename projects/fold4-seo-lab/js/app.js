const button = document.querySelector("#testButton");
const result = document.querySelector("#result");

button.addEventListener("click", () => {
  const now = new Date().toLocaleTimeString("id-ID");

  result.textContent = `JavaScript aktif. Pemeriksaan lokal: ${now}`;
});
