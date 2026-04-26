# 🛍️ Meu E-commerce

Bem-vindo ao repositório principal do nosso projeto de E-commerce! 

Este projeto está estruturado usando o formato **Monorepo**, trazendo o benefício de ter o cliente (Frontend) e a API de microserviços (Backend) gerenciados em um mesmo local. Isso facilita bastante o versionamento e a colaboração em equipe.

## 🗂️ Estrutura do Projeto

Nossa arquitetura está separada nas seguintes pastas:

* 🎨 **[Frontend (`/frontend`)](./frontend)**
  A interface do usuário será construída utilizando **Flutter Web**. Toda a configuração da interface, telas e integração com a API ficará neste diretório.

* ⚙️ **[Backend (`/backend`)](./backend)**
  A nossa infraestrutura da API, construída com arquitetura de **Microserviços em Java**. Integra ferramentas como banco de dados Postgres, Kafka e MinIO (tudo rodando via Docker).

---

## 🚀 Por onde começar?

Para rodar o projeto localmente em sua máquina, recomendamos começar montando a infraestrutura que dará suporte aos dados da aplicação:

👉 **[Veja o guia de inicialização do Backend aqui](./backend/README.md)**

*(A documentação de como rodar as telas do frontend será adicionada em breve na pasta `/frontend/README.md` quando o desenvolvimento Flutter iniciar).*
