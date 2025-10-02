*** Settings ***
Documentation    Testes simples para usuários
Resource         ../../resources/base_setup.robot
Resource         ../../resources/variables.robot
Resource         ../../resources/keywords/login_keywords.robot
Resource         ../../resources/keywords/usuarios_keywords.robot

Suite Setup      Setup Suite
Suite Teardown   Teardown Suite

*** Test Cases ***
CT001 - Criar usuário com dados válidos
    [Documentation]    Criar usuário comum com dados válidos
    [Tags]    usuarios    smoke
    
    ${email}=    Gerar Email Aleatorio
    ${nome}=     Gerar Nome Aleatorio
    
    ${response}=    Criar usuario com dados    ${nome}    ${email}    teste123    false
    
    Validar Status Code    ${response}    ${STATUS_201}
    Validar Mensagem De Sucesso    ${response}    Cadastro realizado com sucesso

CT002 - Criar usuário com dados aleatorios
    [Documentation]    Tentar criar usuário sem email
    [Tags]    usuarios    validation
    
    ${nome}=     Gerar Nome Aleatorio
    
    ${response}=    Criar usuario com dados    ${nome}    ${EMPTY}    teste123    false
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar erro campo obrigatorio usuario    ${response}    email
