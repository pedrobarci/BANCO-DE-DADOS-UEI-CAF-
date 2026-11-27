-- 1. INSERT (Create)
INSERT INTO cliente (nome, cpf, email, telefone, end_cidade) 
VALUES ('Maria Silva Teste', '99988877766', 'maria.teste@email.com', '(11) 99999-9999', 'São Paulo');

-- 2. SELECT (Read)
SELECT id_cliente, nome, email, end_cidade 
FROM cliente 
WHERE cpf = '99988877766';

-- 3. UPDATE
UPDATE cliente 
SET nome = 'Maria Silva Alterada' 
WHERE cpf = '99988877766';

-- 4. DELETE
DELETE FROM cliente 
WHERE cpf = '99988877766';