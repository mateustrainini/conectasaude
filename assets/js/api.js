async function loadData(patientId = STATE.patientId) {
  const requestId = ++STATE.requestId;
  const url = new URL(API_URL, window.location.href);
  if (patientId) url.searchParams.set("paciente_id", patientId);

  const response = await fetch(url, {
    headers: { Accept: "application/json" },
  });
  const result = await response.json();
  if (!response.ok || !result.success) {
    throw new Error(result.message || "Não foi possível carregar os dados.");
  }
  if (requestId !== STATE.requestId) return;

  STATE.data = result;
  STATE.patientId = result.paciente ? Number(result.paciente.id) : null;
  render();
}

