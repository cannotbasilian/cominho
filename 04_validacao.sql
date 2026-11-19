-- 04_validacao.sql : rodar logo após o 03. Todas as consultas devem retornar 0 linhas / diferença = 0.

-- V1: registro do legado sem correspondente (cargo/departamento sem de-para)
SELECT l.id_funcionario, l.cargo, l.departamento
FROM   legado.funcionarios l
LEFT   JOIN migracao.depara_cargo        dc ON dc.variante = lower(trim(l.cargo))
LEFT   JOIN migracao.depara_departamento dd ON dd.variante = lower(trim(l.departamento))
WHERE  dc.variante IS NULL OR dd.variante IS NULL;

-- V2: mesma quantidade de funcionários antes e depois (esperado: diferenca = 0)
SELECT (SELECT COUNT(*) FROM legado.funcionarios) - (SELECT COUNT(*) FROM rh.funcionario) AS diferenca;

-- V3: benefícios sem de-para
SELECT DISTINCT lower(trim(item.valor)) AS beneficio_nao_mapeado
FROM   legado.funcionarios l
CROSS  JOIN LATERAL regexp_split_to_table(l.beneficios, '\s*[,;]\s*') AS item(valor)
LEFT   JOIN migracao.depara_beneficio db ON db.variante = lower(trim(item.valor))
WHERE  db.variante IS NULL;

-- V4: gestor informado no legado que não virou FK
SELECT l.nome, l.gestor
FROM   legado.funcionarios l
JOIN   rh.funcionario f ON f.cpf = regexp_replace(l.cpf, '\D', '', 'g')
WHERE  l.gestor IS NOT NULL AND f.id_gestor IS NULL;

-- V5: salários preservados (esperado: diferenca = 0.00)
SELECT (SELECT SUM(salario) FROM legado.funcionarios) - (SELECT SUM(salario_base) FROM rh.funcionario) AS diferenca;

-- V6: plano de execução (em tabelas maiores, conferir "Index Scan")
EXPLAIN SELECT * FROM rh.funcionario WHERE id_departamento = 1;
