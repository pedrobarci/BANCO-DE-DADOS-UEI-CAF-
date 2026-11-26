# 1. Cenário — Uei Café

## 1.1 Descrição da empresa

A **Uei Café** é uma cafeteria fictícia de médio porte localizada na região central de São Paulo, com uma unidade única e cerca de 15 funcionários. A empresa atua desde 2018 no ramo de cafés especiais, oferecendo bebidas quentes e geladas, salgados, doces e produtos de conveniência. Seu público é composto majoritariamente por trabalhadores do entorno, estudantes e moradores da região, com fluxo médio de 300 atendimentos por dia.

A cafeteria possui um programa de fidelidade simples: cada compra acumula pontos que podem ser trocados por produtos. Os pedidos podem ser feitos no balcão, para consumo no local ou para viagem, e o pagamento é realizado em dinheiro, cartão de crédito, cartão de débito ou Pix.

## 1.2 Problema / necessidade

Atualmente, a Uei Café controla suas operações com **planilhas manuais e cadernos de anotação**, o que gera diversos problemas:

- **Perda de histórico de vendas** — não há registro confiável dos pedidos realizados.
- **Dificuldade em controlar o cardápio** — preços e disponibilidade são atualizados manualmente, gerando erros.
- **Programa de fidelidade inconsistente** — pontos são anotados em papel e frequentemente perdidos.
- **Falta de controle sobre formas de pagamento** — não é possível saber qual meio de pagamento é mais usado.
- **Impossibilidade de gerar relatórios gerenciais** — o dono não consegue responder perguntas simples, como “qual o produto mais vendido?” ou “qual funcionário atendeu mais pedidos?”.
- **Ausência de integridade nos dados** — informações duplicadas de clientes e produtos são comuns.

Diante desse cenário, a Uei Café precisa de um **banco de dados relacional** que centralize clientes, funcionários, produtos, pedidos, itens de pedido e pagamentos, garantindo integridade, consistência e suporte à geração de relatórios gerenciais.

## 1.3 Entidades identificadas

O sistema é composto por **7 entidades**:

| # | Entidade | Descrição |
|---|----------|-----------|
| 1 | **Cliente** | Consumidor cadastrado, com dados pessoais, endereço e pontos de fidelidade. |
| 2 | **Funcionario** | Colaborador da cafeteria (barista, atendente ou gerente). |
| 3 | **Categoria** | Agrupamento de produtos do cardápio (ex.: Bebidas Quentes, Salgados). |
| 4 | **Produto** | Item vendido pela cafeteria, vinculado a uma categoria. |
| 5 | **Pedido** | Venda realizada, com data/hora, status, cliente e funcionário responsável. |
| 6 | **ItemPedido** | Produto específico dentro de um pedido (resolve o N:N entre Pedido e Produto). |
| 7 | **Pagamento** | Registro do pagamento de um pedido (forma, valor e data). |

## 1.4 Atributos por entidade

### Cliente
| Atributo | Tipo | Classificação |
|----------|------|---------------|
| `id_cliente` | BIGINT | **Chave primária** |
| `nome` | VARCHAR(150) | Simples |
| `cpf` | VARCHAR(14) | Simples (único) |
| `email` | VARCHAR(150) | Simples (único) |
| `telefone` | VARCHAR(20) | Simples |
| `end_rua`, `end_numero`, `end_bairro`, `end_cidade`, `end_cep` | VARCHAR | **Composto** (endereço) |
| `data_cadastro` | DATE | Simples |
| `pontos_fidelidade` | INTEGER | **Derivado** (calculado a partir dos pedidos pagos) |

### Funcionario
| Atributo | Tipo | Classificação |
|----------|------|---------------|
| `id_funcionario` | BIGINT | **Chave primária** |
| `nome` | VARCHAR(150) | Simples |
| `cpf` | VARCHAR(14) | Simples (único) |
| `cargo` | VARCHAR(50) | Simples |
| `salario` | DECIMAL(10,2) | Simples |
| `data_admissao` | DATE | Simples |
| `ativo` | BOOLEAN | Simples |

### Categoria
| Atributo | Tipo | Classificação |
|----------|------|---------------|
| `id_categoria` | BIGINT | **Chave primária** |
| `nome` | VARCHAR(80) | Simples (único) |
| `descricao` | VARCHAR(255) | Simples |

### Produto
| Atributo | Tipo | Classificação |
|----------|------|---------------|
| `id_produto` | BIGINT | **Chave primária** |
| `nome` | VARCHAR(120) | Simples |
| `descricao` | VARCHAR(255) | Simples |
| `preco` | DECIMAL(10,2) | Simples |
| `disponivel` | BOOLEAN | Simples |
| `id_categoria` | BIGINT | **Chave estrangeira** (FK → Categoria) |

### Pedido
| Atributo | Tipo | Classificação |
|----------|------|---------------|
| `id_pedido` | BIGINT | **Chave primária** |
| `data_hora` | TIMESTAMP | Simples |
| `valor_total` | DECIMAL(10,2) | **Derivado** (soma dos itens) |
| `status` | VARCHAR(30) | Simples |
| `id_cliente` | BIGINT | **Chave estrangeira** (FK → Cliente) |
| `id_funcionario` | BIGINT | **Chave estrangeira** (FK → Funcionario) |

### ItemPedido
| Atributo | Tipo | Classificação |
|----------|------|---------------|
| `id_item` | BIGINT | **Chave primária** |
| `quantidade` | INTEGER | Simples |
| `preco_unitario` | DECIMAL(10,2) | Simples |
| `id_pedido` | BIGINT | **Chave estrangeira** (FK → Pedido) |
| `id_produto` | BIGINT | **Chave estrangeira** (FK → Produto) |

### Pagamento
| Atributo | Tipo | Classificação |
|----------|------|---------------|
| `id_pagamento` | BIGINT | **Chave primária** |
| `forma_pagamento` | VARCHAR(30) | Simples |
| `valor_pago` | DECIMAL(10,2) | Simples |
| `data_pagamento` | TIMESTAMP | Simples |
| `id_pedido` | BIGINT | **Chave estrangeira** (FK → Pedido, único = 1:1) |

## 1.5 Relacionamentos e cardinalidades

| Relacionamento | Entidades | Cardinalidade | Descrição |
|----------------|-----------|---------------|-----------|
| **Pertence** | Produto — Categoria | **1:N** | Uma categoria agrupa vários produtos; cada produto pertence a uma única categoria. |
| **Realiza** | Cliente — Pedido | **1:N** | Um cliente pode realizar vários pedidos; cada pedido pertence a um único cliente. |
| **Atende** | Funcionario — Pedido | **1:N** | Um funcionário atende vários pedidos; cada pedido é atendido por um único funcionário. |
| **Contém** | Pedido — ItemPedido — Produto | **N:N** | Um pedido contém vários produtos, e um produto pode aparecer em vários pedidos. Resolvido pela entidade associativa **ItemPedido**. |
| **Possui** | Pedido — Pagamento | **1:1** | Cada pedido possui exatamente um pagamento; cada pagamento refere-se a exatamente um pedido. |

## 1.6 Atendimento aos requisitos do enunciado

| Requisito | Como foi atendido |
|-----------|-------------------|
| Mínimo de 5 entidades | ✅ 7 entidades |
| Atributo simples | ✅ `nome`, `email`, `preco`, `status`, etc. |
| Atributo composto | ✅ Endereço do cliente (`end_rua`, `end_numero`, `end_bairro`, `end_cidade`, `end_cep`) |
| Atributo multivalorado | ✅ Telefone do cliente (tratado como campo único no modelo relacional; no conceitual, representa múltiplos contatos) |
| Atributo derivado | ✅ `cliente.pontos_fidelidade` e `pedido.valor_total` |
| Chave primária | ✅ Todas as 7 entidades possuem `id_*` como PK |
| Relacionamento 1:1 | ✅ Pedido — Pagamento |
| Relacionamento 1:N | ✅ Categoria→Produto, Cliente→Pedido, Funcionario→Pedido |
| Relacionamento N:N | ✅ Pedido ↔ Produto (via ItemPedido) |