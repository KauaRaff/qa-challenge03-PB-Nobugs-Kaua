*** Settings ***
Documentation    Keywords relacionadas à autenticação e login
Library          RequestsLibrary
Library          Collections
Resource         ../variables.robot
Resource         ../base_setup.robot

*** Variables ***
${TOKEN}        ${EMPTY}

*** Keywords ***
Realizar Login Como Admin
    [Documentation]    Realiza login com usuário administrador e retorna token
    ${body}=    Create Dictionary
    ...    email=${ADMIN_EMAIL}
    ...    password=${ADMIN_PASSWORD}
    
    ${response}=    POST    ${BASE_URL}${LOGIN_ENDPOINT}    json=${body}    expected_status=200
    
    Validar Status Code    ${response}    ${STATUS_200}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    authorization
    ...    msg=Token de autorização não retornado no login
    
    ${token}=    Set Variable    ${response_json['authorization']}
    Set Suite Variable    ${TOKEN}    ${token}
    
    Log    Login realizado com sucesso. Token: ${token}
    RETURN        ${token}

Realizar Login Com Credenciais
    [Documentation]    Realiza login com email e senha customizados
    [Arguments]    ${email}    ${password}
    
    ${body}=    Create Dictionary
    ...    email=${email}
    ...    password=${password}
    
    ${response}=    POST    ${BASE_URL}${LOGIN_ENDPOINT}    json=${body}    expected_status=any
    
    RETURN    ${response}

Criar Headers Com Token
    [Documentation]    Cria headers HTTP incluindo o token de autenticação
    [Arguments]    ${token}=${TOKEN}
    
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=${token}
    
    RETURN    ${headers}

Validar Login Com Sucesso
    [Documentation]    Valida que o login foi realizado com sucesso
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_200}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    authorization
    Dictionary Should Contain Key    ${response_json}    message
    
    Should Be Equal    ${response_json['message']}    Login realizado com sucesso
    ...    msg=Mensagem de sucesso não retornada

Validar Erro De Login
    [Documentation]    Valida que o login falhou com mensagem de erro
    [Arguments]    ${response}    ${mensagem_esperada}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    ${mensagem_esperada}

Validar Campo Obrigatorio Login
    [Documentation]    Valida erro quando campo obrigatório está ausente
    [Arguments]    ${response}    ${campo}
    
    Validar Status Code    ${response}    ${STATUS_400}
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Contain    ${response_json['${campo}']}    é obrigatório
    ...    msg=Mensagem de campo obrigatório não encontrada para '${campo}'