<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <title>Assistente Virtual - Hospital</title>
    <link rel="stylesheet" href="assets/css/chatbot.css">
</head>
<body>
    <!-- Container principal do chatbot -->
    <div class="chatbot-container">
        
        <!-- TELA 1: Identificação -->
        <div id="telaIdentificacao" class="tela-ativa">
            <div class="identificacao-wrapper">
                <header class="identificacao-header">
                    <h1>🏥 Assistente Virtual</h1>
                    <p>Hospital de Caridade Santa Rita</p>
                </header>

                <main class="identificacao-main">
                    <p class="identificacao-texto">
                        Olá! 👋<br>
                        Sou o Assistente Virtual do Hospital.<br><br>
                        Antes de começarmos, precisamos de algumas informações.
                    </p>

                    <form id="formIdentificacao" class="form-identificacao">
                        <div class="form-group">
                            <label for="pacienteNome">Nome:</label>
                            <input 
                                type="text" 
                                id="pacienteNome" 
                                name="nome" 
                                placeholder="Seu nome completo"
                                required
                            >
                        </div>

                        <div class="form-group">
                            <label for="pacienteData">Data de nascimento:</label>
                            <input 
                                type="date" 
                                id="pacienteData" 
                                name="data_nascimento"
                                required
                            >
                        </div>

                        <button type="submit" class="btn btn-primario btn-grande">
                            Iniciar atendimento
                        </button>
                    </form>
                </main>
            </div>
        </div>

        <!-- TELA 2: Chat -->
        <div id="telaChat" class="tela-inativa">
            <header class="chat-header">
                <h1>🏥 Assistente Virtual</h1>
                <p id="pacienteNomeExibido">Paciente</p>
            </header>

            <main class="chat-mensagens" id="chatMensagens">
                <!-- Mensagens aparecem aqui dinamicamente -->
            </main>

            <div class="chat-ia">
                <form id="formChatIA" class="chat-ia-form">
                    <label for="mensagemIA">Não encontrou sua dúvida nas opções?</label>
                    <div class="chat-ia-linha">
                        <input
                            type="text"
                            id="mensagemIA"
                            name="mensagem"
                            maxlength="1000"
                            placeholder="Digite sua dúvida..."
                            autocomplete="off"
                        >
                        <button type="submit" id="botaoEnviarIA" class="chat-ia-enviar">Enviar</button>
                    </div>
                    <small>A IA responde com base nas informações oficiais cadastradas no chatbot.</small>
                </form>
            </div>

            <footer class="chat-opcoes" id="chatOpcoes">
                <!-- Botões de opções aparecem aqui dinamicamente -->
            </footer>
        </div>

    </div>

    <script src="assets/js/chatbot.js"></script>
</body>
</html>
