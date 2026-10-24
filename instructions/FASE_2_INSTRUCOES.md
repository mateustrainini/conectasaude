# FASE 2: Interface do Chatbot — Instruções

## 1. Estrutura de pastas

```
chatbot/
├── index.php                  ← Página principal
├── assets/
│   ├── css/
│   │   └── chatbot.css       ← Estilos
│   ├── js/
│   │   └── chatbot.js        ← Lógica (dados fictícios)
│   └── img/
└── config/
    └── db.php                ← Conexão (da Fase 1)
```

## 2. Arquivos da Fase 2

- **index.php** — Página raiz com duas telas:
  - Tela 1: Identificação (nome, data de nascimento)
  - Tela 2: Chat (mensagens + opções)

- **chatbot.css** — Estilos responsivos:
  - Mobile-first
  - Mensagens com animações
  - Botões acessíveis
  - Dark mode (prefers-color-scheme)
  - Sem padding em safe-area (notch/action bar)

- **chatbot.js** — Lógica (ainda com dados fictícios):
  - Formulário de identificação
  - Navegação entre categorias e perguntas (árvore)
  - Mensagens do bot e paciente
  - Histórico de interações
  - Botões "Voltar", "Menu principal", "Encerrar"

## 3. Como testar

### Desenvolvimento local

```bash
# Se usar PHP built-in (versão 5.4+)
cd /caminho/para/chatbot
php -S localhost:8000
```

Acesse: `http://localhost:8000`

### Com Apache

1. Copie a pasta `chatbot/` para `htdocs/`
2. Acesse: `http://localhost/chatbot`

## 4. Fluxo de navegação (Fase 2)

```
┌─────────────────────────┐
│  Tela Identificação     │
│  Nome                   │
│  Data de nascimento     │
│  [Iniciar atendimento]  │
└────────────┬────────────┘
             │
             ↓
┌─────────────────────────┐
│  Tela Chat              │
│  Olá, João!             │
│  [Internação] [Exames]  │
│  [Convênios]  [...]     │
│  [Encerrar]             │
└────────────┬────────────┘
             │
        ┌────┴──────────────────┐
        ↓                       ↓
    Categoria          Categoria
    Internação         Exames
    ├─ [Visitas]       ├─ [Preparo]
    ├─ [Acompanhantes] ├─ [Resultado]
    ├─ [Documentos]    │
    ├─ [← Voltar]      ├─ [← Voltar]
    └─ [Encerrar]      └─ [Encerrar]
        │                   │
        ↓                   ↓
    Submenu Visitas     Submenu Preparo
    ├─ [Qual o horário?]
    ├─ [Quantos?]
    ├─ [Menores?]
    ├─ [← Voltar]
    └─ [Encerrar]
```

## 5. Dados fictícios

Os dados vêm de arrays em `chatbot.js`:

```javascript
dadosFicticios = {
    categorias: [...],
    perguntas: [...]
}
```

Isso permite testar a interface sem o banco.

Na **Fase 3**, esse arquivo será substituído por chamadas Fetch → API PHP → MySQL.

## 6. Responsividade

- **Celular**: tela cheia, botões grandes
- **Tablet**: ajustado
- **Desktop**: janela centralizada (max-width: 500px)

Teste com:

```bash
# Chrome DevTools: Ctrl+Shift+M (Cmd+Shift+M no Mac)
```

Ou acesse no seu celular via:

```bash
# Descobrir IP local
ifconfig | grep inet

# Acessar de outro dispositivo na mesma rede
http://SEU_IP:8000
```

## 7. Validações (Fase 2)

- Nome não vazio
- Data de nascimento preenchida
- Mensagens aparecem em tempo real
- Navegação funciona corretamente
- Encerrar volta para identificação

Validações no **backend** e no **banco** vêm na **Fase 3**.

## 8. Pontos de atenção

### Acessibilidade

- Fontes legíveis (16px base)
- Contraste adequado
- Dark mode incluído
- Respeita `prefers-reduced-motion`
- Botões com tamanho mínimo de toque (44-48px)

### Performance

- JS puro (sem jQuery, React, etc.)
- CSS otimizado
- Sem chamadas externas na Fase 2
- Smooth scroll nativo

### UX

- Animações discretas (fade-in de mensagens)
- Feedback imediato ao clicar
- Mensagens do bot vs. paciente diferenciadas
- Histórico de navegação registrado

## 9. Próxima etapa (Fase 3)

Na Fase 3, conectaremos:

```
JavaScript → Fetch → PHP → PDO → MySQL
```

Então:

1. `chatbot.js` vai chamar a API
2. `api/` vai servir os dados do banco
3. Eliminaremos `dadosFicticios`
4. Histórico será salvo no banco
5. Início e fim de conversa serão registrados

## 10. Dicas de desenvolvimento

### Testar em diferentes dispositivos

- iPhone (375px, 667px)
- iPad (768px)
- Android (360px, 720px)
- Desktop (1024px+)

### Debug

Abra o **Console** do navegador (F12) para ver qualquer erro.

Se precisar adicionar `console.log()` para debug:

```javascript
console.log('Pergunta selecionada:', perguntaId);
```

### Modificar dados fictícios

Edite os arrays em `chatbot.js` e recarregue a página (Ctrl+R ou Cmd+R).

Não precisa reiniciar o servidor.

## 11. Estrutura de um arquivo da Fase 2

Todos os 3 arquivos (`index.php`, `chatbot.css`, `chatbot.js`) trabalham juntos:

1. **index.php** — Define a estrutura HTML (duas telas)
2. **chatbot.css** — Estiliza tudo (responsivo, animações)
3. **chatbot.js** — Controla o fluxo (identificação, chat, navegação)

Eles **não têm dependências externas** e rodam no navegador sozinhos.

Na Fase 3, **apenas** `chatbot.js` será modificado para fazer fetch de dados da API.

