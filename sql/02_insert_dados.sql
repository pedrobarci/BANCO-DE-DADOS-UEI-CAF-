-- =============================================
-- PROJETO: Uei Café
-- ETAPA 5 - POVOAMENTO COMPLETO (500 por tabela)
-- =============================================

-- ---------- 0. LIMPEZA TOTAL + REINÍCIO DE IDs ----------
TRUNCATE TABLE pagamento, item_pedido, pedido, produto,
               funcionario, cliente, categoria
RESTART IDENTITY CASCADE;

-- ---------- 1. CATEGORIA (500 registros) ----------
INSERT INTO categoria (nome, descricao)
SELECT
    'Categoria ' || g,
    'Categoria gerada automaticamente #' || g
FROM generate_series(1, 500) AS g;

-- ---------- 2. CLIENTE (500 registros) ----------
INSERT INTO cliente
    (nome, cpf, email, telefone, end_rua, end_numero, end_bairro,
     end_cidade, end_cep, data_cadastro, pontos_fidelidade)
SELECT
    'Cliente ' || g,
    lpad(g::text, 11, '0'),
    'cliente' || g || '@ueicafe.com',
    '(11) 9' || lpad((g * 7 % 100000000)::text, 8, '0'),
    'Rua das Flores ' || g,
    (g % 500 + 1)::text,
    'Bairro ' || (g % 50 + 1),
    CASE WHEN g % 2 = 0 THEN 'São Paulo' ELSE 'Campinas' END,
    '0' || lpad((g % 90000 + 10000)::text, 5, '0') || '-000',
    CURRENT_DATE - (g % 365),
    (g * 3) % 200
FROM generate_series(1, 500) AS g;

-- ---------- 3. FUNCIONARIO (500 registros) ----------
INSERT INTO funcionario (nome, cpf, cargo, salario, data_admissao, ativo)
SELECT
    'Funcionario ' || g,
    lpad((10000000000 + g)::text, 11, '0'),
    CASE (g % 3)
        WHEN 0 THEN 'Barista'
        WHEN 1 THEN 'Atendente'
        ELSE 'Gerente'
    END,
    round((1800 + (g % 15) * 150)::numeric, 2),
    CURRENT_DATE - (g * 2 % 2000),
    (g % 10 <> 0)
FROM generate_series(1, 500) AS g;

-- ---------- 4. PRODUTO (500 registros) ----------
INSERT INTO produto (nome, descricao, preco, disponivel, id_categoria)
SELECT
    'Produto ' || g,
    'Descrição do produto ' || g,
    round((5 + (g % 40) * 0.75)::numeric, 2),
    (g % 20 <> 0),
    (g % 500) + 1
FROM generate_series(1, 500) AS g;

-- ---------- 5. PEDIDO (500 registros) ----------
INSERT INTO pedido (data_hora, valor_total, status, id_cliente, id_funcionario)
SELECT
    NOW() - ((g % 180) || ' days')::interval
          - ((g % 24) || ' hours')::interval,
    0,
    CASE (g % 5)
        WHEN 0 THEN 'Cancelado'
        WHEN 1 THEN 'Aberto'
        ELSE 'Pago'
    END,
    (g % 500) + 1,
    ((g * 3) % 500) + 1
FROM generate_series(1, 500) AS g;

-- ---------- 6. ITEM_PEDIDO (500 registros — versão robusta) ----------
-- Usa o g-ésimo produto e o g-ésimo pedido existentes, sem depender de IDs fixos
INSERT INTO item_pedido (quantidade, preco_unitario, id_pedido, id_produto)
SELECT
    1 + (g % 4),
    p.preco,
    peds.id_pedido,
    p.id_produto
FROM generate_series(1, 500) AS g
JOIN LATERAL (
    SELECT id_produto, preco
    FROM produto
    ORDER BY id_produto
    OFFSET (g - 1) LIMIT 1
) p ON TRUE
JOIN LATERAL (
    SELECT id_pedido
    FROM pedido
    ORDER BY id_pedido
    OFFSET (g - 1) LIMIT 1
) peds ON TRUE;

-- ---------- 7. PAGAMENTO (500 registros — 1:1 com pedido) ----------
INSERT INTO pagamento (forma_pagamento, valor_pago, data_pagamento, id_pedido)
SELECT
    CASE (p.id_pedido % 4)
        WHEN 0 THEN 'Dinheiro'
        WHEN 1 THEN 'Cartão Crédito'
        WHEN 2 THEN 'Cartão Débito'
        ELSE 'Pix'
    END,
    COALESCE((
        SELECT SUM(quantidade * preco_unitario)
        FROM item_pedido
        WHERE id_pedido = p.id_pedido
    ), 1),
    p.data_hora,
    p.id_pedido
FROM pedido p;

-- ---------- 8. RECALCULAR valor_total dos pedidos ----------
UPDATE pedido p
SET valor_total = COALESCE(sub.total, 0)
FROM (
    SELECT id_pedido, SUM(quantidade * preco_unitario) AS total
    FROM item_pedido
    GROUP BY id_pedido
) sub
WHERE p.id_pedido = sub.id_pedido;