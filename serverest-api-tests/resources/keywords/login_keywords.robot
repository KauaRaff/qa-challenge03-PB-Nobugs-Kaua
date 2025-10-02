*** Settings ***
Documentation    Keywords relacionadas à autenticação e login
Library          RequestsLibrary
Library          Collections
Resource         ../variables.robot
Resource         ../base_setup.robot
Resource         usuarios_keywords.robot

*** Variables ***
${TOKEN}        ${EMPTY}

*** Keywords ***
Garantir Admin Existe e Logar
    [Documentation]    Garante que o usuário admin exista e realiza o login
    
    # 1. Tenta criar o admin
    ${body}=    Create Dictionary
    ...    nome=${ADMIN_NOME}
    ...    email=${ADMIN_EMAIL}
    ...    password=${ADMIN_PASSWORD}
    ...    administrador=true
    
    ${response}=    POST    ${BASE_URL}${USUARIOS_ENDPOINT}    json=${body}    expected_status=any
    
    
    ${token}=    Realizar Login Como Admin
    RETURN    ${token}

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
    
    # A ServeRest usa o nome do campo como chave para o erro
    Dictionary Should Contain Key    ${response_json}    ${campo}
    Should Contain    ${response_json['${campo}']}    não pode ficar em branco
    ...    msg=Mensagem de campo obrigatório não encontrada
