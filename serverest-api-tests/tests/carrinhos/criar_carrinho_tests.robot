*** Settings ***
Documentation    Testes simples para carrinhos
Resource         ../../resources/base_setup.robot
Resource         ../../resources/variables.robot
Resource         ../../resources/keywords/login_keywords.robot
Resource         ../../resources/keywords/produtos_keywords.robot
Resource         ../../resources/keywords/carrinho_keywords.robot
Resource         ../../resources/keywords/usuarios_keywords.robot

Suite Setup      Configuracao Inicial
Suite Teardown   Teardown Suite

*** Keywords ***
Configuracao Inicial
    Setup Suite
    Garantir Admin Existe e Logar

*** Test Cases ***
CT001 - Adicionar produto ao carrinho
    [Documentation]    Adicionar produto válido ao carrinho
    [Tags]    carrinho    smoke
    
    # Criar produto primeiro
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    # Criar usuário comum para ter carrinho
    ${user_id}    ${email}    ${nome_user}=    Criar usuario valido
    
    # Fazer login com usuário comum
    ${response_login}=    Realizar Login Com Credenciais    ${email}    teste123
    ${token_user}=    Set Variable    ${response_login.json()['authorization']}
    
    # Adicionar produto ao carrinho
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id}    2    ${token_user}
    
    Validar Status Code    ${response}    ${STATUS_201}
    Validar Carrinho Criado Com Sucesso    ${response}

CT002 - Adicionar produto inexistente ao carrinho
    [Documentation]    Tentar adicionar produto que não existe
    [Tags]    carrinho    validation
    
    # Criar usuário comum
    ${user_id}    ${email}    ${nome_user}=    Criar usuario valido
    
    # Fazer login com usuário comum
    ${response_login}=    Realizar Login Com Credenciais    ${email}    teste123
    ${token_user}=    Set Variable    ${response_login.json()['authorization']}
    
    # Tentar adicionar produto inexistente
    ${response}=    Adicionar Produto Ao Carrinho    IDInexistente123    1    ${token_user}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Erro De Produto Inexistente    ${response}
