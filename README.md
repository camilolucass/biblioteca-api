# Biblioteca API

API REST desenvolvida em Java com Spring Boot para gerenciamento de uma biblioteca. O sistema permite cadastrar livros, consultar disponibilidade, realizar emprestimos e registrar devolucoes, usando PostgreSQL e regras de negocio na camada de service.

## Tecnologias

- Java 17+
- Spring Boot
- Spring Web
- Spring Data JPA
- Bean Validation
- PostgreSQL
- Maven Wrapper
- Docker Compose
- Lombok
- Swagger/OpenAPI
- JUnit 5 e Mockito

## Funcionalidades

- Cadastro, listagem, busca, atualizacao e remocao de livros.
- Consulta de disponibilidade de livro.
- Realizacao de emprestimo apenas para livros disponiveis.
- Registro de devolucao com atualizacao do status do livro.
- Listagem de emprestimos ativos e atrasados.
- Validacao de ISBN unico.
- Tratamento global de erros.
- Documentacao Swagger.

## Como rodar

Suba o PostgreSQL:

```bash
docker compose up -d
```

Execute a aplicacao no Windows:

```bash
.\mvnw.cmd spring-boot:run
```

Execute a aplicacao no Linux ou macOS:

```bash
./mvnw spring-boot:run
```

A API ficara disponivel em:

```text
http://localhost:8080
```

A documentacao Swagger ficara em:

```text
http://localhost:8080/swagger-ui.html
```

## Configuracao do banco

O arquivo `docker-compose.yml` sobe um PostgreSQL local com:

```text
database: biblioteca_db
user: biblioteca_user
password: biblioteca_pass
port: 5432
```

O Spring usa `spring.jpa.hibernate.ddl-auto=update` para criar e atualizar as tabelas durante o desenvolvimento local.

## Endpoints

### Livros

```http
POST /api/livros
GET /api/livros
GET /api/livros/{id}
GET /api/livros/{id}/disponibilidade
PUT /api/livros/{id}
DELETE /api/livros/{id}
```

Exemplo de cadastro:

```json
{
  "titulo": "Clean Code",
  "autor": "Robert C. Martin",
  "isbn": "9780132350884",
  "anoPublicacao": 2008,
  "categoria": "Programacao"
}
```

### Emprestimos

```http
POST /api/emprestimos
GET /api/emprestimos
GET /api/emprestimos/{id}
GET /api/emprestimos/ativos
GET /api/emprestimos/atrasados
PUT /api/emprestimos/{id}/devolucao
```

Exemplo de emprestimo:

```json
{
  "livroId": 1,
  "nomeUsuario": "Lucas Camilo",
  "emailUsuario": "lucas@email.com"
}
```

## Regras de negocio

- Um livro novo entra com status `DISPONIVEL`.
- O ISBN deve ser unico.
- O ano de publicacao nao pode ser maior que o ano atual.
- Um livro so pode ser emprestado se estiver `DISPONIVEL`.
- Ao emprestar, o livro muda para `EMPRESTADO`.
- A devolucao prevista e gerada automaticamente para 7 dias apos o emprestimo.
- Ao devolver, o emprestimo muda para `FINALIZADO` e o livro volta para `DISPONIVEL`.
- Nao e possivel devolver um emprestimo ja finalizado.
- Nao e possivel excluir um livro emprestado.
- Emprestimos ativos com data prevista anterior a data atual sao tratados como `ATRASADO` nas respostas.

## Testes

Execute:

```bash
.\mvnw.cmd test
```

Os testes unitarios cobrem as principais regras de emprestimo, devolucao e ISBN duplicado.

## Melhorias futuras

- Adicionar autenticacao.
- Criar filtros de busca por autor, categoria e status.
- Adicionar paginacao.
- Criar migracoes com Flyway ou Liquibase.
- Criar testes de integracao com Testcontainers.
