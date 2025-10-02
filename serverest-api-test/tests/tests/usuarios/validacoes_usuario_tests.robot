*** Settings ***
Documentation    Testes de validações adicionais de usuários da API ServeRest
Resource         ../../../resources/base_setup.robot
Resource         ../../../resources/variables.robot
Resource         ../../../resources/keywords/usuarios_keywords.robot

Suite Setup      Setup Suite
Suite Teardown   Teardown Suite
Test Setup       Setup Test
Test Teardown    Teardown Test

*** Test Cases ***
CT001 - Buscar usuário por ID válido
    [Documentation]    Valida busca de usuário existente por ID
    [Tags]    usuarios    smoke    high
    
    # Cria usuário
    ${user_id}    ${email}    ${nome}=    Criar Usuario Valido
    
    # Busca usuário criado
    ${response}=    Buscar Usuario Por ID    ${user_id}
    Validar Status Code    ${response}    ${STATUS_200}
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['_id']}    ${user_id}
    Should Be Equal    ${response_json['email']}    ${email}

CT002 - Buscar usuário por ID inexistente
    [Documentation]    Valida erro ao buscar usuário que não existe
    [Tags]    usuarios    negative    medium
    
    ${response}=    Buscar Usuario Por ID    idInexistente123456
    Validar Usuario Nao Encontrado    ${response}

CT003 - Listar todos os usuários
    [Documentation]    Valida endpoint que lista todos os usuários cadastrados
    [Tags]    usuarios    smoke    high
    
    ${response}=    Listar Todos Usuarios
    Validar Status Code    ${response}    ${STATUS_200}
    
    ${response_json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${response_json}    usuarios
    Dictionary Should Contain Key    ${response_json}    quantidade

CT004 - Atualizar usuário existente
    [Documentation]    Valida atualização de dados de usuário
    [Tags]    usuarios    high
    
    # Cria usuário
    ${user_id}    ${email}    ${nome}=    Criar Usuario Valido
    
    # Atualiza dados
    ${novo_nome}=    Set Variable    Nome Atualizado
    ${novo_email}=    Gerar Email Aleatorio
    
    ${response}=    Atualizar usuario    ${user_id}    ${novo_nome}    ${novo_email}    senha123    false
    Validar Status Code    ${response}    200
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['message']}    Registro alterado com sucesso

CT005 - Atualizar usuário com email já usado
    [Documentation]    Valida erro ao tentar atualizar com email duplicado
    [Tags]    usuarios    negative    high
    
    # Cria dois usuários
    ${user_id1}    ${email1}    ${nome1}=    Criar Usuario Valido
    ${user_id2}    ${email2}    ${nome2}=    Criar Usuario Valido
    
    # Tenta atualizar user2 com email do user1
    ${response}=    Atualizar Usuario    ${user_id2}    Nome Teste    ${email1}    senha123    false
    Validar email invalido    ${response}
CT006 - Atualizar usuário inexistente cria novo usuário
    [Documentation]    Valida que PUT com ID inexistente cria novo usuário
    [Tags]    usuarios    medium
    
    ${email}=    Gerar Email Aleatorio
    ${response}=    Atualizar usuario        idInexistente999    Usuario Novo    ${email}    senha123    false
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['message']}    Cadastro realizado com sucesso

CT007 - Deletar usuário existente
    [Documentation]    Valida deleção de usuário
    [Tags]    usuarios    high
    
    # Cria usuário
    ${user_id}    ${email}    ${nome}=    Criar Usuario Valido
    
    # Deleta usuário
    ${response}=    Deletar Usuario    ${user_id}
    Validar Status Code    ${response}    200
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['message']}    Registro excluído com sucesso

CT008 - Deletar usuário inexistente
    [Documentation]    Valida mensagem ao tentar deletar usuário que não existe
    [Tags]    usuarios    negative    medium
    
    ${response}=    Deletar Usuario    idInexistente123456
    
    # API pode retornar 200 com mensagem ou 400
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 200    Log To Console    \nAPI retorna sucesso mesmo com ID inexistente
    ...    ELSE    Validar Status Code    ${response}    ${STATUS_400}

CT009 - Criar usuário com nome vazio
    [Documentation]    Valida erro quando nome é string vazia
    [Tags]    usuarios    negative    validation    high
    
    ${email}=    Gerar Email Aleatorio
    ${response}=    Criar Usuario Com Dados    ${EMPTY}    ${email}    senha123    false
    
    Validar Erro Campo Obrigatorio Usuario    ${response}    nome

CT010 - Criar usuário com email vazio
    [Documentation]    Valida erro quando email é string vazia
    [Tags]    usuarios    negative    validation    high
    
    ${nome}=    Gerar Nome Aleatorio
    ${response}=    Criar Usuario Com Dados    ${nome}    ${EMPTY}    senha123    false
    
    Validar Erro Campo Obrigatorio Usuario    ${response}    email

CT011 - Criar usuário com senha vazia
    [Documentation]    Valida erro quando senha é string vazia
    [Tags]    usuarios    negative    validation    high
    
    ${email}=    Gerar Email Aleatorio
    ${nome}=    Gerar Nome Aleatorio
    ${response}=    Criar Usuario Com Dados    ${nome}    ${email}    ${EMPTY}    false
    
    Validar Erro Campo Obrigatorio Usuario    ${response}    password

CT012 - Criar múltiplos usuários sequencialmente
    [Documentation]    Valida criação de vários usuários em sequência
    [Tags]    usuarios    smoke    medium
    
    FOR    ${i}    IN RANGE    3
        ${user_id}    ${email}    ${nome}=    Criar Usuario Valido
        Should Not Be Empty    ${user_id}
        Log To Console    \nUsuário ${i+1} criado: ${email}
    END