-- 03_migracao_dados.sql : migra legado.funcionarios -> rh.* com tabelas "de-para"
-- Rodar após 01 e 02. Tudo em uma transação.
BEGIN;

DROP SCHEMA IF EXISTS migracao CASCADE;
CREATE SCHEMA migracao;

-- 1) Carga das tabelas de domínio (valores oficiais)
INSERT INTO rh.departamento (sigla, nome) VALUES
('TI',  'Tecnologia da Informação'),
('RH',  'Recursos Humanos'),
('FIN', 'Financeiro');

INSERT INTO rh.cargo (nome, nivel) VALUES
('Gerente de TI',          'GESTAO'),
('Analista de Sistemas',   'PLENO'),
('Desenvolvedor Júnior',   'JUNIOR'),
('Gerente de RH',          'GESTAO'),
('Analista de RH',         'PLENO'),
('Contador',               'SENIOR'),
('Assistente Financeiro',  'ASSISTENTE');

INSERT INTO rh.beneficio (codigo, nome, valor_padrao) VALUES
('VT',     'Vale Transporte',  220.00),
('VR',     'Vale Refeição',    880.00),
('SAUDE',  'Plano de Saúde',   450.00),
('GYM',    'Gympass',          120.00);

-- 2) Tabelas de-para (variante em minúsculas -> valor oficial)
CREATE TABLE migracao.depara_departamento (variante VARCHAR(80) PRIMARY KEY, sigla VARCHAR(10) NOT NULL);
CREATE TABLE migracao.depara_cargo        (variante VARCHAR(80) PRIMARY KEY, cargo_nome VARCHAR(80) NOT NULL);
CREATE TABLE migracao.depara_beneficio    (variante VARCHAR(80) PRIMARY KEY, codigo VARCHAR(10) NOT NULL);

INSERT INTO migracao.depara_departamento VALUES
('ti','TI'), ('t.i.','TI'), ('tecnologia','TI'), ('tecnologia da informação','TI'),
('rh','RH'), ('r.h.','RH'), ('recursos humanos','RH'),
('financeiro','FIN'), ('fin.','FIN');

INSERT INTO migracao.depara_cargo VALUES
('gerente de ti','Gerente de TI'),
('analista de sistemas','Analista de Sistemas'), ('analista sistemas','Analista de Sistemas'),
('dev jr','Desenvolvedor Júnior'),
('gerente de rh','Gerente de RH'),
('analista de rh','Analista de RH'), ('analista rh','Analista de RH'),
('contador','Contador'),
('assistente financeiro','Assistente Financeiro');

INSERT INTO migracao.depara_beneficio VALUES
('vt','VT'), ('vale transporte','VT'),
('vr','VR'), ('vale refeição','VR'),
('plano saúde','SAUDE'), ('plano de saúde','SAUDE'),
('gympass','GYM');

-- 3) Funcionários (CPF só dígitos, e-mail em minúsculas e sem espaços)
INSERT INTO rh.funcionario
    (nome, cpf, email, data_admissao, salario_base, id_cargo, id_departamento)
SELECT  l.nome,
        regexp_replace(l.cpf, '\D', '', 'g'),
        lower(trim(l.email)),
        l.data_admissao,
        l.salario,
        c.id_cargo,
        d.id_departamento
FROM    legado.funcionarios l
JOIN    migracao.depara_cargo        dc ON dc.variante = lower(trim(l.cargo))
JOIN    rh.cargo                     c  ON c.nome      = dc.cargo_nome
JOIN    migracao.depara_departamento dd ON dd.variante = lower(trim(l.departamento))
JOIN    rh.departamento              d  ON d.sigla     = dd.sigla;

-- 4) Gestor: converte o nome em texto para a FK (autorrelacionamento)
UPDATE rh.funcionario f
SET    id_gestor = g.id_funcionario
FROM   legado.funcionarios l
JOIN   rh.funcionario g ON g.nome = l.gestor
WHERE  f.cpf = regexp_replace(l.cpf, '\D', '', 'g');

-- 5) Benefícios: quebra a lista "VT, VR; ..." em linhas (N:N)
INSERT INTO rh.funcionario_beneficio (id_funcionario, id_beneficio, data_inicio)
SELECT DISTINCT f.id_funcionario, b.id_beneficio, f.data_admissao
FROM   legado.funcionarios l
JOIN   rh.funcionario f ON f.cpf = regexp_replace(l.cpf, '\D', '', 'g')
CROSS  JOIN LATERAL regexp_split_to_table(l.beneficios, '\s*[,;]\s*') AS item(valor)
JOIN   migracao.depara_beneficio db ON db.variante = lower(trim(item.valor))
JOIN   rh.beneficio b ON b.codigo = db.codigo;

COMMIT;
