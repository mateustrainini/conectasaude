function render() {
  const app = $("#app");
  if (!STATE.data) {
    app.innerHTML =
      '<div class="card" role="status">Carregando dados do banco…</div>';
    return;
  }

  const patients = STATE.data.pacientes;
  const selector = $("#patientSelector");
  selector.innerHTML = patients
    .map(
      (patient) =>
        `<option value="${Number(patient.id)}" ${Number(patient.id) === STATE.patientId ? "selected" : ""}>${escapeHtml(patient.nome)}</option>`,
    )
    .join("");
  selector.hidden = patients.length < 2;

  if (!STATE.data.paciente) {
    app.innerHTML =
      '<div class="card" role="status">Nenhum paciente de demonstração foi encontrado. Execute config/schema.sql e tente novamente.</div>';
    return;
  }

  app.innerHTML = patientPage();
  const messages = $(".cm");
  if (messages) messages.scrollTop = messages.scrollHeight;
}

function showError(error) {
  console.error(error);
  $("#app").innerHTML =
    `<div class="card" role="alert">${escapeHtml(error.message || "Erro ao carregar dados.")}</div>`;
}

function go(page) {
  STATE.page = page;
  STATE.chatOpen = false;
  render();
  scrollTo(0, 0);
}

function setHistoryFilter(filter) {
  STATE.historyFilter = filter;
  render();
}

function setUnitFilter(filter) {
  STATE.unitFilter = filter;
  render();
}

async function selectPatient(patientId) {
  STATE.chatOpen = false;
  try {
    await loadData(patientId);
  } catch (error) {
    showError(error);
    toast(error.message);
  }
}


$("#patientSelector").addEventListener("change", (event) => {
  selectPatient(Number(event.target.value));
});

loadData().catch(showError);
