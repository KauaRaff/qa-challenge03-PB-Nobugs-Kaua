*** Settings ***
Documentation    Testes simples para produtos
Resource         ../../resources/base_setup.robot
Resource         ../../resources/variables.robot
Resource         ../../resources/keywords/login_keywords.robot
Resource         ../../resources/keywords/produtos_keywords.robot

Suite Setup      Configuracao Inicial
Suite Teardown   Teardown Suite

*** Keywords ***
Configuracao Inicial
    Setup Suite
    Garantir Admin Existe e Logar

*** Test Cases ***
CT001 - Criar produto com dados válidos
    [Documentation]    Criar produto com dados válidos usando token de admin
    [Tags]    produtos    smoke
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto Teste ${timestamp}
    
    ${response}=    Criar Produtos Com Dados    ${nome}    100    Descrição teste    10
    
    Validar Status Code    ${response}    ${STATUS_201}
    Validar Mensagem De Sucesso    ${response}    Cadastro realizado com sucesso

CT002 - Criar produto com dados inválidos
    [Documentation]    Tentar criar produto sem nome
    [Tags]    produtos    validation
    
    ${response}=    Criar Produtos Com Dados    ${EMPTY}    100    Descrição teste    10
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Erro Campo Obrigatorio Produto    ${response}    nome

CT003 - Atualizar produto inexistente (PUT cria novo)
    [Documentation]    PUT com ID inexistente deve criar novo produto
    [Tags]    produtos    edge-case
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto PUT ${timestamp}
    
    ${response}=    Atualizar Produto    IDInexistente123    ${nome}    150    Descrição PUT    5
    
    Validar Status Code    ${response}    ${STATUS_201}
    Validar Mensagem De Sucesso    ${response}    Cadastro realizado com sucesso
