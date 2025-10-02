*** Settings ***
Documentation    Testes de criação e validação de produtos da API ServeRest
Resource         ../../../resources/base_setup.robot
Resource         ../../../resources/variables.robot
Resource         ../../../resources/keywords/login_keywords.robot
Resource         ../../../resources/keywords/produtos_keywords.robot

Suite Setup      Run Keywords    Setup Suite    AND    Realizar Login Como Admin
Suite Teardown   Teardown Suite
Test Setup       Setup Test
Test Teardown    Teardown Test

*** Test Cases ***
CT001 - Criar produto com dados válidos
    [Documentation]    Valida criação de produto com todos os campos corretos
    [Tags]    produtos    smoke    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    Should Not Be Empty    ${produto_id}    msg=ID do produto não foi retornado

CT002 - Criar produto sem autenticação
    [Documentation]    Valida erro ao tentar criar produto sem token
    [Tags]    produtos    security    high
    
    ${response}=    Criar produto sem autenticação    Produto Teste    100    Descrição teste    10
    Validar Erro Token Ausente    ${response}

CT003 - Criar produto com preço zero
    [Documentation]    Valida erro quando preço é igual a zero
    [Tags]    produtos    negative    validation    high
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${response}=    Criar produtos com dados    ${nome}    0    Descrição teste    10
    Validar Erro Preco Zero    ${response}

CT004 - Criar produto com preço negativo
    [Documentation]    Valida erro quando preço é negativo
    [Tags]    produtos    negative    validation    high
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${response}=    Criar produtos com dados    ${nome}    -50    Descrição teste    10
    Validar Erro Preco Negativo    ${response}

CT005 - Criar produto sem nome
    [Documentation]    Valida erro quando campo nome não é enviado
    [Tags]    produtos    negative    validation    high
    
    ${headers}=    Criar Headers Com Token
    ${body}=    Create Dictionary    preco=100    descricao=Teste    quantidade=10
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=400
    
    Validar Erro Campo Obrigatorio Produto    ${response}    nome

CT006 - Criar produto com nome vazio
    [Documentation]    Valida erro quando nome é string vazia
    [Tags]    produtos    negative    validation    high
    
    ${response}=    Criar produtos com dados    ${EMPTY}    100    Descrição teste    10
    Validar Erro Campo Obrigatorio Produto    ${response}    nome

CT007 - Criar produto sem preço
    [Documentation]    Valida erro quando campo preço não é enviado
    [Tags]    produtos    negative    validation    high
    
    ${headers}=    Criar Headers Com Token
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    ${body}=    Create Dictionary    nome=${nome}    descricao=Teste    quantidade=10
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=400
    
    Validar Erro Campo Obrigatorio Produto    ${response}    preco

CT008 - Criar produto com preço como texto
    [Documentation]    Valida erro quando preço é enviado como texto
    [Tags]    produtos    negative    validation    high
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${headers}=    Criar Headers Com Token
    ${body}=    Create Dictionary    nome=${nome}    preco=texto    descricao=Teste    quantidade=10
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=400
    
    Validar Status Code    ${response}    ${STATUS_400}

CT009 - Criar produto sem descrição
    [Documentation]    Valida comportamento quando descrição não é enviada
    [Tags]    produtos    validation    medium
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${headers}=    Criar Headers Com Token
    ${body}=    Create Dictionary    nome=${nome}    preco=100    quantidade=10
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=any
    
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 201    Log To Console    \nAPI aceita produto sem descrição
    ...    ELSE IF    ${status} == 400    Log To Console    \nAPI rejeita produto sem descrição

CT010 - Criar produto com descrição vazia
    [Documentation]    Valida comportamento quando descrição é string vazia
    [Tags]    produtos    validation    medium
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${response}=    Criar produtos com dados    ${nome}    100    ${EMPTY}    10
    
   
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 201    Log To Console    \nAPI aceita descrição vazia
    ...    ELSE    Validar Status Code    ${response}    ${STATUS_400}



CT011 - Criar produto com campos extras
    [Documentation]    Valida comportamento ao enviar campos não documentados
    [Tags]    produtos    validation    medium
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${headers}=    Criar Headers Com Token
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=100
    ...    descricao=Teste
    ...    quantidade=10
    ...    categoria=Extra
    ...    tags=teste
    
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=any
    
    # API deve ignorar campos extras ou retornar sucesso
    ${status}=    Set Variable    ${response.status_code}
    Should Be True    ${status} == 201 or ${status} == 400    msg=Status inesperado: ${status}