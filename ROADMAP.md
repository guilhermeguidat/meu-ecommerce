# 🗺️ Roadmap do Projeto Meu E-commerce (Foco Frontend)

Este roadmap define as etapas de desenvolvimento do frontend (Flutter Web) do nosso aplicativo de e-commerce white-label, baseado nas diretrizes de design Apple-inspired (minimalista, moderno, bordas arredondadas 20px, tipografia clara). 

O foco principal do desenvolvimento é a interface (UI/UX) e integração via chamadas à API, mantendo o back-end inalterado, a não ser que uma tela demande estritamente um novo endpoint ou dado.

---

## 🟢 Fase 1: Onboarding & Autenticação (Em Andamento)

**Status Geral:** Quase Concluída.

- [x] **Setup Inicial Frontend:** Configuração do projeto Flutter Web, injeção de dependências (get_it), temas globais (Design System).
- [x] **Tela de Login:** Interface minimalista, opções de acesso, integração com backend.
- [x] **Tela de Registro:** Fluxo de criação de conta com tratamento de CORS e erros (ex: 409 Conflict).
- [ ] **Fluxo "Esqueci Minha Senha":** Tela para solicitação de redefinição de senha e fluxo de recuperação.

---

## 🔴 Fase 2: Experiência do Cliente (Storefront)

**Status Geral:** A iniciar (Aguardando Fase 5).

- [ ] **Home Screen (Tela Inicial):**
  - Header moderno com área para logo customizável (White-Label).
  - Carrossel de banners em destaque.
  - Lista horizontal de categorias.
  - Grid de produtos em destaque/tendência.
- [ ] **Busca & Descoberta:**
  - Barra de busca avançada.
  - Histórico de "Buscas Recentes".
- [ ] **Modal/BottomSheet de Filtros:**
  - Design limpo (Clean Bottom-Sheet).
  - Slider de faixa de preço.
  - Seleção de Categorias e opções de ordenação (Sort by).
- [ ] **Detalhes do Produto:**
  - Hero image (imagem principal grande).
  - Botão estático e persistente de "Adicionar ao Carrinho" na parte inferior.
  - Descrição expansível.
  - Sessão de produtos relacionados.

---

## 🔴 Fase 3: Carrinho e Checkout

**Status Geral:** A iniciar.

- [ ] **Carrinho de Compras:** 
  - Listagem de itens com botões de controle de quantidade (+/-).
  - Resumo de valores (subtotal, frete, total).
- [ ] **Fluxo de Checkout (Etapas):**
  1. Seleção de Endereço de Entrega.
  2. Escolha do Método de Pagamento.
  3. Revisão do Pedido (Resumo final).
  4. Tela de Sucesso / "Obrigado pela sua compra".

---

## 🔴 Fase 4: Perfil do Usuário

**Status Geral:** A iniciar.

- [ ] **Dashboard do Usuário:** 
  - Status e histórico de pedidos recentes.
- [ ] **Configurações "Minha Conta":**
  - Gerenciamento de endereços salvos.
  - Gerenciamento de métodos de pagamento.
  - Edição de dados pessoais.

---

## 🟡 Fase 5: Dashboard Admin/Lojista (Visão Mobile/Web) - (Prioridade Atual)

**Status Geral:** Em Andamento.

- [ ] **Dashboard Principal:** 
  - Gráficos de vendas (gráficos de linha com design minimalista).
  - Resumo financeiro e métricas de desempenho.
- [ ] **Gerenciamento de Produtos:**
  - Visualização em lista dos produtos cadastrados.
  - Ações de editar e excluir (Edit/Delete).
- [ ] **Configurações da Loja (Store Settings):**
  - Tela para upload/alteração de Logo.
  - Escolha da Cor Primária da marca (Demonstração da funcionalidade White-Label).

---

## 🛠️ Notas Arquiteturais e de Design
- **Design System:** Todos os novos componentes devem utilizar as cores neutras (branco, tons de cinza) e aplicar a "Cor Primária da Marca" (Brand Color) nos botões Call-to-Action.
- **Clean Architecture:** As novas features devem continuar seguindo a estrutura rigorosa de `data` (models, repositories), `domain` (se necessário), `presentation` (pages, widgets, providers).
- **Backend:** Alterações no Spring Boot apenas se a feature do frontend estiver bloqueada pela ausência de um serviço, endpoint, campo no DTO, ou se um erro lógico impedir a continuação.
