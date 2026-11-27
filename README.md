# Uei Café - Banco de Dados

## 1. Cenário

A **Uei Café** é uma cafeteria real localizada na região de Franca SP...

*(Para ver o cenário completo com atributos e relacionamentos, acesse [docs/cenario.md](docs/cenario.md))*

## 2. Modelagem Conceitual

A modelagem conceitual foi representada por meio do Diagrama Entidade-Relacionamento (DER), utilizando a notação *Crow's Foot* (Pé de Galinha) para demonstrar as cardinalidades. O diagrama abaixo ilustra as 7 entidades do sistema, seus atributos (simples, compostos e derivados), chaves e os relacionamentos.

![Diagrama Entidade-Relacionamento - Uei Café](images/der.png)

### 2.1 Explicação dos Relacionamentos e Cardinalidades

Para atender aos requisitos do modelo, os relacionamentos foram definidos da seguinte forma:

*   **Relacionamento 1:1 (Um para Um) — `Pedido` e `Pagamento`:** 
    Cada pedido possui exatamente um pagamento associado, e cada pagamento pertence a um único pedido. Isso é garantido pela chave estrangeira `id_pedido` na tabela `pagamento` com a restrição `UNIQUE`.
*   **Relacionamentos 1:N (Um para Muitos):**
    *   **`Categoria` → `Produto`:** Uma categoria agrupa vários produtos, mas cada produto pertence a apenas uma categoria.
    *   **`Cliente` → `Pedido`:** Um cliente pode realizar vários pedidos, mas cada pedido está vinculado a um único cliente.
    *   **`Funcionario` → `Pedido`:** Um funcionário pode atender vários pedidos, mas cada pedido é registrado por um único funcionário.
*   **Relacionamento N:N (Muitos para Muitos) — `Pedido` e `Produto`:**
    Um pedido pode conter vários produtos, e um mesmo produto pode estar em vários pedidos. No modelo relacional, isso é resolvido pela entidade associativa **`ITEM_PEDIDO`**, que contém as chaves estrangeiras de ambos e o atributo `quantidade`.

### 2.2 Classificação dos Atributos no DER
*   **Atributos Compostos:** O endereço do cliente foi desmembrado em `end_rua`, `end_numero`, `end_bairro`, `end_cidade` e `end_cep`.
*   **Atributos Derivados:** O `valor_total` do pedido (soma dos itens) e os `pontos_fidelidade` do cliente.
*   **Chaves Primárias (PK):** Identificadas com o prefixo `id_` em todas as tabelas.
*   **Chaves Estrangeiras (FK):** Identificadas nos campos que fazem ligação entre as tabelas.

## 3. Modelagem Lógica

A modelagem lógica relacional foi construída a partir do DER, transformando as entidades em tabelas, os atributos em colunas e os relacionamentos em chaves estrangeiras (FK). Abaixo está a estrutura detalhada de cada tabela com seus respectivos tipos de dados, chaves primárias (PK) e chaves estrangeiras (FK).

### 3.1 Tabela: `cliente`
Armazena os dados dos consumidores cadastrados na cafeteria.
| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_cliente` | BIGINT | **PK**, Identity | Identificador único do cliente. |
| `nome` | VARCHAR(150) | NOT NULL | Nome completo. |
| `cpf` | VARCHAR(14) | NOT NULL, UNIQUE | CPF do cliente. |
| `email` | VARCHAR(150) | UNIQUE | E-mail de contato. |
| `telefone` | VARCHAR(20) | | Telefone de contato. |
| `end_rua` | VARCHAR(200) | | Rua do endereço (atributo composto). |
| `end_numero` | VARCHAR(20) | | Número do endereço. |
| `end_bairro` | VARCHAR(100) | | Bairro do endereço. |
| `end_cidade` | VARCHAR(100) | | Cidade do endereço. |
| `end_cep` | VARCHAR(10) | | CEP do endereço. |
| `data_cadastro` | DATE | NOT NULL, DEFAULT CURRENT_DATE | Data de registro no sistema. |
| `pontos_fidelidade`| INTEGER | NOT NULL, DEFAULT 0 | Atributo derivado (pontos acumulados). |

### 3.2 Tabela: `funcionario`
Armazena os dados dos colaboradores (baristas, atendentes, gerentes).
| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_funcionario` | BIGINT | **PK**, Identity | Identificador único do funcionário. |
| `nome` | VARCHAR(150) | NOT NULL | Nome completo. |
| `cpf` | VARCHAR(14) | NOT NULL, UNIQUE | CPF do funcionário. |
| `cargo` | VARCHAR(50) | NOT NULL | Cargo exercido (Ex: Barista, Gerente). |
| `salario` | DECIMAL(10,2) | NOT NULL | Salário base. |
| `data_admissao` | DATE | NOT NULL | Data de contratação. |
| `ativo` | BOOLEAN | NOT NULL, DEFAULT TRUE | Indica se está ativo na empresa. |

### 3.3 Tabela: `categoria`
Armazena os agrupamentos dos produtos do cardápio.
| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_categoria` | BIGINT | **PK**, Identity | Identificador único da categoria. |
| `nome` | VARCHAR(80) | NOT NULL, UNIQUE | Nome da categoria (Ex: Bebidas Quentes). |
| `descricao` | VARCHAR(255) | | Descrição detalhada. |

### 3.4 Tabela: `produto`
Armazena os itens vendidos pela cafeteria.
| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_produto` | BIGINT | **PK**, Identity | Identificador único do produto. |
| `nome` | VARCHAR(120) | NOT NULL | Nome do produto. |
| `descricao` | VARCHAR(255) | | Ingredientes ou detalhes. |
| `preco` | DECIMAL(10,2) | NOT NULL, CHECK (> 0)| Preço de venda. |
| `disponivel` | BOOLEAN | NOT NULL, DEFAULT TRUE | Indica se está no cardápio. |
| `id_categoria` | BIGINT | **FK** → `categoria` | Categoria à qual o produto pertence. |

### 3.5 Tabela: `pedido`
Registra as vendas realizadas.
| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_pedido` | BIGINT | **PK**, Identity | Identificador único do pedido. |
| `data_hora` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data e hora da venda. |
| `valor_total` | DECIMAL(10,2) | NOT NULL, DEFAULT 0 | Atributo derivado (soma dos itens). |
| `status` | VARCHAR(30) | NOT NULL, DEFAULT 'Aberto' | Status do pedido (Aberto, Pago, Cancelado).|
| `id_cliente` | BIGINT | **FK** → `cliente` | Cliente que realizou o pedido. |
| `id_funcionario`| BIGINT | **FK** → `funcionario` | Funcionário que atendeu o pedido. |

### 3.6 Tabela: `item_pedido`
Entidade associativa que resolve o relacionamento N:N entre Pedido e Produto.
| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_item` | BIGINT | **PK**, Identity | Identificador único do item. |
| `quantidade` | INTEGER | NOT NULL, CHECK (> 0)| Quantidade comprada do produto. |
| `preco_unitario`| DECIMAL(10,2) | NOT NULL | Preço do produto no momento da venda. |
| `id_pedido` | BIGINT | **FK** → `pedido` | Pedido ao qual o item pertence. |
| `id_produto` | BIGINT | **FK** → `produto` | Produto vendido. |

### 3.7 Tabela: `pagamento`
Registra a forma e o valor pago de um pedido (Relacionamento 1:1 com Pedido).
| Coluna | Tipo de Dado | Restrições | Descrição |
| :--- | :--- | :--- | :--- |
| `id_pagamento` | BIGINT | **PK**, Identity | Identificador único do pagamento. |
| `forma_pagamento`| VARCHAR(30) | NOT NULL | Dinheiro, Cartão Crédito, Débito ou Pix.|
| `valor_pago` | DECIMAL(10,2) | NOT NULL, CHECK (> 0)| Valor efetivamente pago. |
| `data_pagamento` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Data e hora do pagamento. |
| `id_pedido` | BIGINT | **FK** → `pedido`, UNIQUE | O pedido pago (garante o 1:1). |

---
**Resumo dos Relacionamentos (Integridade Referencial):**
* `produto.id_categoria` aponta para `categoria.id_categoria` (1:N)
* `pedido.id_cliente` aponta para `cliente.id_cliente` (1:N)
* `pedido.id_funcionario` aponta para `funcionario.id_funcionario` (1:N)
* `item_pedido.id_pedido` aponta para `pedido.id_pedido` (N:N via item)
* `item_pedido.id_produto` aponta para `produto.id_produto` (N:N via item)
* `pagamento.id_pedido` aponta para `pedido.id_pedido` (1:1)

## 4. Modelagem Física

A implementação física do banco de dados foi realizada no SGBD PostgreSQL, utilizando a plataforma em nuvem **Supabase**. Foram criadas as 7 tabelas definidas no modelo lógico, com seus respectivos tipos de dados, restrições de integridade (`NOT NULL`, `UNIQUE`, `CHECK`) e chaves estrangeiras (`FOREIGN KEY`) configuradas com regras de exclusão e atualização em cascata (`ON DELETE CASCADE`) para garantir a integridade referencial. Os scripts SQL de criação estão disponíveis na pasta `sql` deste repositório.

### Evidências da Implementação no Supabase

**Visão Geral do Banco de Dados no Table Editor:**
![Visão Geral](images/supabase-tabelas/visao-geral.png.png)

<details>
<summary><b>👉 Clique aqui para expandir e ver todos os prints do passo a passo e da estrutura das tabelas</b></summary>
<br>

**Criação do Projeto no Supabase:**
![Projeto Criado](images/supabase-tabelas/projeto.png.png)
![Projeto Criado 2](images/supabase-tabelas/projeto2.png.png)
![Projeto Criado 3](images/supabase-tabelas/projeto3.png.png)
![Projeto Criado 4](images/supabase-tabelas/projeto4.png.png)
![Projeto Criado 5](images/supabase-tabelas/projeto5.png.png)
![Projeto Criado 6](images/supabase-tabelas/projeto6.png.png)

**Execução do Script SQL:**
![Script Executado](images/supabase-tabelas/02-script.png.png)

**Lista de Tabelas Criadas:**
![Lista de Tabelas](images/supabase-tabelas/lista-tabelas.png.png)
![Lista de Tabelas 2](images/supabase-tabelas/lista-tabelas2.png.png)

**Estrutura das Tabelas:**
*Cliente:*
![Estrutura Cliente](images/supabase-tabelas/estrutura-cliente.png.png)

*Funcionário:*
![Estrutura Funcionario](images/supabase-tabelas/estrutura-funcionario.png.png)

*Categoria:*
![Estrutura Categoria](images/supabase-tabelas/estrutura-categoria.png.png)

*Produto:*
![Estrutura Produto](images/supabase-tabelas/estrutura-produto.png.png)

*Pedido:*
![Estrutura Pedido](images/supabase-tabelas/estrutura-pedido.png.png)

*Item Pedido:*
![Estrutura Item Pedido](images/supabase-tabelas/estrutura-item-pedido.png.png)

*Pagamento:*
![Estrutura Pagamento](images/supabase-tabelas/estrutura-pagamento.png.png)

</details>

## 5. Dados

Para a validação do banco de dados e realização de testes, o sistema foi populado com um volume significativo de dados coerentes com o cenário da cafeteria. Foram inseridos **500 registros em cada uma das 7 tabelas** (totalizando 3.500 registros), garantindo a unicidade das chaves primárias e o respeito às regras de negócio.

A inserção foi realizada via script SQL para garantir agilidade e consistência. O script de povoamento está disponível em `sql/02_insert_dados.sql`.

### Evidências do Povoamento
Abaixo estão as capturas de tela demonstrando a execução dos scripts e a verificação da quantidade de dados:

![Evidência de Dados 1](images/dados/dado-01.png.png)
![Evidência de Dados 2](images/dados/dado-02.png.png)
![Evidência de Dados 3](images/dados/dado-03.png.png)
![Evidência de Dados 4](images/dados/dado-04.png.png)
![Evidência de Dados 5](images/dados/dado-05.png.png)
![Evidência de Dados 6](images/dados/dado-06.png.png)
![Evidência de Dados 7](images/dados/dado-07.png.png)
![Evidência de Dados 8](images/dados/dado-08.png.png)
![Evidência de Dados 9](images/dados/dado-09.png.png)
![Evidência de Dados 10](images/dados/dado-10.png.png)
![Evidência de Dados 11](images/dados/dado-11.png.png)

## 6. CRUD
Para demonstrar o funcionamento prático do banco de dados, foram realizadas as quatro operações fundamentais de manipulação de dados (CRUD) diretamente no ambiente do Supabase (SQL Editor).

### 6.1 Create (Inserção)
![Operação de Insert](images/crud/01-select.png)

### 6.2 Read (Consulta)
![Operação de Select](images/crud/02-select.png)

### 6.3 Update (Atualização)
![Operação de Update](images/crud/03-update.png)

### 6.4 Delete (Exclusão)
![Operação de Delete](images/crud/04-delete.png)

## 7. Relatórios

Foram desenvolvidas 10 consultas SQL avançadas para extrair informações gerenciais do banco de dados da Uei Café. Todas as consultas utilizam comandos como `SELECT`, `WHERE`, `JOIN`, `GROUP BY` e `ORDER BY`.

### Relatório 1: Faturamento por forma de pagamento
**Objetivo:** Identificar qual meio de pagamento gera mais receita.
![Relatório 1](images/relatorios/consulta-01.png)

### Relatório 2: Top 10 produtos mais vendidos
**Objetivo:** Descobrir quais itens do cardápio têm maior saída.
![Relatório 2](images/relatorios/consulta-02.png)

### Relatório 3: Pedidos de alto valor
**Objetivo:** Listar pedidos acima de R$ 100,00 e seus respectivos clientes.
![Relatório 3](images/relatorios/consulta-03.png)

### Relatório 4: Desempenho por funcionário
**Objetivo:** Avaliar qual funcionário vendeu mais e quantos pedidos atendeu.
![Relatório 4](images/relatorios/consulta-04.png)

### Relatório 5: Produtos por categoria
**Objetivo:** Listar os produtos pertencentes a uma categoria específica.
![Relatório 5](images/relatorios/consulta-05.png)

### Relatório 6: Clientes inativos
**Objetivo:** Identificar clientes cadastrados que ainda não realizaram nenhum pedido.
![Relatório 6](images/relatorios/consulta-06.png)

### Relatório 7: Ticket médio por cidade
**Objetivo:** Calcular o valor médio gasto por pedido em São Paulo.
![Relatório 7](images/relatorios/consulta-07.png)

### Relatório 8: Detalhamento de um pedido
**Objetivo:** Mostrar todos os itens que compõem um pedido específico.
![Relatório 8](images/relatorios/consulta-08.png)

### Relatório 9: Cancelamentos por mês
**Objetivo:** Acompanhar a evolução de pedidos cancelados mês a mês.
![Relatório 9](images/relatorios/consulta-09.png)

### Relatório 10: Top 3 categorias com maior faturamento
**Objetivo:** Identificar quais tipos de produtos geram mais dinheiro.
![Relatório 10](images/relatorios/consulta-10.png)