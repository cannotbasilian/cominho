-- 05_dml_atualizado.sql : DML adaptado ao novo modelo (inserções, atualizações e consultas)

-- Novo funcionário (cargo/departamento/gestor resolvidos por chave natural)
INSERT INTO rh.funcionario
    (nome, cpf, email, data_admissao, salario_base, id_cargo, id_departamento, id_gestor)
SELECT 'Juliana Prado', '10120230344', 'juliana.prado@empresa.com', DATE '2026-11-03', 4700.00,
       c.id_cargo, d.id_departamento, g.id_funcionario
FROM   rh.cargo c, rh.departamento d, rh.funcionario g
WHERE  c.nome = 'Desenvolvedor Júnior' AND d.sigla = 'TI' AND g.nome = 'Carlos Mendes';

-- Concede benefícios ao novo funcionário
INSERT INTO rh.funcionario_beneficio (id_funcionario, id_beneficio, data_inicio)
SELECT f.id_funcionario, b.id_beneficio, f.data_admissao
FROM   rh.funcionario f
JOIN   rh.beneficio b ON b.codigo IN ('VT','VR','SAUDE')
WHERE  f.cpf = '10120230344';

-- Promoção (antes: UPDATE com texto livre; agora: troca de FK)
UPDATE rh.funcionario
SET    id_cargo = (SELECT id_cargo FROM rh.cargo WHERE nome = 'Analista de Sistemas'),
       salario_base = 5800.00
WHERE  cpf = '10120230344';

-- Encerra um benefício sem perder o histórico
UPDATE rh.funcionario_beneficio fb
SET    data_fim = CURRENT_DATE
FROM   rh.funcionario f, rh.beneficio b
WHERE  fb.id_funcionario = f.id_funcionario
  AND  fb.id_beneficio   = b.id_beneficio
  AND  f.nome = 'Igor Teixeira' AND b.codigo = 'VT' AND fb.data_fim IS NULL;

-- Abre a folha de outubro/2026 e gera os holerites (desconto fixo de 11%, cálculo didático)
INSERT INTO rh.folha_pagamento (competencia) VALUES (DATE '2026-10-01');

INSERT INTO rh.holerite (id_folha, id_funcionario, total_proventos, total_descontos)
SELECT fp.id_folha, f.id_funcionario, f.salario_base, ROUND(f.salario_base * 0.11, 2)
FROM   rh.funcionario f
JOIN   rh.folha_pagamento fp ON fp.competencia = DATE '2026-10-01'
WHERE  f.status = 'ATIVO' AND f.data_admissao <= DATE '2026-10-31';

-- ---------- Consultas ----------
-- Q1: Headcount e massa salarial por departamento
SELECT d.nome AS departamento, COUNT(*) AS funcionarios, SUM(f.salario_base) AS massa_salarial
FROM   rh.funcionario f
JOIN   rh.departamento d USING (id_departamento)
WHERE  f.status = 'ATIVO'
GROUP  BY d.nome
ORDER  BY massa_salarial DESC;

-- Q2: Benefícios vigentes por funcionário
SELECT f.nome, string_agg(b.nome, ', ' ORDER BY b.nome) AS beneficios
FROM   rh.funcionario f
LEFT   JOIN rh.funcionario_beneficio fb
       ON fb.id_funcionario = f.id_funcionario AND fb.data_fim IS NULL
LEFT   JOIN rh.beneficio b ON b.id_beneficio = fb.id_beneficio
GROUP  BY f.nome
ORDER  BY f.nome;

-- Q3: Quantos funcionários recebem cada benefício
SELECT b.nome, COUNT(*) AS beneficiarios
FROM   rh.funcionario_beneficio fb
JOIN   rh.beneficio b USING (id_beneficio)
WHERE  fb.data_fim IS NULL
GROUP  BY b.nome
ORDER  BY beneficiarios DESC;

-- Q4: Organograma (gestor -> equipe)
SELECT g.nome AS gestor, f.nome AS subordinado, c.nome AS cargo
FROM   rh.funcionario f
JOIN   rh.funcionario g ON g.id_funcionario = f.id_gestor
JOIN   rh.cargo c ON c.id_cargo = f.id_cargo
ORDER  BY g.nome, f.nome;

-- Q5: Total da folha por departamento na competência 10/2026
SELECT d.nome, SUM(h.total_proventos) AS proventos, SUM(h.total_descontos) AS descontos,
       SUM(h.salario_liquido) AS liquido
FROM   rh.holerite h
JOIN   rh.folha_pagamento fp USING (id_folha)
JOIN   rh.funcionario f USING (id_funcionario)
JOIN   rh.departamento d USING (id_departamento)
WHERE  fp.competencia = DATE '2026-10-01'
GROUP  BY d.nome
ORDER  BY liquido DESC;
