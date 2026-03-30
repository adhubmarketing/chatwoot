# Guia de Testes - Funcionalidade Kanban

## Componentes Implementados

### ✅ Novos Componentes
- `DeleteConfirmDialog.vue` - Diálogo reutilizável de confirmação de exclusão
- `CreateStepModal.vue` - Modal para criar nova etapa
- `TaskModal.vue` - Modal unificado criar/editar task (2 colunas)
- `EditStepModal.vue` - Modal para editar etapa
- `TemplateSelectionModal.vue` - Modal de seleção de template
- `BoardSettings.vue` - Página completa de configurações do board

### ✅ Componentes Atualizados
- `BoardView.vue` - Integração de modais, colunas colapsáveis, Spinner
- `Index.vue` - Template selection, Spinner
- `TaskCard.vue` - Cores padronizadas n-*, hover edit icon
- `BoardCard.vue` - Cores de avatar padronizadas n-*
- `CreateBoardModal.vue` - Usando Dialog component

---

## Checklist de Testes

### 1. Listagem de Boards (Index.vue)
- [ ] Página carrega com Spinner durante loading
- [ ] Empty state aparece quando não há boards
- [ ] Botão "Add Board" abre o TemplateSelectionModal
- [ ] BoardCards aparecem com cores padronizadas
- [ ] Click no card navega para BoardView

### 2. Seleção de Template (TemplateSelectionModal)
- [ ] Modal abre com largura adequada (não corta a tela)
- [ ] 4 templates aparecem em grid 2x2:
  - Empty (ícone clipboard)
  - Sales (ícone target)
  - Support (ícone headphones)
  - Recruitment (ícone users)
- [ ] Click em um template abre CreateBoardModal
- [ ] Botão "Cancelar" fecha o modal

### 3. Criar Board (CreateBoardModal)
- [ ] Campo "Board Name" é obrigatório
- [ ] Campo "Board Description" tem limite de 120 caracteres com contador
- [ ] Botão "Voltar" retorna ao TemplateSelectionModal
- [ ] Botão "Cancelar" fecha o modal
- [ ] Botão "Criar" cria o board e aplica template (se selecionado)
- [ ] Todos os botões em português

### 4. Visualização do Board (BoardView)
#### Header
- [ ] Título do board e contador de tasks aparecem
- [ ] Filtros de Agent e Inbox funcionam
- [ ] Botão Settings navega para BoardSettings
- [ ] Botão "Add Task" abre TaskModal em modo criar

#### Colunas (Steps)
- [ ] Cada step aparece com cor personalizada
- [ ] Header da coluna mostra: botão colapsar, nome, contador, settings, add task
- [ ] Click no ícone de colapsar (chevron-left) colapsa a coluna
- [ ] Coluna colapsada mostra:
  - Texto vertical com nome do step
  - Contador de tasks
  - Ícone chevron-right
- [ ] Click na coluna colapsada expande novamente
- [ ] Botão settings (gear) no header abre EditStepModal
- [ ] Botão + no header adiciona task naquele step

#### Tasks
- [ ] TaskCards aparecem com:
  - Título
  - Labels (máximo 2 visíveis + contador)
  - Avatares dos agentes
  - Data de vencimento
  - Indicador de prioridade (dot colorido)
  - Ícone de editar ao passar o mouse
- [ ] Click no card abre TaskModal em modo editar
- [ ] Drag & drop de tasks entre steps funciona
- [ ] Cores padronizadas (n-ruby-*, n-amber-*, n-blue-*, n-teal-*)

#### Add Step
- [ ] Botão "Add Step" no final abre CreateStepModal
- [ ] Step criado aparece no board

### 5. Criar Step (CreateStepModal)
- [ ] Campo "Step Name" é obrigatório
- [ ] Campo "Step Description" tem limite de 120 caracteres com contador
- [ ] Color picker permite selecionar cor
- [ ] Campo hex de cor sincroniza com color picker
- [ ] Botão "Cancelar" fecha o modal
- [ ] Botão "Criar" cria a etapa e atualiza o board
- [ ] Todos os botões em português

### 6. Editar Step (EditStepModal)
- [ ] Modal carrega com "Carregando..." enquanto busca dados
- [ ] ID do step aparece no header
- [ ] Campos preenchidos com dados atuais:
  - Nome
  - Descrição
  - Cor
- [ ] Botão "Excluir" abre DeleteConfirmDialog
- [ ] Botão "Cancelar" fecha o modal
- [ ] Botão "Atualizar" salva alterações
- [ ] Todos os botões em português

### 7. Criar/Editar Task (TaskModal)
#### Layout 2 Colunas
**Coluna Esquerda:**
- [ ] Campo "Task Title" é obrigatório
- [ ] Campo "Description" tem limite de 5000 caracteres com contador

**Coluna Direita:**
- [ ] Assign Agents: select + chips, pode adicionar/remover
- [ ] Labels: input com hint "Separe as etiquetas com vírgulas"
- [ ] Conversas: placeholder disabled (futuro)
- [ ] Contatos: placeholder disabled (futuro)
- [ ] Start Date: date picker
- [ ] Due Date: date picker

#### Footer
- [ ] Botão "Excluir" (só em modo editar, à esquerda)
- [ ] Step selector com indicador de cor
- [ ] Priority selector: Nenhuma, Baixa, Média, Alta, Urgente
- [ ] Botão "Cancelar" fecha o modal
- [ ] Botão "Criar" (modo criar) ou "Atualizar" (modo editar)
- [ ] Todos os botões em português

#### Funcionalidades
- [ ] Criar task: preenche campos, seleciona step/priority, salva
- [ ] Editar task: carrega dados, modifica, salva
- [ ] Excluir task: abre DeleteConfirmDialog, confirma, deleta
- [ ] ID do task aparece no header (modo editar)

### 8. Confirmação de Exclusão (DeleteConfirmDialog)
- [ ] Título customizado aparece
- [ ] Descrição customizada aparece
- [ ] Botão "Cancelar" fecha o diálogo
- [ ] Botão "Excluir" (vermelho) confirma exclusão
- [ ] Loading state durante exclusão
- [ ] Todos os botões em português

### 9. Configurações do Board (BoardSettings)
#### Header
- [ ] Botão voltar retorna ao BoardView
- [ ] Título "Board Settings" e nome do board aparecem
- [ ] ID do board aparece

#### Seção: Basic Information
- [ ] Campo "Board Name" editável
- [ ] Campo "Board Description" editável (limite 2000 caracteres)
- [ ] Botão "Salvar alterações" salva mudanças
- [ ] Loading state "Salvando..."

#### Seção: Steps
- [ ] Lista de steps com:
  - Drag handle (grip-vertical)
  - Indicador de cor
  - Nome
  - Contador de tasks
  - Botão editar (abre EditStepModal)
  - Botão excluir (abre DeleteConfirmDialog)
- [ ] Botão "Add Step" abre CreateStepModal
- [ ] Empty state quando não há steps

#### Seção: Assigned Agents
- [ ] Chips com agentes selecionados
- [ ] Pode remover agentes (X no chip)
- [ ] Select para adicionar novos agentes
- [ ] Botão "Atualizar" salva mudanças
- [ ] Loading state "Atualizando..."

#### Seção: Assigned Inboxes
- [ ] Chips com inboxes selecionadas
- [ ] Pode remover inboxes (X no chip)
- [ ] Select para adicionar novas inboxes
- [ ] Botão "Atualizar" salva mudanças
- [ ] Loading state "Atualizando..."

#### Seção: Automation
- [ ] 5 checkboxes para automações:
  1. Auto-create task for new conversations
  2. Sync task and conversation agents
  3. Auto-assign task to agent
  4. Auto-resolve conversation when task ends
  5. Auto-complete task when conversation resolves
- [ ] Botão "Salvar automação" salva mudanças
- [ ] Loading state "Salvando..."

#### Seção: Danger Zone
- [ ] Border vermelho ao redor
- [ ] Título "Danger Zone" em vermelho
- [ ] Warning text sobre exclusão permanente
- [ ] Botão vermelho "Delete Board"
- [ ] DeleteConfirmDialog confirma antes de excluir
- [ ] Após exclusão, redireciona para kanban_overview

---

## Design System

### Cores Padronizadas (n-*)
- **Slate**: Neutro geral (`n-slate-*`)
- **Blue**: Primary, steps, agents (`n-blue-*`)
- **Teal**: Success, inboxes (`n-teal-*`)
- **Amber**: Warning, high priority (`n-amber-*`)
- **Ruby**: Danger, urgent priority (`n-ruby-*`)
- **Violet, Pink, Iris**: Avatares (`n-violet-9`, `n-pink-9`, `n-iris-9`)

### Componentes Usados
- `Dialog` (components-next/dialog)
- `Button` (components-next/button)
- `Icon` (components-next/icon, ícones Lucide)
- `Spinner` (components-next/spinner)

---

## Rotas

| Nome | Path | Componente |
|------|------|------------|
| `kanban_overview` | `/accounts/:accountId/kanban` | Index.vue |
| `kanban_board_view` | `/accounts/:accountId/kanban/boards/:boardId` | BoardView.vue |
| `kanban_board_settings` | `/accounts/:accountId/kanban/boards/:boardId/settings` | BoardSettings.vue |

---

## Como Testar

1. **Inicie o servidor**:
   ```bash
   pnpm dev
   # ou
   overmind start -f Procfile.dev
   ```

2. **Navegue para Kanban**:
   - Login no Chatwoot
   - Acesse: `/app/accounts/{ACCOUNT_ID}/kanban`

3. **Fluxo de Teste Completo**:
   1. Criar board com template
   2. Adicionar steps manualmente
   3. Criar tasks em diferentes steps
   4. Mover tasks entre steps (drag & drop)
   5. Editar task (atribuir agentes, labels, prioridade)
   6. Colapsar/expandir colunas
   7. Acessar Settings
   8. Modificar automações
   9. Excluir task, step, board

4. **Verificar Traduções**:
   - Todos os botões devem estar em português
   - Não deve aparecer "GENERAL.CANCEL" ou "GENERAL.CREATE"
   - Loading states devem mostrar "Carregando...", "Salvando...", etc.

---

## Problemas Conhecidos Resolvidos

✅ **Botões mostrando chaves de tradução** - Resolvido usando labels em português direto
✅ **Diálogos não fechando** - Resolvido com Dialog component e métodos open/close
✅ **Template modal cortando a tela** - Resolvido mudando width de "2xl" para "xl"
✅ **Cores inconsistentes** - Resolvido padronizando para paleta n-*

---

## Arquivos Principais

### Criados
- `BoardSettings.vue` (669 linhas)
- `TaskModal.vue` (461 linhas)
- `CreateStepModal.vue` (162 linhas)
- `EditStepModal.vue` (236 linhas)
- `DeleteConfirmDialog.vue` (63 linhas)
- `TemplateSelectionModal.vue` (112 linhas)

### Modificados
- `BoardView.vue` - Integração de modais, colunas colapsáveis
- `Index.vue` - Template selection flow
- `TaskCard.vue` - Cores, hover edit
- `BoardCard.vue` - Cores
- `CreateBoardModal.vue` - Dialog component
- `kanban.routes.js` - Rota de settings

### Removidos
- `CreateTaskModal.vue` - Substituído por TaskModal.vue
- `StepColumn.vue` - Funcionalidade integrada em BoardView.vue

---

## Próximos Passos (Opcional)

- [ ] Adicionar traduções PT-BR completas em `pt-BR/kanban.json`
- [ ] Implementar drag & drop para reordenar steps
- [ ] Implementar funcionalidade de link com conversations/contacts
- [ ] Adicionar testes automatizados (RSpec + Jest)
- [ ] Implementar filtros avançados (por prioridade, data)
