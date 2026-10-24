// function toggleChat() {
//   STATE.chatOpen = !STATE.chatOpen;
//   if (STATE.chatOpen && STATE.chat.length === 0) {
//     STATE.chat.push({
//       sender: "assistant",
//       text: `Olá, ${STATE.data.paciente.nome}. Posso consultar as informações registradas no banco.`,
//     });
//   }
//   render();
// }

// function beginReferral() {
//   STATE.chatFlow = "referral";
//   STATE.chat.push({
//     sender: "assistant",
//     text: "Para ilustrar um encaminhamento, informe o CPF e o COREN do profissional. Os dados serão conferidos no cadastro local de demonstração.",
//   });
//   render();
// }

// async function validateReferral(event) {
//   event.preventDefault();
//   const form = event.currentTarget;
//   const submitButton = form.querySelector('button[type="submit"]');
//   submitButton.disabled = true;

//   try {
//     const response = await fetch("../api/validar_profissional.php", {
//       method: "POST",
//       headers: { Accept: "application/json" },
//       body: new FormData(form),
//     });
//     const result = await response.json();
//     if (!response.ok || !result.success) {
//       throw new Error(result.message || "Não foi possível validar o profissional.");
//     }

//     STATE.chat.push({ sender: "user", text: "Verificar cadastro profissional" });
//     if (!result.valid) {
//       STATE.chat.push({ sender: "assistant", text: result.message });
//       render();
//       return;
//     }

//     STATE.chat.push({
//       sender: "assistant",
//       text: `${result.professional.nome} validado no cadastro de demonstração. Vamos registrar uma triagem básica; isso não substitui avaliação profissional.`,
//     });
//     STATE.chatFlow = "triage";
//     STATE.triageIndex = 0;
//     STATE.triageAnswers = [];
//     STATE.chat.push({
//       sender: "assistant",
//       text: TRIAGE_QUESTIONS[STATE.triageIndex],
//     });
//     render();
//   } catch (error) {
//     console.error(error);
//     STATE.chat.push({
//       sender: "assistant",
//       text: error.message || "Não foi possível validar o profissional. Tente novamente.",
//     });
//     render();
//   }
// }

// function answerTriage(event) {
//   event.preventDefault();
//   const answer = $("#triageAnswer").value.trim();
//   if (!answer) return;

//   STATE.triageAnswers.push(answer);
//   STATE.chat.push({ sender: "user", text: answer });
//   STATE.triageIndex += 1;

//   if (STATE.triageIndex < TRIAGE_QUESTIONS.length) {
//     STATE.chat.push({
//       sender: "assistant",
//       text: TRIAGE_QUESTIONS[STATE.triageIndex],
//     });
//   } else {
//     const summary = STATE.triageAnswers
//       .map((item, index) => `${index + 1}. ${TRIAGE_QUESTIONS[index]} ${item}`)
//       .join("\n");
//     STATE.chat.push(
//       {
//         sender: "assistant",
//         text: `Triagem de demonstração registrada:\n${summary}`,
//       },
//       {
//         sender: "assistant",
//         text: "Em uma versão integrada, a IA poderia resumir o histórico do paciente junto com as respostas desta triagem para apoiar a equipe. Aqui não há análise por IA nem gravação no prontuário: é apenas uma ilustração, sem diagnóstico.",
//       },
//     );
//     STATE.chatFlow = "idle";
//     STATE.triageIndex = 0;
//     STATE.triageAnswers = [];
//   }

//   render();
// }

// function cancelChatFlow() {
//   STATE.chatFlow = "idle";
//   STATE.triageIndex = 0;
//   STATE.triageAnswers = [];
//   STATE.chat.push({
//     sender: "assistant",
//     text: "Fluxo de demonstração encerrado. Nenhum dado foi salvo no prontuário.",
//   });
//   render();
// }

// function answerChat(question) {
//   const query = question.toLocaleLowerCase("pt-BR");
//   const { vacinas, exames, unidades, altas } = STATE.data;
//   if (/vac/.test(query)) {
//     const pending = vacinas.filter((vaccine) => vaccine.status === "pendente");
//     return {
//       text: pending.length
//         ? `Há ${pending.length} vacina(s) pendente(s): ${pending.map((vaccine) => vaccine.nome).join(", ")}.`
//         : "Não há vacinas pendentes registradas.",
//       page: "vac",
//     };
//   }
//   if (/exam/.test(query)) {
//     const open = exames.filter((exam) =>
//       ["solicitado", "agendado"].includes(exam.status),
//     );
//     return {
//       text: open.length
//         ? `Há ${open.length} exame(s) solicitado(s) ou agendado(s): ${open.map((exam) => exam.nome).join(", ")}.`
//         : "Não há exames pendentes registrados.",
//       page: "exa",
//     };
//   }
//   if (/unid|perto|ubs|hospital/.test(query)) {
//     return {
//       text: `Há ${unidades.length} unidade(s) de saúde cadastrada(s).`,
//       page: "uni",
//     };
//   }
//   if (/alta|hist|consulta/.test(query)) {
//     return {
//       text: altas.length
//         ? `A alta mais recente está com status ${STATUS_LABELS[altas[0].status] || altas[0].status}.`
//         : "Não há alta hospitalar registrada.",
//       page: "hist",
//     };
//   }
//   return {
//     text: "Posso consultar vacinas, exames, histórico, altas e unidades cadastradas.",
//   };
// }

// function sendChat(question) {
//   if (!question) return;
//   const answer = answerChat(question);
//   STATE.chat.push(
//     { sender: "user", text: question },
//     { sender: "assistant", text: answer.text, page: answer.page },
//   );
//   render();
//   $("#chatInput")?.focus();
// }

// function sendChatFromForm(event) {
//   event.preventDefault();
//   const input = $("#chatInput");
//   const question = input.value.trim();
//   if (question) sendChat(question);
// }

// =============================================================

function toggleChat() {
  STATE.chatOpen = !STATE.chatOpen;

  if (STATE.chatOpen && STATE.chat.length === 0) {
    STATE.chat.push({
      sender: "assistant",
      text: `Olá, ${STATE.data.paciente.nome}. Posso consultar as informações registradas no banco.`,
    });
  }

  render();
}

function beginReferral() {
  STATE.chatFlow = "referral";

  STATE.chat.push({
    sender: "assistant",
    text: "Para ilustrar um encaminhamento, informe o CPF e o COREN do profissional. Os dados serão conferidos no cadastro local de demonstração.",
  });

  render();
}

async function validateReferral(event) {
  event.preventDefault();

  const form = event.currentTarget;
  const submitButton = form.querySelector('button[type="submit"]');

  submitButton.disabled = true;

  try {
    const response = await fetch("../api/validar_profissional.php", {
      method: "POST",
      headers: {
        Accept: "application/json",
      },
      body: new FormData(form),
    });

    const result = await response.json();

    if (!response.ok || !result.success) {
      throw new Error(
        result.message || "Não foi possível validar o profissional.",
      );
    }

    STATE.chat.push({
      sender: "user",
      text: "Verificar cadastro profissional",
    });

    if (!result.valid) {
      STATE.chat.push({
        sender: "assistant",
        text: result.message,
      });

      render();
      return;
    }

    STATE.chat.push({
      sender: "assistant",
      text: `${result.professional.nome} validado no cadastro de demonstração. Vamos registrar uma triagem básica; isso não substitui avaliação profissional.`,
    });

    STATE.chatFlow = "triage";
    STATE.triageIndex = 0;
    STATE.triageAnswers = [];

    STATE.chat.push({
      sender: "assistant",
      text: TRIAGE_QUESTIONS[STATE.triageIndex],
    });

    render();
  } catch (error) {
    console.error(error);

    STATE.chat.push({
      sender: "assistant",
      text:
        error.message ||
        "Não foi possível validar o profissional. Tente novamente.",
    });

    render();
  }
}

function answerTriage(event) {
  event.preventDefault();

  const answer = $("#triageAnswer").value.trim();

  if (!answer) return;

  STATE.triageAnswers.push(answer);

  STATE.chat.push({
    sender: "user",
    text: answer,
  });

  STATE.triageIndex += 1;

  if (STATE.triageIndex < TRIAGE_QUESTIONS.length) {
    STATE.chat.push({
      sender: "assistant",
      text: TRIAGE_QUESTIONS[STATE.triageIndex],
    });
  } else {
    const summary = STATE.triageAnswers
      .map(
        (item, index) =>
          `${index + 1}. ${TRIAGE_QUESTIONS[index]} ${item}`,
      )
      .join("\n");

    STATE.chat.push(
      {
        sender: "assistant",
        text: `Triagem de demonstração registrada:\n${summary}`,
      },
      {
        sender: "assistant",
        text: "Em uma versão integrada, a IA poderia resumir o histórico do paciente junto com as respostas desta triagem para apoiar a equipe. Aqui não há análise por IA nem gravação no prontuário: é apenas uma ilustração, sem diagnóstico.",
      },
    );

    STATE.chatFlow = "idle";
    STATE.triageIndex = 0;
    STATE.triageAnswers = [];
  }

  render();
}

function cancelChatFlow() {
  STATE.chatFlow = "idle";
  STATE.triageIndex = 0;
  STATE.triageAnswers = [];

  STATE.chat.push({
    sender: "assistant",
    text: "Fluxo de demonstração encerrado. Nenhum dado foi salvo no prontuário.",
  });

  render();
}

async function getChatConversationId() {
  if (STATE.chatConversationId) {
    return STATE.chatConversationId;
  }

  const patient = STATE.data?.paciente;

  if (!patient?.nome || !patient?.data_nascimento) {
    throw new Error("Não foi possível identificar o paciente.");
  }

  const body = new URLSearchParams({
    nome: patient.nome,
    data_nascimento: patient.data_nascimento,
  });

  const response = await fetch("../api/iniciarConversa.php", {
    method: "POST",

    headers: {
      Accept: "application/json",
      "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
    },

    body,
  });

  const result = await response.json();

  if (!response.ok || !result.success) {
    throw new Error(
      result.message || "Não foi possível iniciar a conversa.",
    );
  }

  STATE.chatConversationId = result.conversa_id;

  return result.conversa_id;
}

async function sendChat(question) {
  if (!question?.trim()) return;

  STATE.chat.push({
    sender: "user",
    text: question,
  });

  render();

  try {
    const conversaId = await getChatConversationId();

    const body = new URLSearchParams({
      conversa_id: conversaId,
      mensagem: question,
    });

    const response = await fetch("../api/chatIA.php", {
      method: "POST",

      headers: {
        Accept: "application/json",
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
      },

      body,
    });

    const result = await response.json();

    if (!response.ok || !result.success) {
      throw new Error(
        result.message || "Não foi possível consultar a IA.",
      );
    }

    STATE.chat.push({
      sender: "assistant",
      text: result.resposta,
    });
  } catch (error) {
    console.error(error);

    STATE.chat.push({
      sender: "assistant",
      text:
        error.message ||
        "Não foi possível consultar o assistente no momento.",
    });
  }

  render();

  $("#chatInput")?.focus();
}

function sendChatFromForm(event) {
  event.preventDefault();

  const input = $("#chatInput");
  const question = input.value.trim();

  if (question) {
    sendChat(question);
  }
}