-- 01_legado.sql : estrutura ANTES da refatoração (schema "legado")
DROP SCHEMA IF EXISTS legado CASCADE;
CREATE SCHEMA legado;

CREATE TABLE legado.funcionarios (
    id_funcionario  SERIAL PRIMARY KEY,
    nome            VARCHAR(120),
    cpf             VARCHAR(14),
    email           VARCHAR(120),
    cargo           VARCHAR(80),     -- texto livre: "Analista de Sistemas", "Analista Sistemas"...
    departamento    VARCHAR(80),     -- texto livre: "TI", "T.I.", "Tecnologia"...
    beneficios      VARCHAR(255),    -- lista separada por vírgula/ponto e vírgula
    salario         NUMERIC(10,2),
    data_admissao   DATE,
    gestor          VARCHAR(120)     -- nome do gestor em texto
);

INSERT INTO legado.funcionarios
    (nome, cpf, email, cargo, departamento, beneficios, salario, data_admissao, gestor)
VALUES
('Carlos Mendes',   '111.111.111-11', 'carlos.mendes@empresa.com',  'Gerente de TI',          'TI',                       'VT, VR, Plano de Saúde',          15000.00, '2018-03-12', NULL),
('Ana Souza',       '222.222.222-22', 'ana.souza@empresa.com',      'Analista de Sistemas',   'T.I.',                     'VT, VR',                           7500.00, '2020-07-01', 'Carlos Mendes'),
('Bruno Lima',      '333.333.333-33', 'BRUNO.LIMA@empresa.com ',    'Analista Sistemas',      'Tecnologia',               'vale transporte; vale refeição',   7200.00, '2021-02-15', 'Carlos Mendes'),
('Camila Rocha',    '444.444.444-44', 'camila.rocha@empresa.com',   'Dev Jr',                 'tecnologia da informação', 'VR',                               4500.00, '2023-05-20', 'Carlos Mendes'),
('Daniela Alves',   '555.555.555-55', 'daniela.alves@empresa.com',  'Gerente de RH',          'Recursos Humanos',         'VT, VR, Plano Saúde, Gympass',    13000.00, '2017-09-04', NULL),
('Eduardo Pires',   '666.666.666-66', 'eduardo.pires@empresa.com',  'Analista de RH',         'RH',                       'Plano Saúde, VT',                  5800.00, '2022-01-10', 'Daniela Alves'),
('Fernanda Costa',  '777.777.777-77', 'fernanda.costa@empresa.com', 'Analista RH',            'R.H.',                     NULL,                               5600.00, '2022-08-22', 'Daniela Alves'),
('Gustavo Nunes',   '888.888.888-88', 'gustavo.nunes@empresa.com',  'Contador',               'Financeiro',               'VT; VR',                           8200.00, '2019-11-11', NULL),
('Helena Martins',  '999.999.999-99', 'helena.martins@empresa.com', 'Contador',               'FINANCEIRO',               'Vale Refeição, Plano de Saúde',    8100.00, '2020-04-30', 'Gustavo Nunes'),
('Igor Teixeira',   '123.456.789-09', 'igor.teixeira@empresa.com',  'Assistente Financeiro',  'Fin.',                     'vt',                               3900.00, '2024-02-05', 'Gustavo Nunes');
