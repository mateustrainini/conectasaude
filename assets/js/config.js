const API_URL = "../api/portal.php";
const TYPE_LABELS = {
  ubs: "UBS",
  hospital: "Hospital",
  clinica: "Clínica",
  laboratorio: "Laboratório",
};
const EVENT_TYPES = {
  consulta: ["🩺", "Consulta", "var(--k1)"],
  exame: ["🧪", "Exame", "var(--k2)"],
  internacao: ["🏥", "Internação", "var(--k3)"],
  alta: ["🏠", "Alta", "var(--k4)"],
  encaminhamento: ["➡️", "Encaminhamento", "var(--k5)"],
  acompanhamento: ["💚", "Acompanhamento", "var(--k4)"],
};
const STATUS_LABELS = {
  pendente: "Pendente",
  enviada: "Enviada",
  recebida: "Recebida",
  acompanhamento: "Acompanhamento registrado",
  aplicada: "Aplicada",
  solicitado: "Solicitado",
  agendado: "Agendado",
  concluido: "Concluído",
  realizada: "Realizada",
  cancelada: "Cancelada",
  liberado: "Acesso liberado",
  revogado: "Acesso revogado",
};
const URGENCY_LABELS = {
  verde: "Verde",
  amarelo: "Amarela",
  laranja: "Laranja",
  vermelho: "Vermelha",
};
const STATE = {
  page: "inicio",
  historyFilter: "todos",
  unitFilter: "todas",
  patientId: null,
  requestId: 0,
  chatOpen: false,
  chat: [],
  chatFlow: "idle",
  triageIndex: 0,
  triageAnswers: [],
  data: null,
};
const $ = (selector) => document.querySelector(selector);
const TRIAGE_QUESTIONS = [
  "Qual é o principal motivo do atendimento?",
  "Quais sintomas ou sinais foram observados?",
  "Quando começou ou há quanto tempo acontece?",
  "Há alguma informação importante para a equipe? Se não houver, escreva “não informado”.",
];

