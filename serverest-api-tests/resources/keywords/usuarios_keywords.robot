*** Settings ***
Documentation    Keywords relacionadas ao gerenciamento de usuários
Library          RequestsLibrary
Library          Collections
Resource         ../variables.robot
Resource         ../base_setup.robot

*** Keywords ***
Criar usuario valido
    [Documentation]    Cria um usuário com dados válidos e retorna o ID
    [Arguments]    ${admin}=false
    
    ${email}=    Gerar Email Aleatorio
    ${nome}=     Gerar Nome Aleatorio
    
    ${response}=    Criar usuario com dados    ${nome}    ${email}    teste123    ${admin}
    
    Validar Usuario Criado Com Sucesso    ${response}
    
    ${user_id}=    Set Variable    ${response.json()['_id']}
    Log    Usuário criado com sucesso. ID: ${user_id}
    RETURN    ${user_id}    ${email}    ${nome}

Criar usuario com dados
    [Documentation]    Cria usuário com dados customizados
    [Arguments]    ${nome}    ${email}    ${password}    ${admin}=false
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=${password}
    ...    administrador=${admin}
    
    ${response}=    POST    ${BASE_URL}${USUARIOS_ENDPOINT}    json=${body}    expected_status=any
    
    RETURN    ${response}

Validar Usuario Criado Com Sucesso
    [Documentation]    Valida resposta de criação de usuário bem-sucedida
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    _id
    Dictionary Should Contain Key    ${response_json}    message
    
    Should Be Equal    ${response_json['message']}    Cadastro realizado com sucesso
    ...    msg=Mensagem de sucesso não retornada

Validar erro campo obrigatorio usuario
    [Documentation]    Valida erro de campo obrigatório em usuário
    [Arguments]    ${response}    ${campo}
    
    Validar Status Code    ${response}    ${STATUS_400}
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Contain    ${response_json['${campo}']}    não pode ficar em branco
    ...    msg=Mensagem de campo obrigatório não encontrada para '${campo}'

Validar email invalido
    [Documentation]    Valida erro quando email está em formato inválido
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    email deve ser um email válido

Validar usuario nao encontrado
    [Documentation]    Valida erro quando usuário não existe
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Usuário não encontrado

Validar usuario com email ja cadastrado
    [Documentation]    Valida erro quando email já existe
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Este email já está sendo usado

Buscar Usuario Por ID
    [Documentation]    Busca um usuário pelo ID.
    [Arguments]    ${user_id}
    
    ${response}=    GET    ${BASE_URL}${USUARIOS_ENDPOINT}/${user_id}    expected_status=any
    
    RETURN    ${response}
