*** Settings ***
Documentation    Testes de autenticação da API ServeRest
Resource         ../../../resources/base_setup.robot
Resource         ../../../resources/variables.robot
Resource         ../../../resources/keywords/login_keywords.robot

Suite Setup      Setup Suite
Suite Teardown   Teardown Suite
Test Setup       Setup Test
Test Teardown    Teardown Test

*** Test Cases ***
CT001 - Login com credenciais válidas
    [Documentation]    Valida login bem-sucedido com credenciais corretas
    [Tags]    login    smoke    high
    
    ${response}=    Realizar Login Com Credenciais    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Validar Login Com Sucesso    ${response}

CT002 - Login com email inexistente
    [Documentation]    Valida erro ao tentar login com email não cadastrado
    [Tags]    login    negative    high
    
    ${response}=    Realizar Login Com Credenciais    inexistente@teste.com    senha123
    Validar Erro De Login    ${response}    Email e/ou senha inválidos

CT003 - Login com senha incorreta
    [Documentation]    Valida erro ao tentar login com senha errada
    [Tags]    login    negative    high
    
    ${response}=    Realizar Login Com Credenciais    ${ADMIN_EMAIL}    senhaerrada123
    Validar Erro De Login    ${response}    Email e/ou senha inválidos

CT004 - Login sem email
    [Documentation]    Valida erro quando campo email não é enviado
    [Tags]    login    negative    validation    high
    
    ${body}=    Create Dictionary    password=${ADMIN_PASSWORD}
    ${response}=    POST    ${BASE_URL}${LOGIN_ENDPOINT}    json=${body}    expected_status=400
    
    Validar Campo Obrigatorio Login    ${response}    email

CT005 - Login sem senha
    [Documentation]    Valida erro quando campo senha não é enviado
    [Tags]    login    negative    validation    high
    
    ${body}=    Create Dictionary    email=${ADMIN_EMAIL}
    ${response}=    POST    ${BASE_URL}${LOGIN_ENDPOINT}    json=${body}    expected_status=400
    
    Validar Campo Obrigatorio Login    ${response}    password

CT006 - Login com email inválido
    [Documentation]    Valida erro quando email está em formato inválido
    [Tags]    login    negative    validation    medium
    
    ${response}=    Realizar Login Com Credenciais    emailinvalido    senha123
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    email deve ser um email válido

CT007 - Login com campos vazios
    [Documentation]    Valida erro quando email e senha estão vazios
    [Tags]    login    negative    validation    medium
    
    ${response}=    Realizar Login Com Credenciais    ${EMPTY}    ${EMPTY}
    Validar Status Code    ${response}    ${STATUS_400}