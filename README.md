# Sprint RH - Refatoração do banco de dados de RH e folha de pagamento

Atividade em dupla de **Scrum, Kanban e DevOps** (Cenário 11: Sistema de RH e Folha de Pagamento).

O banco original guardava cargos, departamentos e benefícios como **texto livre** na tabela `funcionarios`, o que gerava erros de digitação ("TI", "T.I.", "Tecnologia") e relatórios incorretos. Este repositório contém a refatoração para a **3ª Forma Normal (3FN)**, com tabelas de domínio, chaves, restrições, índices, migração de dados e validação.

## Equipe

| Papel | Integrante |
|---|---|
| Product Owner / Revisor | [Integrante A] |
| Scrum Master / Desenvolvedor | [Integrante B] |

- Quadro Kanban: [colar o link do Trello]
- Documentação completa: [documentacao_completa.md](documentacao_completa.md)

## O que mudou

| Antes (`legado.funcionarios`) | Depois (schema `rh`) |
|---|---|
| Departamento em texto livre | Tabela `departamento` + FK |
| Cargo em texto livre | Tabela `cargo` (com nível) + FK |
| Benefícios em lista separada por vírgula | Tabela `beneficio` + relação N:N `funcionario_beneficio` com histórico |
| Gestor como nome em texto | `id_gestor` (autorrelacionamento com FK) |
| CPF com pontos e traço, sem unicidade | `CHAR(11)` só com dígitos, `UNIQUE` e `CHECK` |
| E-mail com maiúsculas e espaços | Padronizado em minúsculas, `UNIQUE` |
| Sem chaves, restrições nem índices | PK, FK, UNIQUE, CHECK e 6 índices |
| Sem folha de pagamento | Tabelas `folha_pagamento` e `holerite` |

## Estrutura do repositório

```
.
├── README.md
├── documentacao_completa.md
├── sql/
│   ├── 01_legado.sql
│   ├── 02_ddl_refatorado.sql
│   ├── 03_migracao_dados.sql
│   ├── 04_validacao.sql
│   └── 05_dml_atualizado.sql
└── csv/
    ├── legado_funcionarios.csv
    ├── departamento.csv
    ├── cargo.csv
    ├── beneficio.csv
    ├── funcionario.csv
    └── funcionario_beneficio.csv
```

## Como executar

Requisito: **PostgreSQL** (os scripts usam schemas, `regexp_split_to_table` e `string_agg`).

Execute os arquivos nesta ordem:

```bash
psql -U usuario -d banco -f sql/01_legado.sql
psql -U usuario -d banco -f sql/02_ddl_refatorado.sql
psql -U usuario -d banco -f sql/03_migracao_dados.sql
psql -U usuario -d banco -f sql/04_validacao.sql
psql -U usuario -d banco -f sql/05_dml_atualizado.sql
```

| Ordem | Arquivo | Função |
|---|---|---|
| 1 | `01_legado.sql` | Cria o schema `legado` com a tabela original e 10 funcionários de exemplo |
| 2 | `02_ddl_refatorado.sql` | Cria o schema `rh` (3FN), com chaves, restrições e índices |
| 3 | `03_migracao_dados.sql` | Migra os dados usando tabelas de-para, em uma transação |
| 4 | `04_validacao.sql` | Confere a migração (todas as diferenças devem ser 0) |
| 5 | `05_dml_atualizado.sql` | Inserções, atualizações e consultas no novo modelo |

> O `05_dml_atualizado.sql` insere a funcionária Juliana Prado e a folha de 10/2026. Para executá-lo de novo, rode antes `02` e `03` novamente, senão o CPF e a competência duplicados causam erro.

## Fluxo de trabalho

- **Kanban:** Backlog, Sprint Backlog, Em Andamento, Em Revisão (PR) e Concluído.
- **Git:** uma branch por tarefa (`feature/rh-0X-...`), commits dos dois integrantes e Pull Requests revisados pelo parceiro antes do merge na `main`.
