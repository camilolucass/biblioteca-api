param(
    [string]$ProjetoRaiz = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

function HtmlEncode {
    param([AllowNull()][string]$Text)
    if ($null -eq $Text) { return '' }
    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Read-ProjectFile {
    param([string]$RelativePath)

    $fullPath = Join-Path $ProjetoRaiz $RelativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        return "// Arquivo nao encontrado: $RelativePath"
    }

    return Get-Content -LiteralPath $fullPath -Raw -Encoding UTF8
}

function CodeBlock {
    param(
        [string]$Title,
        [string]$RelativePath,
        [string]$Language = 'java',
        [string]$Explanation = ''
    )

    $code = Read-ProjectFile $RelativePath
    $encoded = HtmlEncode $code
    $encodedPath = HtmlEncode $RelativePath
    $encodedTitle = HtmlEncode $Title
    $encodedExplanation = HtmlEncode $Explanation

    return @"
<section class="code-section">
  <h3>$encodedTitle</h3>
  <p class="file-path">$encodedPath</p>
  <p>$encodedExplanation</p>
  <pre><code class="language-$Language">$encoded</code></pre>
</section>
"@
}

$outputHtml = Join-Path $PSScriptRoot 'material-estudo-biblioteca-api.html'
$outputPdf = Join-Path $PSScriptRoot 'material-estudo-biblioteca-api.pdf'
$generatedAt = Get-Date -Format 'dd/MM/yyyy HH:mm'

$codeSections = New-Object System.Collections.Generic.List[string]

$codeSections.Add((CodeBlock 'Maven e dependencias' 'pom.xml' 'xml' 'Define o projeto Maven, a versao do Java, Spring Boot e bibliotecas usadas: Web, JPA, Validation, PostgreSQL, H2, Lombok, Swagger e testes.'))
$codeSections.Add((CodeBlock 'Docker Compose do PostgreSQL' 'docker-compose.yml' 'yaml' 'Cria um container PostgreSQL local com banco, usuario, senha, porta e volume persistente.'))
$codeSections.Add((CodeBlock 'Configuracao principal com PostgreSQL' 'src/main/resources/application.properties' 'properties' 'Configuracao padrao da API para conectar no PostgreSQL que sobe pelo Docker Compose.'))
$codeSections.Add((CodeBlock 'Perfil local com H2' 'src/main/resources/application-local.properties' 'properties' 'Configuracao alternativa para rodar sem Docker, usando banco H2 em memoria.'))
$codeSections.Add((CodeBlock 'Classe principal Spring Boot' 'src/main/java/com/lucas/bibliotecaapi/BibliotecaApiApplication.java' 'java' 'Ponto de entrada da aplicacao. A anotacao @SpringBootApplication habilita a configuracao automatica e o scan de componentes.'))
$codeSections.Add((CodeBlock 'Enum StatusLivro' 'src/main/java/com/lucas/bibliotecaapi/enums/StatusLivro.java' 'java' 'Lista os estados possiveis de um livro no sistema.'))
$codeSections.Add((CodeBlock 'Enum StatusEmprestimo' 'src/main/java/com/lucas/bibliotecaapi/enums/StatusEmprestimo.java' 'java' 'Lista os estados possiveis de um emprestimo.'))
$codeSections.Add((CodeBlock 'Entidade Livro' 'src/main/java/com/lucas/bibliotecaapi/model/Livro.java' 'java' 'Representa a tabela livros. Usa JPA para mapear campos Java para colunas no banco.'))
$codeSections.Add((CodeBlock 'Entidade Emprestimo' 'src/main/java/com/lucas/bibliotecaapi/model/Emprestimo.java' 'java' 'Representa a tabela emprestimos. O @ManyToOne cria a relacao entre emprestimo e livro.'))
$codeSections.Add((CodeBlock 'DTO LivroRequestDTO' 'src/main/java/com/lucas/bibliotecaapi/dto/LivroRequestDTO.java' 'java' 'DTO de entrada para cadastrar ou atualizar livro. Tambem contem validacoes de campos obrigatorios.'))
$codeSections.Add((CodeBlock 'DTO LivroResponseDTO' 'src/main/java/com/lucas/bibliotecaapi/dto/LivroResponseDTO.java' 'java' 'DTO de saida para devolver livro ao cliente da API sem expor diretamente a entidade JPA.'))
$codeSections.Add((CodeBlock 'DTO DisponibilidadeLivroDTO' 'src/main/java/com/lucas/bibliotecaapi/dto/DisponibilidadeLivroDTO.java' 'java' 'DTO especifico para a consulta de disponibilidade do livro.'))
$codeSections.Add((CodeBlock 'DTO EmprestimoRequestDTO' 'src/main/java/com/lucas/bibliotecaapi/dto/EmprestimoRequestDTO.java' 'java' 'DTO de entrada para realizar um emprestimo.'))
$codeSections.Add((CodeBlock 'DTO EmprestimoResponseDTO' 'src/main/java/com/lucas/bibliotecaapi/dto/EmprestimoResponseDTO.java' 'java' 'DTO de saida com dados do emprestimo, livro, datas e status.'))
$codeSections.Add((CodeBlock 'Repository de Livro' 'src/main/java/com/lucas/bibliotecaapi/repository/LivroRepository.java' 'java' 'Interface Spring Data JPA que fornece CRUD e consultas por ISBN.'))
$codeSections.Add((CodeBlock 'Repository de Emprestimo' 'src/main/java/com/lucas/bibliotecaapi/repository/EmprestimoRepository.java' 'java' 'Interface Spring Data JPA que busca emprestimos por status e atrasados.'))
$codeSections.Add((CodeBlock 'Service de Livro' 'src/main/java/com/lucas/bibliotecaapi/service/LivroService.java' 'java' 'Camada onde ficam as regras de negocio de livros: ISBN unico, ano valido, disponibilidade e remocao.'))
$codeSections.Add((CodeBlock 'Service de Emprestimo' 'src/main/java/com/lucas/bibliotecaapi/service/EmprestimoService.java' 'java' 'Camada onde ficam as regras de emprestimo e devolucao. E o coracao do fluxo da biblioteca.'))
$codeSections.Add((CodeBlock 'Controller de Livro' 'src/main/java/com/lucas/bibliotecaapi/controller/LivroController.java' 'java' 'Exponibiliza os endpoints REST de livros. Recebe DTOs e chama o service.'))
$codeSections.Add((CodeBlock 'Controller de Emprestimo' 'src/main/java/com/lucas/bibliotecaapi/controller/EmprestimoController.java' 'java' 'Exponibiliza os endpoints REST de emprestimos e devolucoes.'))
$codeSections.Add((CodeBlock 'Resposta padrao de erro' 'src/main/java/com/lucas/bibliotecaapi/exception/ApiErrorResponse.java' 'java' 'Formato padrao para mensagens de erro retornadas pela API.'))
$codeSections.Add((CodeBlock 'Erro de recurso nao encontrado' 'src/main/java/com/lucas/bibliotecaapi/exception/RecursoNaoEncontradoException.java' 'java' 'Excecao usada quando livro ou emprestimo nao existe.'))
$codeSections.Add((CodeBlock 'Erro de regra de negocio' 'src/main/java/com/lucas/bibliotecaapi/exception/RegraNegocioException.java' 'java' 'Excecao usada quando uma regra de negocio e violada.'))
$codeSections.Add((CodeBlock 'Tratamento global de erros' 'src/main/java/com/lucas/bibliotecaapi/exception/GlobalExceptionHandler.java' 'java' 'Centraliza a traducao de excecoes Java para respostas HTTP organizadas.'))
$codeSections.Add((CodeBlock 'Teste da aplicacao' 'src/test/java/com/lucas/bibliotecaapi/BibliotecaApiApplicationTests.java' 'java' 'Teste simples para manter a classe principal coberta sem exigir banco real.'))
$codeSections.Add((CodeBlock 'Testes do LivroService' 'src/test/java/com/lucas/bibliotecaapi/service/LivroServiceTest.java' 'java' 'Teste unitario da regra de ISBN duplicado.'))
$codeSections.Add((CodeBlock 'Testes do EmprestimoService' 'src/test/java/com/lucas/bibliotecaapi/service/EmprestimoServiceTest.java' 'java' 'Testes unitarios das principais regras de emprestimo e devolucao.'))
$codeSections.Add((CodeBlock 'Gitignore' '.gitignore' 'text' 'Evita versionar arquivos gerados, build, IDE e logs locais.'))

$allCode = $codeSections -join "`n"

$html = @"
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8" />
  <title>Material de Estudo - Biblioteca API</title>
  <style>
    @page {
      size: A4;
      margin: 16mm 13mm;
    }

    * {
      box-sizing: border-box;
    }

    body {
      font-family: "Segoe UI", Arial, sans-serif;
      color: #172033;
      background: #ffffff;
      line-height: 1.45;
      font-size: 12.2px;
      margin: 0;
    }

    h1, h2, h3 {
      color: #0f172a;
      page-break-after: avoid;
    }

    h1 {
      font-size: 30px;
      margin: 0 0 10px;
    }

    h2 {
      font-size: 20px;
      margin: 30px 0 10px;
      border-bottom: 2px solid #dbe4f0;
      padding-bottom: 5px;
    }

    h3 {
      font-size: 15px;
      margin: 20px 0 6px;
    }

    p {
      margin: 7px 0;
    }

    ul, ol {
      margin-top: 6px;
      padding-left: 22px;
    }

    li {
      margin: 4px 0;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin: 10px 0 18px;
      page-break-inside: avoid;
    }

    th, td {
      border: 1px solid #cbd5e1;
      padding: 6px 7px;
      vertical-align: top;
    }

    th {
      background: #eef2f7;
      text-align: left;
    }

    code {
      font-family: Consolas, "Courier New", monospace;
      font-size: 10.2px;
    }

    pre {
      background: #0f172a;
      color: #e2e8f0;
      border-radius: 6px;
      padding: 10px;
      overflow-wrap: anywhere;
      white-space: pre-wrap;
      line-height: 1.35;
      page-break-inside: auto;
      border: 1px solid #1e293b;
    }

    pre code {
      color: inherit;
    }

    .cover {
      min-height: 760px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      page-break-after: always;
      border-left: 8px solid #2563eb;
      padding-left: 24px;
    }

    .subtitle {
      font-size: 16px;
      color: #475569;
      max-width: 640px;
    }

    .meta {
      margin-top: 22px;
      color: #64748b;
    }

    .toc {
      page-break-after: always;
    }

    .callout {
      border-left: 4px solid #2563eb;
      background: #eff6ff;
      padding: 10px 12px;
      margin: 12px 0;
    }

    .warning {
      border-left-color: #f59e0b;
      background: #fffbeb;
    }

    .success {
      border-left-color: #16a34a;
      background: #f0fdf4;
    }

    .diagram {
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 8px;
      margin: 14px 0 18px;
      page-break-inside: avoid;
    }

    .box {
      border: 1px solid #94a3b8;
      border-radius: 6px;
      padding: 9px;
      text-align: center;
      background: #f8fafc;
      font-weight: 600;
    }

    .arrow {
      font-weight: 700;
      color: #2563eb;
    }

    .file-path {
      color: #475569;
      font-family: Consolas, "Courier New", monospace;
      font-size: 10.5px;
      margin-top: 0;
    }

    .code-section {
      page-break-before: auto;
      margin-bottom: 22px;
    }

    .page-break {
      page-break-before: always;
    }

    .small {
      color: #64748b;
      font-size: 11px;
    }
  </style>
</head>
<body>
  <section class="cover">
    <h1>Material de Estudo<br>Biblioteca API</h1>
    <p class="subtitle">Guia completo para entender, explicar, pesquisar e replicar a API REST de gerenciamento de biblioteca feita em Java, Spring Boot, PostgreSQL, Docker, JPA, DTOs, validações, Swagger e testes.</p>
    <p class="meta">Gerado em $generatedAt<br>Projeto: biblioteca-api<br>Autor do repositório: camilolucass</p>
  </section>

  <section class="toc">
    <h2>Sumario</h2>
    <ol>
      <li>Visao geral do projeto</li>
      <li>Conceitos fundamentais</li>
      <li>Arquitetura em camadas</li>
      <li>Fluxos principais</li>
      <li>Banco de dados e conexoes</li>
      <li>Endpoints REST</li>
      <li>Como rodar, testar e parar</li>
      <li>Como estudar e replicar</li>
      <li>Codigo completo comentado por arquivo</li>
    </ol>
  </section>

  <section>
    <h2>1. Visao Geral Do Projeto</h2>
    <p>A <strong>Biblioteca API</strong> e uma API REST backend para gerenciar livros e emprestimos. Ela permite cadastrar livros, consultar disponibilidade, realizar emprestimos e registrar devolucoes.</p>

    <div class="callout success">
      <strong>Resultado pratico:</strong> o projeto mostra habilidades de backend reais: Java, Spring Boot, API REST, banco relacional, JPA/Hibernate, validacao, tratamento de erros, Docker, Swagger, testes unitarios e Git/GitHub.
    </div>

    <h3>Principais funcionalidades</h3>
    <ul>
      <li>Cadastrar, listar, buscar, atualizar e remover livros.</li>
      <li>Consultar se um livro esta disponivel para emprestimo.</li>
      <li>Realizar emprestimo de livro disponivel.</li>
      <li>Registrar devolucao de livro emprestado.</li>
      <li>Listar emprestimos ativos e atrasados.</li>
      <li>Bloquear ISBN duplicado.</li>
      <li>Bloquear exclusao de livro emprestado.</li>
      <li>Responder erros em formato padronizado.</li>
    </ul>

    <h3>Tecnologias usadas</h3>
    <table>
      <tr><th>Tecnologia</th><th>Uso no projeto</th><th>O que pesquisar</th></tr>
      <tr><td>Java 17+</td><td>Linguagem principal.</td><td>POO, record, enum, Optional, LocalDate.</td></tr>
      <tr><td>Spring Boot</td><td>Framework para criar a API rapidamente.</td><td>@SpringBootApplication, IoC, auto configuration.</td></tr>
      <tr><td>Spring Web</td><td>Controllers e endpoints HTTP.</td><td>@RestController, @GetMapping, @PostMapping.</td></tr>
      <tr><td>Spring Data JPA</td><td>Acesso ao banco com repositories.</td><td>JpaRepository, query methods, @Query.</td></tr>
      <tr><td>Hibernate</td><td>Implementacao JPA que mapeia objetos para tabelas.</td><td>ORM, Entity, relacionamento ManyToOne.</td></tr>
      <tr><td>Bean Validation</td><td>Validacao dos DTOs de entrada.</td><td>@NotBlank, @NotNull, @Email, @Valid.</td></tr>
      <tr><td>PostgreSQL</td><td>Banco principal do projeto.</td><td>Banco relacional, tabelas, chaves estrangeiras.</td></tr>
      <tr><td>Docker Compose</td><td>Sobe o PostgreSQL localmente.</td><td>containers, volumes, portas, services.</td></tr>
      <tr><td>H2</td><td>Banco opcional em memoria para rodar sem Docker.</td><td>profiles do Spring, banco em memoria.</td></tr>
      <tr><td>Swagger/OpenAPI</td><td>Documentacao interativa da API.</td><td>springdoc-openapi, swagger-ui.</td></tr>
      <tr><td>JUnit e Mockito</td><td>Testes unitarios das regras de negocio.</td><td>@Mock, @InjectMocks, asserts.</td></tr>
    </table>
  </section>

  <section>
    <h2>2. Conceitos Fundamentais</h2>

    <h3>API REST</h3>
    <p>Uma API REST permite que outros clientes, como navegador, Postman, frontend ou app mobile, conversem com o backend usando HTTP. Cada rota representa uma acao ou recurso.</p>
    <ul>
      <li><strong>GET</strong>: buscar informacoes.</li>
      <li><strong>POST</strong>: criar um recurso novo.</li>
      <li><strong>PUT</strong>: atualizar ou executar uma alteracao importante.</li>
      <li><strong>DELETE</strong>: remover um recurso.</li>
    </ul>

    <h3>JSON</h3>
    <p>JSON e o formato usado para enviar e receber dados na API. Exemplo de livro:</p>
    <pre><code>{
  "titulo": "Clean Code",
  "autor": "Robert C. Martin",
  "isbn": "9780132350884",
  "anoPublicacao": 2008,
  "categoria": "Programacao"
}</code></pre>

    <h3>JPA, Hibernate e ORM</h3>
    <p>JPA e uma especificacao Java para persistir objetos em banco de dados. Hibernate e a implementacao usada pelo Spring Boot. ORM significa Object-Relational Mapping: classes Java viram tabelas, atributos viram colunas e objetos viram registros.</p>

    <h3>DTO</h3>
    <p>DTO significa Data Transfer Object. Ele separa o modelo interno do banco da entrada e saida da API. Isso evita expor a entidade JPA diretamente e permite controlar melhor validacoes e respostas.</p>

    <h3>Service Layer</h3>
    <p>A camada service guarda as regras de negocio. Controller nao deve decidir se um livro pode ser emprestado; quem decide isso e o service.</p>

    <h3>Repository</h3>
    <p>Repository conversa com o banco. Ao estender <code>JpaRepository</code>, o Spring ja entrega metodos como <code>save</code>, <code>findById</code>, <code>findAll</code> e <code>delete</code>.</p>

    <h3>Injecao de Dependencia</h3>
    <p>O Spring cria e injeta objetos automaticamente. Por exemplo, o controller recebe o service no construtor; o service recebe repositories. Isso reduz acoplamento e facilita testes.</p>
  </section>

  <section>
    <h2>3. Arquitetura Em Camadas</h2>
    <p>O projeto foi dividido em pacotes com responsabilidades claras.</p>

    <div class="diagram">
      <div class="box">Cliente<br><span class="small">Swagger/Postman</span></div>
      <div class="box">Controller<br><span class="small">HTTP</span></div>
      <div class="box">Service<br><span class="small">Regras</span></div>
      <div class="box">Repository<br><span class="small">JPA</span></div>
      <div class="box">Banco<br><span class="small">PostgreSQL</span></div>
    </div>

    <table>
      <tr><th>Pacote</th><th>Responsabilidade</th><th>Exemplo</th></tr>
      <tr><td>controller</td><td>Receber requisicoes HTTP e devolver respostas.</td><td>LivroController</td></tr>
      <tr><td>service</td><td>Aplicar regras de negocio.</td><td>EmprestimoService</td></tr>
      <tr><td>repository</td><td>Acessar o banco de dados.</td><td>LivroRepository</td></tr>
      <tr><td>model</td><td>Representar tabelas JPA.</td><td>Livro, Emprestimo</td></tr>
      <tr><td>dto</td><td>Representar entrada e saida da API.</td><td>LivroRequestDTO</td></tr>
      <tr><td>enums</td><td>Guardar valores fixos de status.</td><td>StatusLivro</td></tr>
      <tr><td>exception</td><td>Padronizar erros.</td><td>GlobalExceptionHandler</td></tr>
    </table>

    <div class="callout">
      <strong>Regra de ouro:</strong> controller nao deve conter regra de negocio; repository nao deve conter regra de negocio; entidade nao deve ser exposta diretamente como contrato da API. O service coordena a regra.
    </div>
  </section>

  <section>
    <h2>4. Fluxos Principais</h2>

    <h3>Fluxo de cadastro de livro</h3>
    <ol>
      <li>Cliente envia <code>POST /api/livros</code> com JSON.</li>
      <li><code>LivroController</code> recebe <code>LivroRequestDTO</code>.</li>
      <li>Bean Validation valida titulo, autor e ISBN.</li>
      <li><code>LivroService</code> verifica ano de publicacao e ISBN duplicado.</li>
      <li>Service cria entidade <code>Livro</code> com status <code>DISPONIVEL</code>.</li>
      <li><code>LivroRepository</code> salva no PostgreSQL.</li>
      <li>API retorna <code>LivroResponseDTO</code>.</li>
    </ol>

    <h3>Fluxo de emprestimo</h3>
    <ol>
      <li>Cliente envia <code>POST /api/emprestimos</code> com <code>livroId</code>, nome e email.</li>
      <li><code>EmprestimoService</code> busca o livro.</li>
      <li>Se o livro nao existir, retorna 404.</li>
      <li>Se o livro nao estiver <code>DISPONIVEL</code>, retorna erro de regra.</li>
      <li>Cria emprestimo com status <code>ATIVO</code>.</li>
      <li>Define devolucao prevista para 7 dias depois.</li>
      <li>Muda o livro para <code>EMPRESTADO</code>.</li>
      <li>Salva o emprestimo.</li>
    </ol>

    <h3>Fluxo de devolucao</h3>
    <ol>
      <li>Cliente envia <code>PUT /api/emprestimos/{id}/devolucao</code>.</li>
      <li>Service busca o emprestimo.</li>
      <li>Se ja estiver finalizado, bloqueia.</li>
      <li>Confere se o livro esta emprestado.</li>
      <li>Preenche <code>dataDevolucao</code> com a data atual.</li>
      <li>Muda o emprestimo para <code>FINALIZADO</code>.</li>
      <li>Muda o livro para <code>DISPONIVEL</code>.</li>
    </ol>
  </section>

  <section>
    <h2>5. Banco De Dados E Conexoes</h2>

    <h3>PostgreSQL via Docker</h3>
    <p>O arquivo <code>docker-compose.yml</code> cria um container PostgreSQL com os dados abaixo:</p>
    <table>
      <tr><th>Item</th><th>Valor</th></tr>
      <tr><td>Banco</td><td>biblioteca_db</td></tr>
      <tr><td>Usuario</td><td>biblioteca_user</td></tr>
      <tr><td>Senha</td><td>biblioteca_pass</td></tr>
      <tr><td>Porta local</td><td>5432</td></tr>
      <tr><td>URL JDBC</td><td>jdbc:postgresql://localhost:5432/biblioteca_db</td></tr>
    </table>

    <h3>Conexao da aplicacao</h3>
    <p>A aplicacao usa o arquivo <code>application.properties</code> para conectar no PostgreSQL. A propriedade <code>spring.jpa.hibernate.ddl-auto=update</code> permite que o Hibernate crie/atualize as tabelas durante o desenvolvimento.</p>

    <h3>H2 opcional</h3>
    <p>O perfil <code>local</code> usa H2 em memoria. Ele serve para estudar e rodar rapido sem Docker, mas o caminho principal do projeto continua sendo PostgreSQL.</p>

    <div class="callout warning">
      <strong>Importante:</strong> banco H2 em memoria perde os dados ao parar a aplicacao. O PostgreSQL com volume Docker preserva dados enquanto o volume existir.
    </div>
  </section>

  <section>
    <h2>6. Endpoints REST</h2>

    <h3>Livros</h3>
    <table>
      <tr><th>Metodo</th><th>Rota</th><th>Uso</th></tr>
      <tr><td>POST</td><td>/api/livros</td><td>Cadastrar livro.</td></tr>
      <tr><td>GET</td><td>/api/livros</td><td>Listar todos os livros.</td></tr>
      <tr><td>GET</td><td>/api/livros/{id}</td><td>Buscar livro por ID.</td></tr>
      <tr><td>GET</td><td>/api/livros/{id}/disponibilidade</td><td>Consultar disponibilidade.</td></tr>
      <tr><td>PUT</td><td>/api/livros/{id}</td><td>Atualizar livro.</td></tr>
      <tr><td>DELETE</td><td>/api/livros/{id}</td><td>Remover livro, se nao estiver emprestado.</td></tr>
    </table>

    <h3>Emprestimos</h3>
    <table>
      <tr><th>Metodo</th><th>Rota</th><th>Uso</th></tr>
      <tr><td>POST</td><td>/api/emprestimos</td><td>Realizar emprestimo.</td></tr>
      <tr><td>GET</td><td>/api/emprestimos</td><td>Listar emprestimos.</td></tr>
      <tr><td>GET</td><td>/api/emprestimos/{id}</td><td>Buscar emprestimo por ID.</td></tr>
      <tr><td>GET</td><td>/api/emprestimos/ativos</td><td>Listar emprestimos ativos.</td></tr>
      <tr><td>GET</td><td>/api/emprestimos/atrasados</td><td>Listar emprestimos atrasados.</td></tr>
      <tr><td>PUT</td><td>/api/emprestimos/{id}/devolucao</td><td>Registrar devolucao.</td></tr>
    </table>
  </section>

  <section>
    <h2>7. Como Rodar, Testar E Parar</h2>

    <h3>Rodar com Docker e PostgreSQL</h3>
    <pre><code>cd "C:\Users\Lucas\Documents\New project\biblioteca-api"
docker compose up -d
.\mvnw.cmd spring-boot:run</code></pre>

    <h3>Acessar Swagger</h3>
    <pre><code>http://localhost:8080/swagger-ui.html</code></pre>

    <h3>Parar tudo</h3>
    <pre><code>cd "C:\Users\Lucas\Documents\New project\biblioteca-api"
docker compose down</code></pre>

    <h3>Rodar testes</h3>
    <pre><code>.\mvnw.cmd test</code></pre>

    <h3>Rodar sem Docker, com H2</h3>
    <pre><code>.\mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=local</code></pre>

    <h3>Console H2</h3>
    <pre><code>URL: http://localhost:8080/h2-console
JDBC URL: jdbc:h2:mem:biblioteca_db
User: sa
Password: deixe em branco</code></pre>
  </section>

  <section>
    <h2>8. Como Estudar E Replicar</h2>

    <h3>Ordem recomendada de estudo</h3>
    <ol>
      <li>Java basico: classes, objetos, metodos, construtores, enums, records.</li>
      <li>HTTP e REST: metodos, status codes, JSON.</li>
      <li>Spring Boot: controllers, services, repositories e injecao de dependencia.</li>
      <li>JPA/Hibernate: entity, id, coluna, relacionamento, repository.</li>
      <li>Banco relacional: tabelas, chaves primarias, chaves estrangeiras.</li>
      <li>DTO e validacao: separar entrada/saida da entidade.</li>
      <li>Tratamento de erros: exceptions e RestControllerAdvice.</li>
      <li>Docker: container, imagem, volume, porta, compose.</li>
      <li>Testes: JUnit, Mockito, mock, assert.</li>
      <li>Git/GitHub: init, add, commit, push e README.</li>
    </ol>

    <h3>Ordem para refazer o projeto do zero</h3>
    <ol>
      <li>Criar projeto no Spring Initializr.</li>
      <li>Adicionar dependencias Web, JPA, Validation, PostgreSQL, Lombok, Swagger e Test.</li>
      <li>Criar entidades <code>Livro</code> e <code>Emprestimo</code>.</li>
      <li>Criar enums de status.</li>
      <li>Criar repositories.</li>
      <li>Criar DTOs de request e response.</li>
      <li>Criar services com regras de negocio.</li>
      <li>Criar controllers com endpoints.</li>
      <li>Criar tratamento global de erros.</li>
      <li>Criar docker-compose.</li>
      <li>Criar testes unitarios.</li>
      <li>Rodar testes e testar no Swagger.</li>
      <li>Escrever README e publicar no GitHub.</li>
    </ol>

    <h3>Termos para pesquisar</h3>
    <p>Spring Boot REST API, DTO Java record, Spring Data JPA query methods, Hibernate Entity Mapping, Bean Validation, ControllerAdvice, JUnit 5 Mockito, Docker Compose PostgreSQL, Swagger OpenAPI Springdoc.</p>
  </section>

  <section class="page-break">
    <h2>9. Codigo Completo Comentado Por Arquivo</h2>
    <p>Esta parte contem os arquivos principais do projeto. Leia primeiro a explicacao acima; depois use estes codigos como referencia para entender como cada camada conversa com a outra.</p>
    $allCode
  </section>
</body>
</html>
"@

Set-Content -LiteralPath $outputHtml -Value $html -Encoding UTF8

$chromeCandidates = @(
    'C:\Program Files\Google\Chrome\Application\chrome.exe',
    'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
    'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
    'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
)

$browser = $chromeCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $browser) {
    throw 'Chrome ou Edge nao encontrado para gerar o PDF.'
}

if (Test-Path -LiteralPath $outputPdf) {
    Remove-Item -LiteralPath $outputPdf -Force
}

$htmlUri = ([System.Uri]$outputHtml).AbsoluteUri
& $browser --headless --disable-gpu --no-sandbox --print-to-pdf="$outputPdf" $htmlUri | Out-Null

if (-not (Test-Path -LiteralPath $outputPdf)) {
    throw "Falha ao gerar PDF em $outputPdf"
}

[pscustomobject]@{
    Html = $outputHtml
    Pdf = $outputPdf
}
