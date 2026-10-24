function patientHome() {
  const patient = STATE.data.paciente;
  const vaccines = STATE.data.vacinas;
  const exams = STATE.data.exames;
  const appointments = STATE.data.consultas.filter(
    (appointment) => appointment.status === "agendada",
  );
  const discharges = STATE.data.altas;
  const latestDischarge = discharges[0];
  const latestAppointment = appointments[0];

  return `<p class="lead">Olá, <b>${patientName()}</b></p>
    ${
      latestDischarge
        ? `<div class="card al"><b>Alta hospitalar registrada</b><p>${escapeHtml(latestDischarge.resumo)}</p>${statusBadge(latestDischarge.status)}<br><button class="btn sm" onclick="go('hist')">Ver no histórico</button></div>`
        : '<div class="card al in"><b>Nenhuma alta hospitalar registrada</b><p class="mu">As informações serão exibidas quando forem registradas pela unidade de saúde.</p></div>'
    }
    <div class="grid2">
      <button class="card" onclick="go('exa')"><div class="big">${exams.filter((exam) => ["solicitado", "agendado"].includes(exam.status)).length}</div>exames pendentes</button>
      <button class="card" onclick="go('vac')"><div class="big">${vaccines.filter((vaccine) => vaccine.status === "pendente").length}</div>vacinas pendentes</button>
    </div>
    <div class="card"><h3>Consultas</h3>
      <p>${latestAppointment ? `${escapeHtml(latestAppointment.unidade || "Unidade não informada")}: <b>${escapeHtml(formatDate(latestAppointment.agendado_para, true))}</b>` : "Nenhuma consulta agendada"}</p>
      ${latestAppointment?.motivo ? `<p class="mu">${escapeHtml(latestAppointment.motivo)}</p>` : ""}
    </div>
    <div class="card"><h3>Próximos passos</h3>
      <ul>${latestDischarge?.retorno_recomendado ? `<li>${escapeHtml(latestDischarge.retorno_recomendado)}</li>` : ""}
        ${vaccines
          .filter((vaccine) => vaccine.status === "pendente")
          .map(
            (vaccine) =>
              `<li>Vacina ${escapeHtml(vaccine.nome)}${vaccine.proxima_dose_em ? `: ${escapeHtml(formatDate(vaccine.proxima_dose_em))}` : ""}</li>`,
          )
          .join("")}
        ${exams
          .filter((exam) => exam.status === "agendado")
          .map(
            (exam) =>
              `<li>${escapeHtml(exam.nome)}: ${escapeHtml(formatDate(exam.agendado_para, true))}</li>`,
          )
          .join("")}
        ${!latestDischarge?.retorno_recomendado && !vaccines.some((vaccine) => vaccine.status === "pendente") && !exams.some((exam) => exam.status === "agendado") ? "<li>Nenhum próximo passo registrado.</li>" : ""}
      </ul>
    </div>`;
}

function historyPage() {
  const filters = [
    ["todos", "Tudo"],
    ["consulta", "Consultas"],
    ["exame", "Exames"],
    ["internacao", "Internações e altas"],
    ["encaminhamento", "Encaminhamentos"],
    ["acompanhamento", "Acompanhamentos"],
  ];
  return `<div class="chips">${filters.map(([key, label]) => `<button class="chip ${STATE.historyFilter === key ? "on" : ""}" onclick="setHistoryFilter('${key}')">${label}</button>`).join("")}</div>${timeline()}`;
}

function vaccinesPage() {
  const patient = STATE.data.paciente;
  return `<div class="vc"><div><b>Carteirinha de vacinação</b><h2>${patientName()}</h2><p>CNS ${escapeHtml(patient.cns || "Não informado")}</p><p>${STATE.data.vacinas.filter((vaccine) => vaccine.status === "aplicada").length} doses aplicadas</p></div><div style="font-size:44px" aria-hidden="true">🛡️</div></div>
    <div class="list">${STATE.data.vacinas.map((vaccine) => `<div class="card row"><div><h3>${escapeHtml(vaccine.nome)}</h3><span class="mu">${escapeHtml(vaccine.dose || "")}${vaccine.aplicada_em ? ` · Aplicada em ${escapeHtml(formatDate(vaccine.aplicada_em))}` : ""}${vaccine.proxima_dose_em ? ` · Próxima dose ${escapeHtml(formatDate(vaccine.proxima_dose_em))}` : ""}</span>${vaccine.observacoes ? `<p>${escapeHtml(vaccine.observacoes)}</p>` : ""}</div>${statusBadge(vaccine.status)}</div>`).join("") || '<p class="mu">Nenhuma vacina registrada.</p>'}</div>`;
}

function examsPage() {
  const groups = [
    ["solicitado", "Solicitados"],
    ["agendado", "Agendados"],
    ["concluido", "Concluídos"],
  ];
  return groups
    .map(([status, title]) => {
      const exams = STATE.data.exames.filter((exam) => exam.status === status);
      return `<section><h2>${title}</h2>${exams.map((exam) => `<div class="card"><div class="row"><h3>${escapeHtml(exam.nome)}</h3>${statusBadge(exam.status)}</div><p class="mu">${escapeHtml(exam.unidade_executora || exam.unidade_solicitante || "Unidade não informada")}${exam.agendado_para ? ` · ${escapeHtml(formatDate(exam.agendado_para, true))}` : ` · Solicitado em ${escapeHtml(formatDate(exam.solicitado_em))}`}</p>${exam.solicitante ? `<p>Solicitante: ${escapeHtml(exam.solicitante)}</p>` : ""}${exam.instrucoes ? `<p>${escapeHtml(exam.instrucoes)}</p>` : ""}${exam.resultado_resumo ? `<p>${escapeHtml(exam.resultado_resumo)}</p>` : ""}${documentLink(exam.documento_url, "Abrir laudo")}</div>`).join("") || '<p class="mu">Nenhum exame registrado.</p>'}</section>`;
    })
    .join("");
}

function waitingListPage() {
  const entries = STATE.data.lista_espera;
  return `<div class="card waitlist-notice" role="note">
    <h2>Como funciona a mudança de cor neste exemplo</h2>
    <p>A classificação por cor pode mudar conforme a quantidade de dias de espera. A demonstração mostra como o tempo na fila pode influenciar essa classificação.</p>
  </div>
  <div class="urgency-legend" aria-label="Legenda das cores">
    ${[
      ["vermelho", URGENCY_LABELS.vermelho],
      ["azul", URGENCY_LABELS.azul],
      ["amarelo", URGENCY_LABELS.amarelo],
      ["verde", URGENCY_LABELS.verde],
    ]
      .map(
        ([color, label]) =>
          `<span class="urgency-badge urgency-${color}">${label}</span>`,
      )
      .join("")}
  </div>
  <div class="list">${
    entries
      .map((entry) => {
        const currentLabel = URGENCY_LABELS[entry.classificacao_atual];
        const daysWaiting = Number(entry.dias_espera);
        const classificationChanged =
          entry.classificacao_atual !== entry.classificacao_inicial;
        const showChangeWarning =
          classificationChanged && Boolean(entry.observacoes);

        return `<article class="card waiting-item">
        <div class="waiting-item-heading">
          <div><span class="mu">Procedimento</span><h3>${escapeHtml(entry.procedimento)}</h3></div>
          <span class="urgency-badge urgency-${escapeHtml(entry.classificacao_atual)}">Classificação ${escapeHtml(currentLabel)}</span>
        </div>
        <p><b>Unidade:</b> ${escapeHtml(entry.unidade || "Unidade não informada")}</p>
        <p><b>Tempo de espera:</b> ${daysWaiting} ${daysWaiting === 1 ? "dia" : "dias"}</p>
        <p><b>Entrada na lista:</b> ${escapeHtml(formatDate(entry.data_entrada))}</p>
        ${showChangeWarning ? `<p class="waitlist-change" role="status"><span aria-hidden="true">!</span> <em>${escapeHtml(entry.observacoes)}</em></p>` : ""}
      </article>`;
      })
      .join("") ||
    '<p class="mu">Não há procedimentos aguardando para este paciente.</p>'
  }</div>`;
}

function unitTypeLabel(type) {
  return TYPE_LABELS[type] || type;
}

function unitsPage() {
  const units = STATE.data.unidades.filter(
    (unit) => STATE.unitFilter === "todas" || unit.tipo === STATE.unitFilter,
  );
  const filters = [
    ["todas", "Todas"],
    ["ubs", "UBS"],
    ["clinica", "Clínicas"],
    ["hospital", "Hospitais"],
    ["laboratorio", "Laboratórios"],
  ];
  return `<div class="chips">${filters.map(([key, label]) => `<button class="chip ${STATE.unitFilter === key ? "on" : ""}" onclick="setUnitFilter('${key}')">${label}</button>`).join("")}</div>
    <div class="list">${units.map((unit) => `<div class="card row"><div><h3>${escapeHtml(unit.nome)}</h3><span class="mu">${escapeHtml(unitTypeLabel(unit.tipo))}${unit.horario_atendimento ? ` · ${escapeHtml(unit.horario_atendimento)}` : ""}</span>${unit.endereco ? `<p>${escapeHtml(unit.endereco)}</p>` : ""}</div>${unit.endereco || unit.nome ? `<a class="btn sm sec" href="https://www.google.com/maps/search/?api=1&query=${encodeURIComponent([unit.nome, unit.endereco].filter(Boolean).join(", "))}" target="_blank" rel="noopener noreferrer">Abrir rota</a>` : ""}</div>`).join("") || '<p class="mu">Nenhuma unidade encontrada.</p>'}</div>`;
}

function profilePage() {
  const patient = STATE.data.paciente;
  return `<div class="card"><h2>${patientName()}</h2><p class="mu">Nascimento: ${escapeHtml(formatDate(patient.data_nascimento))}</p>
    ${patient.cns ? `<p>CNS ${escapeHtml(patient.cns)}</p>` : ""}
    ${patient.telefone ? `<p>Telefone ${escapeHtml(patient.telefone)}</p>` : ""}
    ${patient.endereco ? `<p>Endereço ${escapeHtml(patient.endereco)}</p>` : ""}
    <p>UBS de referência: ${escapeHtml(patient.unidade || "Não informada")}</p>
  </div>
  <div class="card"><h3>Quem acessou meus dados</h3><ul>${STATE.data.acessos.map((access) => `<li><b>${escapeHtml(formatDate(access.acessado_em, true))}</b><br><span class="mu">${escapeHtml(access.profissional)}${access.unidade ? ` · ${escapeHtml(access.unidade)}` : ""}${access.motivo ? ` · ${escapeHtml(access.motivo)}` : ""}</span></li>`).join("") || "<li>Não há acessos registrados.</li>"}</ul></div>`;
}

function chatPage() {
  return `<div class="cm chat" aria-live="polite">${STATE.chat.map((message) => `<div class="msg ${message.sender === "user" ? "u" : ""}">${escapeHtml(message.text)}${message.page ? `<br><button class="btn sm" onclick="go('${message.page}')">Abrir</button>` : ""}</div>`).join("")}</div>
    <div class="cf">${
      STATE.chatFlow === "referral"
        ? `<form class="chat-form" onsubmit="validateReferral(event)">
            <label for="referralCpf">CPF do profissional</label>
            <input id="referralCpf" name="cpf" inputmode="numeric" autocomplete="off" placeholder="000.000.000-00" required>
            <label for="referralCoren">COREN</label>
            <input id="referralCoren" name="coren" autocomplete="off" placeholder="000001-TE/RS" required>
            <button class="btn" type="submit">Verificar cadastro</button>
          </form>
          <button class="chip" onclick="cancelChatFlow()">Cancelar</button>`
        : STATE.chatFlow === "triage"
          ? `<form class="chat-form" onsubmit="answerTriage(event)">
              <label for="triageAnswer">${escapeHtml(TRIAGE_QUESTIONS[STATE.triageIndex])}</label>
              <input id="triageAnswer" name="answer" maxlength="500" autocomplete="off" required>
              <button class="btn" type="submit">Registrar resposta</button>
            </form>
            <button class="chip" onclick="cancelChatFlow()">Cancelar triagem</button>`
          : `<div class="chips">${[["Minhas vacinas", "vac"], ["Meus exames", "exa"], ["Unidades perto", "uni"], ["Minha alta", "hist"]].map(([question, page]) => `<button class="chip" onclick="sendQuickChat('${question}', '${page}')">${question}</button>`).join("")}
            <button class="chip" onclick="beginReferral()">➡️ Encaminhar paciente</button>
          </div>
          <form class="row" onsubmit="sendChatFromForm(event)"><input id="chatInput" aria-label="Mensagem" placeholder="Digite sua pergunta" autocomplete="off"><button class="btn" style="margin:0">Enviar</button></form>`
    }</div>`;
}

function patientPage() {
  const pages = {
    inicio: ["Início", patientHome],
    hist: ["Histórico", historyPage],
    vac: ["Vacinação", vaccinesPage],
    exa: ["Exames", examsPage],
    espera: ["Lista de espera", waitingListPage],
    mais: [
      "Mais opções",
      () =>
        `<div class="list"><button class="card row" onclick="go('uni')"><span><h3>📍 Unidades próximas</h3><span class="mu">UBS, clínicas, hospitais e laboratórios</span></span>›</button><button class="card row" onclick="go('perfil')"><span><h3>👤 Perfil</h3><span class="mu">Dados e acessos ao prontuário</span></span>›</button></div>`,
    ],
    uni: ["Unidades próximas", unitsPage],
    perfil: ["Perfil", profilePage],
  };
  const [title, renderContent] = pages[STATE.page] || pages.inicio;
  const subpage = ["uni", "perfil"].includes(STATE.page);
  return `<div class="phone"><header class="ph">${subpage ? `<button class="ib" aria-label="Voltar" onclick="go('mais')">‹</button>` : ""}<h1>${title}</h1></header><main class="scr">${renderContent()}</main>
    <nav class="bn" aria-label="Navegação">${[
      ["inicio", "🏠", "Início"],
      ["hist", "🕘", "Histórico"],
      ["vac", "💉", "Vacinas"],
      ["exa", "🧪", "Exames"],
      ["espera", "⏳", "Espera"],
      ["mais", "☰", "Mais"],
    ]
      .map(
        ([key, icon, label]) =>
          `<button class="${STATE.page === key || (subpage && key === "mais") ? "on" : ""}" onclick="go('${key}')"><span aria-hidden="true">${icon}</span>${label}</button>`,
      )
      .join("")}</nav></div>
    <button class="fab ${STATE.chatOpen ? "op" : ""}" aria-label="${STATE.chatOpen ? "Fechar" : "Abrir"} assistente" aria-expanded="${STATE.chatOpen}" onclick="toggleChat()">${STATE.chatOpen ? "✕" : "💬"}</button>
    ${STATE.chatOpen ? `<section class="cp" role="dialog" aria-label="Assistente"><div class="ch"><b>Assistente Conecta</b><button class="ib" aria-label="Fechar assistente" onclick="toggleChat()">✕</button></div>${chatPage()}</section>` : ""}`;
}

