-- 1. Faturamento por forma de pagamento
SELECT forma_pagamento, SUM(valor_pago) AS faturamento_total
FROM pagamento
GROUP BY forma_pagamento
ORDER BY faturamento_total DESC;

-- 2. Top 10 produtos mais vendidos
SELECT p.nome AS produto, SUM(ip.quantidade) AS total_vendido
FROM item_pedido ip
JOIN produto p ON ip.id_produto = p.id_produto
GROUP BY p.nome
ORDER BY total_vendido DESC
LIMIT 10;

-- 3. Pedidos acima de R$ 100
SELECT ped.id_pedido, c.nome AS cliente, ped.valor_total, ped.data_hora
FROM pedido ped
JOIN cliente c ON ped.id_cliente = c.id_cliente
WHERE ped.valor_total > 100.00
ORDER BY ped.valor_total DESC;

-- 4. Desempenho por funcionário
SELECT f.nome AS funcionario, COUNT(ped.id_pedido) AS qtd_pedidos, SUM(ped.valor_total) AS total_vendido
FROM pedido ped
JOIN funcionario f ON ped.id_funcionario = f.id_funcionario
GROUP BY f.nome
ORDER BY total_vendido DESC;

-- 5. Produtos por categoria (ex: categoria 1)
SELECT p.nome AS produto, p.preco, c.nome AS categoria
FROM produto p
JOIN categoria c ON p.id_categoria = c.id_categoria
WHERE c.id_categoria = 1
ORDER BY p.preco ASC;

-- 6. Clientes inativos
SELECT c.nome, c.email
FROM cliente c
LEFT JOIN pedido ped ON c.id_cliente = ped.id_cliente
WHERE ped.id_pedido IS NULL
ORDER BY c.nome ASC;

-- 7. Ticket médio por cidade
SELECT c.end_cidade, AVG(ped.valor_total) AS ticket_medio
FROM pedido ped
JOIN cliente c ON ped.id_cliente = c.id_cliente
WHERE c.end_cidade = 'São Paulo'
GROUP BY c.end_cidade
ORDER BY ticket_medio DESC;

-- 8. Detalhamento de um pedido (ex: pedido 1)
SELECT p.nome AS produto, ip.quantidade, ip.preco_unitario, (ip.quantidade * ip.preco_unitario) AS subtotal
FROM item_pedido ip
JOIN produto p ON ip.id_produto = p.id_produto
WHERE ip.id_pedido = 1
ORDER BY subtotal DESC;

-- 9. Cancelamentos por mês
SELECT TO_CHAR(data_hora, 'YYYY-MM') AS mes, COUNT(*) AS qtd_cancelados
FROM pedido
WHERE status = 'Cancelado'
GROUP BY mes
ORDER BY mes DESC;

-- 10. Top 3 categorias com maior faturamento
SELECT c.nome AS categoria, SUM(ip.quantidade * ip.preco_unitario) AS faturamento_categoria
FROM item_pedido ip
JOIN produto p ON ip.id_produto = p.id_produto
JOIN categoria c ON p.id_categoria = c.id_categoria
GROUP BY c.nome
ORDER BY faturamento_categoria DESC
LIMIT 3;