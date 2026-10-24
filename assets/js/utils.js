function escapeHtml(value) {
  return String(value ?? "").replace(
    /[&<>"']/g,
    (character) =>
      ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
      })[character],
  );
}

function formatDate(value, includeTime = false) {
  if (!value) return "Não informado";
  const parts = String(value).replace("T", " ").split(" ");
  const [year, month, day] = parts[0].split("-");
  const date = `${day}/${month}/${year}`;
  return includeTime && parts[1] ? `${date} às ${parts[1].slice(0, 5)}` : date;
}

function toast(message) {
  const element = $("#toast");
  element.textContent = message;
  element.hidden = false;
  clearTimeout(toast.timer);
  toast.timer = setTimeout(() => {
    element.hidden = true;
  }, 3500);
}


function statusBadge(status) {
  const label = STATUS_LABELS[status] || status || "Não informado";
  const style = [
    "recebida",
    "acompanhamento",
    "aplicada",
    "concluido",
    "realizada",
    "liberado",
  ].includes(status)
    ? "ok"
    : status === "pendente"
      ? "wa"
      : "";
  return `<span class="bd ${style}">${escapeHtml(label)}</span>`;
}

function documentLink(url, label) {
  if (!url || !/^(https?:\/\/|\/(?!\/)|\.\.?\/)/i.test(url)) return "";
  return `<p><a href="${escapeHtml(url)}" target="_blank" rel="noopener noreferrer">${label}</a></p>`;
}

function recordCard(record, type) {
  const event = EVENT_TYPES[type];
  const facility =
    record.unidade || record.unidade_solicitante || "Unidade não informada";
  const detail =
    record.detalhes ||
    record.instrucoes ||
    record.resultado_resumo ||
    record.orientacoes ||
    record.retorno_recomendado ||
    "Sem detalhes registrados.";
  const origin = record.origem ? ` · origem: ${escapeHtml(record.origem)}` : "";
  const status = record.status ? statusBadge(record.status) : "";

  return `<li style="--c:${event[2]}"><details class="${["alta", "acompanhamento"].includes(type) ? "new" : ""}">
    <summary>
      <span class="dt">${escapeHtml(formatDate(record.ocorrido_em, true))} · ${event[1]}</span>
      <h3>${event[0]} ${escapeHtml(record.titulo)} ${status}</h3>
      <span class="mu">${escapeHtml(facility)}${origin}</span>
    </summary>
    <p>${escapeHtml(detail)}</p>${documentLink(record.documento_url, "Abrir documento")}
  </details></li>`;
}

function timeline() {
  const records = [
    ...(STATE.data.registros || []).map((record) => ({
      ...record,
      timeline_type: record.tipo,
      occurred_at: record.ocorrido_em,
    })),
    ...(STATE.data.altas || []).map((discharge) => ({
      ...discharge,
      titulo: "Alta hospitalar",
      detalhes: discharge.resumo,
      origem: "Alta hospitalar",
      unidade: discharge.hospital,
      ocorrido_em: discharge.alta_em,
      timeline_type: "alta",
    })),
  ]
    .filter(
      (record) =>
        STATE.historyFilter === "todos" ||
        record.timeline_type === STATE.historyFilter ||
        (STATE.historyFilter === "internacao" &&
          ["alta", "acompanhamento"].includes(record.timeline_type)),
    )
    .sort((first, second) =>
      second.occurred_at.localeCompare(first.occurred_at),
    );

  return `<ol class="tl">${records.map((record) => recordCard(record, record.timeline_type)).join("") || '<p class="mu">Nenhum registro encontrado.</p>'}</ol>`;
}

function patientName(patient = STATE.data.paciente) {
  return patient ? escapeHtml(patient.nome) : "";
}

