# Backend E-commerce

Este é o backend do nosso sistema de e-commerce, desenvolvido com uma arquitetura de microserviços.

## 🚀 Inicialização da Infraestrutura Local

Nossa infraestrutura depende de alguns containers Docker (Banco de dados, Broker de mensageria e Bucket). 
Em vez de utilizar scripts que variam por sistema operacional, você pode gerenciar os serviços rodando os comandos abaixo na pasta raiz do `backend`.

### Subir os serviços (Up)

```bash
docker compose -p ecommerce-local -f servicos/database/docker-compose.yml up -d
docker compose -p ecommerce-local -f servicos/broker/docker-compose.yml up -d
docker compose -p ecommerce-local -f servicos/bucket/docker-compose.yml up -d
```

### Configurar Banco de Dados (Schema)

Após o banco de dados estar rodando, injete as tabelas padrão:

**No Windows (PowerShell):**
```powershell
Get-Content .\servicos\database\schema.sql | docker exec -i db_ecommerce psql -U postgres
```

**No Linux/Mac/Git Bash:**
```bash
docker exec -i db_ecommerce psql -U postgres < ./servicos/database/schema.sql
```

### Derrubar os serviços (Down)

```bash
docker compose -p ecommerce-local -f servicos/database/docker-compose.yml down
docker compose -p ecommerce-local -f servicos/broker/docker-compose.yml down
docker compose -p ecommerce-local -f servicos/bucket/docker-compose.yml down
```
