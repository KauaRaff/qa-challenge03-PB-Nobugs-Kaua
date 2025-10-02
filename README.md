#  Testes Automatizados API ServeRest

Este projeto contém testes automatizados para a API **ServeRest** utilizando **Robot Framework**. A suíte cobre funcionalidades de **usuários**, **produtos** e **carrinhos**, garantindo validação de cenários positivos e negativos.

---

## 🔹 Tecnologias e Dependências

- **Robot Framework** 7.0.1  
- **Robot Framework Requests Library** 0.9.6  
- **Python Requests** 2.31.0  


## 🔹 Estrtura do projeto
```
tests/
├── usuarios/
│   └── usuarios_tests.robot
├── produtos/
│   └── produtos_tests.robot
├── carrinhos/
│   └── carrinhos_tests.robot
resources/
├── variables.robot
├── base_setup.robot
└── keywords/
    ├── login_keywords.robot
    ├── usuarios_keywords.robot
    ├── produtos_keywords.robot
    └── carrinho_keywords.robot
```
Descrição dos arquivos principais:

variables.robot → Variáveis globais e endpoints da API

base_setup.robot → Configuração e teardown da suíte de testes

keywords/ → Palavras-chave customizadas por módulo (login, usuários, produtos, carrinhos)

tests/ → Testes organizados por módulos



## 🔹 Sequência de Execução dos Testes
A execução dos testes segue a ordem estratégica, garantindo que o token do admin esteja disponível e pré-requisitos atendidos:

Usuários – Criação e validação de usuários

Produtos – Criação, atualização e exclusão de produtos

Carrinhos – Adição de produtos, conclusão e cancelamento de carrinhos

⚠️ Ordem essencial: usuários → produtos → carrinhos, pois carrinhos dependem de usuários existentes e produtos válidos, e produtos dependem do token do admin.



## 🔹 Como Rodar os Testes localmente

° Em uma pasta local sua:
```bash
 git clone https://github.com/KauaRaff/qa-challenge03-PB-Nobugs-Kaua
```
° Após isso terá todo o projeto em sua máquina local:


```bash
robot tests/

Roda o teste completo.
```
```bash
robot tests/usuarios
robot tests/produtos
robot tests/carrinhos

Roda na sequência recomendada
```


Instalação das dependências:

```bash
pip install -r requirements.txt

Arquivo requirements.txt:

robotframework==7.0.1
robotframework-requests==0.9.6
requests==2.31.0
```


## 🔹 Como Rodar os Testes em uma EC2 - AWS

É possível simular um ambiente distribuído, com duas instâncias EC2:

EC2 1 – ServeRest API

Sobe a API ServeRest nesta máquina.

```
Deve estar acessível via rede (http://<IP_EC2_1>:8000).
```
EC2 2 – Robot Framework
```
Clona este projeto (git clone <repo>).

Instala Python e dependências (pip install -r requirements.txt).

Configura ${BASE_URL} em variables.robot apontando para a EC2 1.
```
Executa os testes:
```
robot tests/
```

° Mini-diagrama da arquitetura:
```
+----------------+         HTTP Requests        +----------------+
| EC2 2          | ------------------------->  |  EC2 1         |
| Robot Framework|                             | ServeRest API  |
+----------------+                             +----------------+

```


##  🔹 Relatórios

Após execução, são gerados:

report.html → Relatório visual

log.html → Log detalhado de cada teste

output.xml → Arquivo para integração CI/CD


##  🔹 Observações

O Suite Setup garante que o admin exista e esteja logado antes da execução.

Todos os testes dependem de sessões HTTP válidas e do token do admin.

Recomenda-se sempre rodar os testes na ordem indicada.

Organização modular facilita manutenção e expansão futura.


## 🔹 Autor

Kaua Raffaello (NoBugs) – QA


