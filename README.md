# Uei Café - Banco de Dados

## 1. Cenário

A **Uei Café** é uma cafeteria real localizada na região de Franca SP...

*(Para ver o cenário completo com atributos e relacionamentos, acesse [docs/cenario.md](docs/cenario.md))*

## 2. Modelagem Conceitual
(em construção)

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
(em construção)

## 5. Dados
(em construção)

## 6. CRUD
(em construção)

## 7. Relatórios
(em construção)