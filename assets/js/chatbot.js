/* ============================================================================
   CHATBOT HOSPITALAR - JAVASCRIPT v2
   Fase 3: Integrado com API PHP + MySQL via Fetch
   ============================================================================ */

// ============================================================================
// ESTADO DA APLICAÇÃO
// ============================================================================

const app = {
    paciente: {
        id: null,
        nome: '',
        data_nascimento: ''
    },
    conversa_id: null,
    mensagens: [],
    pergunta_atual_id: null,
    historico_ids: [],
    carregando: false
};

// ============================================================================
// CONFIGURAÇÃO
// ============================================================================

const API_BASE = './api/'; // Raiz do projeto

// ============================================================================
// FUNÇÕES DE FETCH
// ============================================================================

async function chamar_api(endpoint, metodo = 'GET', dados = null) {
    try {
        const opcoes = {
            method: metodo,
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        };

        if (metodo === 'POST' && dados) {
            opcoes.body = new URLSearchParams(dados).toString();
        }

        let url = API_BASE + endpoint;
        if (metodo === 'GET' && dados) {
            url += '?' + new URLSearchParams(dados).toString();
        }

        const resposta = await fetch(url, opcoes);
        const json = await resposta.json();

        return json;

    } catch (erro) {
        console.error('Erro ao chamar API:', erro);
        return {
            success: false,
            message: 'Erro ao conectar com o servidor'
        };
    }
}

// ============================================================================
// FUNÇÕES AUXILIARES
// ============================================================================

function obterCategoriasDoBackend() {
    // Na Fase 3, as categorias vêm do banco
    // Mas vamos manter uma lista básica para o menu inicial
    return [
        { id: 1, nome: 'Internação', icone: '🏥' },
        { id: 2, nome: 'Exames', icone: '🧪' },
        { id: 3, nome: 'Convênios', icone: '💳' },
        { id: 4, nome: 'Consultas', icone: '👨‍⚕️' },
        { id: 5, nome: 'Contato', icone: '📞' }
    ];
}

function mostrarCarregamento(visivel) {
    app.carregando = visivel;
    // Opcional: mostrar spinner
}

// ============================================================================
// MANIPULAÇÃO DE TELAS
// ============================================================================

function mostrarTela(idTela) {
    document.querySelectorAll('[class*="tela-"]').forEach(tela => {
        tela.classList.remove('tela-ativa');
        tela.classList.add('tela-inativa');
    });
    document.getElementById(idTela).classList.remove('tela-inativa');
    document.getElementById(idTela).classList.add('tela-ativa');
}

// ============================================================================
// MANIPULAÇÃO DE MENSAGENS E OPÇÕES
// ============================================================================

function adicionarMensagem(tipo, conteudo) {
    const container = document.getElementById('chatMensagens');
    const div = document.createElement('div');
    
    div.className = `msg-${tipo}`;
    const msgConteudo = document.createElement('div');
    msgConteudo.className = 'msg-conteudo';
    msgConteudo.textContent = conteudo;
    div.appendChild(msgConteudo);
    
    container.appendChild(div);
    container.scrollTop = container.scrollHeight;
    
    app.mensagens.push({ tipo, conteudo });
}

function limparOpcoes() {
    document.getElementById('chatOpcoes').innerHTML = '';
}

function adicionarOpcoes(opcoes) {
    const container = document.getElementById('chatOpcoes');
    container.innerHTML = '';

    if (opcoes.length === 0) {
        return;
    }

    const div = document.createElement('div');
    div.className = 'opcoes-grupo';

    opcoes.forEach(opcao => {
        const botao = document.createElement('button');
        botao.className = 'opcao-botao';
        botao.textContent = opcao.pergunta;
        botao.addEventListener('click', () => {
            selecionarPergunta(opcao.id);
        });
        div.appendChild(botao);
    });

    container.appendChild(div);
}

function adicionarOpcaoNavegacao(texto, callback) {
    const container = document.getElementById('chatOpcoes');
    
    const botao = document.createElement('button');
    botao.className = 'opcao-botao';
    botao.style.borderColor = '#666';
    botao.style.color = '#666';
    botao.textContent = texto;
    botao.addEventListener('click', callback);
    
    container.appendChild(botao);
}

// ============================================================================
// FLUXO DO CHAT
// ============================================================================

async function iniciarChat() {
    app.mensagens = [];
    app.pergunta_atual_id = null;
    app.historico_ids = [];

    document.getElementById('pacienteNomeExibido').textContent = app.paciente.nome;

    mostrarTela('telaChat');

    // Mensagem de boas-vindas
    adicionarMensagem('bot', `Olá, ${app.paciente.nome}! 👋\n\nComo posso ajudá-lo?`);

    // Exibir categorias como opções
    const categorias = obterCategoriasDoBackend();

    limparOpcoes();
    const container = document.getElementById('chatOpcoes');
    container.innerHTML = '';

    const div = document.createElement('div');
    div.className = 'opcoes-grupo';

    categorias.forEach(categoria => {
        const botao = document.createElement('button');
        botao.className = 'opcao-botao';
        botao.textContent = `${categoria.icone} ${categoria.nome}`;
        botao.addEventListener('click', () => {
            selecionarCategoria(categoria.id);
        });
        div.appendChild(botao);
    });

    container.appendChild(div);

    // Opção para encerrar
    adicionarOpcaoNavegacao('❌ Encerrar atendimento', encerrarConversa);
}

async function selecionarCategoria(categoriaId) {
    mostrarCarregamento(true);

    // Chamar API para obter perguntas da categoria
    const resultado = await chamar_api('perguntas.php', 'GET', {
        categoria_id: categoriaId
    });

    mostrarCarregamento(false);

    if (!resultado.success) {
        adicionarMensagem('bot', 'Desculpe, ocorreu um erro ao carregar as perguntas.');
        adicionarOpcaoNavegacao('🏠 Menu principal', voltarMenuPrincipal);
        return;
    }

    const categoria = obterCategoriasDoBackend().find(c => c.id === categoriaId);
    
    // Adicionar a ação do paciente
    adicionarMensagem('paciente', `${categoria.icone} ${categoria.nome}`);

    // Adicionar mensagem do bot
    adicionarMensagem('bot', `Certo! O que você gostaria de saber sobre ${categoria.nome.toLowerCase()}?`);

    const perguntas = resultado.perguntas || [];

    if (perguntas.length === 0) {
        adicionarMensagem('bot', 'Desculpe, não há perguntas disponíveis nesta categoria.');
        adicionarOpcaoNavegacao('🏠 Menu principal', voltarMenuPrincipal);
        return;
    }

    // Exibir opções
    limparOpcoes();
    adicionarOpcoes(perguntas);
    adicionarOpcaoNavegacao('← Voltar', voltarMenuPrincipal);
    adicionarOpcaoNavegacao('❌ Encerrar atendimento', encerrarConversa);
}

async function selecionarPergunta(perguntaId) {
    mostrarCarregamento(true);

    // Chamar API para obter resposta
    const resultado = await chamar_api('responder.php', 'POST', {
        conversa_id: app.conversa_id,
        pergunta_id: perguntaId
    });

    mostrarCarregamento(false);

    if (!resultado.success) {
        adicionarMensagem('bot', 'Desculpe, ocorreu um erro ao processar sua pergunta.');
        adicionarOpcaoNavegacao('🏠 Menu principal', voltarMenuPrincipal);
        return;
    }

    // Registrar no histórico
    app.historico_ids.push(perguntaId);
    app.pergunta_atual_id = perguntaId;

    // Adicionar pergunta do paciente
    adicionarMensagem('paciente', resultado.pergunta);

    // Adicionar resposta do bot
    adicionarMensagem('bot', resultado.resposta);

    // Obter próximas opções
    const opcoes = resultado.opcoes || [];

    limparOpcoes();

    if (opcoes.length > 0) {
        adicionarOpcoes(opcoes);
    }

    // Botões de navegação
    adicionarOpcaoNavegacao('🏠 Menu principal', voltarMenuPrincipal);
    adicionarOpcaoNavegacao('❌ Encerrar atendimento', encerrarConversa);
}

function voltarMenuPrincipal() {
    app.pergunta_atual_id = null;
    iniciarChat();
}

async function encerrarConversa() {
    // Finalizar no banco
    if (app.conversa_id) {
        mostrarCarregamento(true);
        
        const resultado = await chamar_api('finalizarConversa.php', 'POST', {
            conversa_id: app.conversa_id
        });

        mostrarCarregamento(false);
        
        if (!resultado.success) {
            console.error('Erro ao finalizar conversa:', resultado.message);
        }
    }

    // Mensagem de despedida
    adicionarMensagem('bot', `Obrigado por usar o Assistente Virtual, ${app.paciente.nome}! 👋\n\nTenha um ótimo dia!`);

    // Limpar opções
    limparOpcoes();

    // Voltar para identificação após 2 segundos
    setTimeout(() => {
        app.paciente.id = null;
        app.paciente.nome = '';
        app.paciente.data_nascimento = '';
        app.conversa_id = null;
        app.mensagens = [];
        document.getElementById('formIdentificacao').reset();
        mostrarTela('telaIdentificacao');
    }, 2000);
}

// ============================================================================
// FASE 6 - PERGUNTA LIVRE COM IA
// ============================================================================

async function enviarPerguntaIA(mensagem) {
    if (!app.conversa_id || app.carregando) {
        return;
    }

    const campo = document.getElementById('mensagemIA');
    const botao = document.getElementById('botaoEnviarIA');

    adicionarMensagem('paciente', mensagem);
    campo.value = '';
    campo.disabled = true;
    botao.disabled = true;
    botao.textContent = '...';
    mostrarCarregamento(true);

    const resultado = await chamar_api('chatIA.php', 'POST', {
        conversa_id: app.conversa_id,
        mensagem: mensagem
    });

    mostrarCarregamento(false);
    campo.disabled = false;
    botao.disabled = false;
    botao.textContent = 'Enviar';

    if (!resultado.success) {
        adicionarMensagem('bot', resultado.message || 'Não foi possível consultar a IA agora.');
        campo.focus();
        return;
    }

    adicionarMensagem('bot', resultado.resposta);
    campo.focus();
}

document.getElementById('formChatIA').addEventListener('submit', async function(e) {
    e.preventDefault();

    const campo = document.getElementById('mensagemIA');
    const mensagem = campo.value.trim();

    if (mensagem.length < 2) {
        campo.focus();
        return;
    }

    await enviarPerguntaIA(mensagem);
});

// ============================================================================
// MANIPULAÇÃO DO FORMULÁRIO DE IDENTIFICAÇÃO
// ============================================================================

document.getElementById('formIdentificacao').addEventListener('submit', async function(e) {
    e.preventDefault();

    const nome = document.getElementById('pacienteNome').value.trim();
    const data = document.getElementById('pacienteData').value;

    if (!nome || !data) {
        alert('Por favor, preencha todos os campos.');
        return;
    }

    // Desabilitar formulário enquanto processa
    const botao = this.querySelector('button[type="submit"]');
    const textoOriginal = botao.textContent;
    botao.disabled = true;
    botao.textContent = 'Aguarde...';

    // Chamar API para iniciar conversa
    mostrarCarregamento(true);

    const resultado = await chamar_api('iniciarConversa.php', 'POST', {
        nome: nome,
        data_nascimento: data
    });

    mostrarCarregamento(false);

    botao.disabled = false;
    botao.textContent = textoOriginal;

    if (!resultado.success) {
        alert('Erro: ' + (resultado.message || 'Não foi possível iniciar o atendimento'));
        return;
    }

    // Salvar dados
    app.paciente.id = resultado.paciente_id;
    app.paciente.nome = resultado.paciente_nome;
    app.paciente.data_nascimento = data;
    app.conversa_id = resultado.conversa_id;

    // Iniciar chat
    iniciarChat();
});

// ============================================================================
// INICIALIZAÇÃO
// ============================================================================

document.addEventListener('DOMContentLoaded', function() {
    // Mostrar tela de identificação ao carregar
    mostrarTela('telaIdentificacao');
    document.getElementById('pacienteNome').focus();
});
