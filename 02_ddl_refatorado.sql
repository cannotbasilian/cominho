-- 02_ddl_refatorado.sql : estrutura DEPOIS da refatoração (3FN) - schema "rh"
DROP SCHEMA IF EXISTS rh CASCADE;
CREATE SCHEMA rh;

-- ---------- Tabelas de domínio ----------
CREATE TABLE rh.departamento (
    id_departamento SMALLSERIAL PRIMARY KEY,
    sigla           VARCHAR(10)  NOT NULL UNIQUE,
    nome            VARCHAR(80)  NOT NULL UNIQUE,
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE rh.cargo (
    id_cargo        SMALLSERIAL PRIMARY KEY,
    nome            VARCHAR(80)  NOT NULL UNIQUE,
    nivel           VARCHAR(20)  NOT NULL
                    CHECK (nivel IN ('ESTAGIO','JUNIOR','PLENO','SENIOR','GESTAO','ASSISTENTE')),
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE rh.beneficio (
    id_beneficio    SMALLSERIAL PRIMARY KEY,
    codigo          VARCHAR(10)  NOT NULL UNIQUE,
    nome            VARCHAR(80)  NOT NULL UNIQUE,
    valor_padrao    NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (valor_padrao >= 0),
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE
);

-- ---------- Entidade principal ----------
CREATE TABLE rh.funcionario (
    id_funcionario  SERIAL PRIMARY KEY,
    nome            VARCHAR(120)  NOT NULL,
    cpf             CHAR(11)      NOT NULL UNIQUE CHECK (cpf ~ '^[0-9]{11}$'),
    email           VARCHAR(120)  NOT NULL UNIQUE,
    data_admissao   DATE          NOT NULL,
    salario_base    NUMERIC(10,2) NOT NULL CHECK (salario_base > 0),
    status          VARCHAR(10)   NOT NULL DEFAULT 'ATIVO'
                    CHECK (status IN ('ATIVO','AFASTADO','DESLIGADO')),
    id_cargo        SMALLINT      NOT NULL REFERENCES rh.cargo(id_cargo),
    id_departamento SMALLINT      NOT NULL REFERENCES rh.departamento(id_departamento),
    id_gestor       INTEGER       REFERENCES rh.funcionario(id_funcionario)
                    CHECK (id_gestor IS NULL OR id_gestor <> id_funcionario)
);

-- N:N Funcionário x Benefício (substitui a coluna "beneficios" separada por vírgula)
CREATE TABLE rh.funcionario_beneficio (
    id_funcionario  INTEGER  NOT NULL REFERENCES rh.funcionario(id_funcionario) ON DELETE CASCADE,
    id_beneficio    SMALLINT NOT NULL REFERENCES rh.beneficio(id_beneficio),
    data_inicio     DATE     NOT NULL,
    data_fim        DATE,
    PRIMARY KEY (id_funcionario, id_beneficio, data_inicio),
    CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- ---------- Folha de pagamento ----------
CREATE TABLE rh.folha_pagamento (
    id_folha        SERIAL PRIMARY KEY,
    competencia     DATE NOT NULL UNIQUE CHECK (EXTRACT(DAY FROM competencia) = 1),
    status          VARCHAR(10) NOT NULL DEFAULT 'ABERTA'
                    CHECK (status IN ('ABERTA','FECHADA','PAGA'))
);

CREATE TABLE rh.holerite (
    id_holerite     SERIAL PRIMARY KEY,
    id_folha        INTEGER NOT NULL REFERENCES rh.folha_pagamento(id_folha),
    id_funcionario  INTEGER NOT NULL REFERENCES rh.funcionario(id_funcionario),
    total_proventos NUMERIC(12,2) NOT NULL CHECK (total_proventos >= 0),
    total_descontos NUMERIC(12,2) NOT NULL CHECK (total_descontos >= 0),
    salario_liquido NUMERIC(12,2) GENERATED ALWAYS AS (total_proventos - total_descontos) STORED,
    UNIQUE (id_folha, id_funcionario)
);

-- ---------- Índices (PKs e UNIQUEs já criam índices próprios) ----------
CREATE INDEX idx_func_departamento ON rh.funcionario (id_departamento);
CREATE INDEX idx_func_cargo        ON rh.funcionario (id_cargo);
CREATE INDEX idx_func_gestor       ON rh.funcionario (id_gestor);
CREATE INDEX idx_func_ativos       ON rh.funcionario (nome) WHERE status = 'ATIVO';
CREATE INDEX idx_fb_beneficio      ON rh.funcionario_beneficio (id_beneficio);
CREATE INDEX idx_holerite_func     ON rh.holerite (id_funcionario);
