*** Settings ***
Documentation    Keywords relacionadas ao gerenciamento de usuários
Library          RequestsLibrary
Library          Collections
Resource         ../variables.robot
Resource         ../base_setup.robot
Resource         login_keywords.robot

*** Keywords ***
Criar usuario valido
    [Documentation]    Cria um usuário com dados válidos e retorna o ID
    [Arguments]    ${admin}=false
    
    ${email}=    Gerar Email Aleatorio
    ${nome}=     Gerar Nome Aleatorio
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${email}
    ...    password=teste123
    ...    administrador=${admin}
    
    ${response}=    POST    ${BASE_URL}${USUARIOS_ENDPOINT}    json=${body}    expected_status=201
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    _id
    ...    msg=ID do usuário não retornado
    
    ${user_id}=    Set Variable    ${response_json['_id']}
    
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

Buscar usuario por ID
    [Documentation]    Busca usuário específico por ID
    [Arguments]    ${user_id}
    
    ${response}=    GET    ${BASE_URL}${USUARIOS_ENDPOINT}/${user_id}    expected_status=any
    
    RETURN    ${response}

Listar todos usuarios
    [Documentation]    Lista todos os usuários cadastrados
    
    ${response}=    GET    ${BASE_URL}${USUARIOS_ENDPOINT}    expected_status=200
    
    Validar Status Code    ${response}    ${STATUS_200}
    RETURN    ${response}

Atualizar usuario
    [Documentation]    Lista todos os usuários cadastrados
    
    ${response}=    GET    ${BASE_URL}${USUARIOS_ENDPOINT}    expected_status=200
    
    Validar Status Code    ${response}    ${STATUS_200}
    RETURN    ${response}

Deletar usuario
    [Documentation]    Deleta um usuário por ID
    [Arguments]    ${user_id}
    
    ${response}=    DELETE    ${BASE_URL}${USUARIOS_ENDPOINT}/${user_id}    expected_status=any
    
    RETURN    ${response}

Validar usuario criado com sucesso
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
    
    Should Contain    ${response_json['${campo}']}    obrigatório
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

    
