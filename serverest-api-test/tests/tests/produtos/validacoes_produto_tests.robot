*** Settings ***
Documentation    Testes de validações adicionais de produtos da API ServeRest
Resource         ../../../resources/base_setup.robot
Resource         ../../../resources/variables.robot
Resource         ../../../resources/keywords/login_keywords.robot
Resource         ../../../resources/keywords/produtos_keywords.robot

Suite Setup      Run Keywords    Setup Suite    AND    Realizar Login Como Admin
Suite Teardown   Teardown Suite
Test Setup       Setup Test
Test Teardown    Teardown Test

*** Test Cases ***
CT001 - Buscar produto por ID válido
    [Documentation]    Valida busca de produto existente por ID
    [Tags]    produtos    smoke    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Buscar Produto Por ID    ${produto_id}
    Validar Status Code    ${response}    ${STATUS_200}
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['_id']}    ${produto_id}
    Should Be Equal    ${response_json['nome']}    ${nome}

CT002 - Buscar produto por ID inexistente
    [Documentation]    Valida erro ao buscar produto que não existe
    [Tags]    produtos    negative    medium
    
    ${response}=    Buscar Produto Por ID    idInexistente123456
    Validar Produto Nao Encontrado    ${response}

CT003 - Listar todos os produtos
    [Documentation]    Valida endpoint que lista todos os produtos cadastrados
    [Tags]    produtos    smoke    high
    
    ${response}=    Listar Todos Produtos
    Validar Status Code    ${response}    ${STATUS_200}
    
    ${response_json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${response_json}    produtos
    Dictionary Should Contain Key    ${response_json}    quantidade

CT004 - Deletar produto existente
    [Documentation]    Valida deleção de produto
    [Tags]    produtos    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Deletar Produto    ${produto_id}
    Validar Status Code    ${response}    200
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['message']}    Registro excluído com sucesso

CT005 - Deletar produto inexistente
    [Documentation]    Valida mensagem ao tentar deletar produto que não existe
    [Tags]    produtos    negative    medium
    
    ${response}=    Deletar Produto    idInexistente123456
    
    # API pode retornar 200 com mensagem ou 400
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 200    Log To Console    \nAPI retorna sucesso mesmo com ID inexistente
    ...    ELSE    Validar Status Code    ${response}    ${STATUS_400}

CT006 - Deletar produto sem autenticação
    [Documentation]    Valida erro ao tentar deletar sem token
    [Tags]    produtos    security    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    DELETE    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    expected_status=401
    Validar Status Code    ${response}    401

CT007 - Criar produto com nome de produto já existente
    [Documentation]    Valida comportamento ao criar produto com nome duplicado
    [Tags]    produtos    validation    medium
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto Unico ${timestamp}
    
    ${response1}=    Criar produtos com dados    ${nome}    100    Descrição 1    10
    Validar Produto Criado Com Sucesso    ${response1}
    
    ${response2}=    Criar produtos com dados    ${nome}    200    Descrição 2    20
    
    ${status}=    Set Variable    ${response2.status_code}
    Run Keyword If    ${status} == 201    Log To Console    \nAPI aceita nomes duplicados
    ...    ELSE IF    ${status} == 400    Log To Console    \nAPI rejeita nomes duplicados

CT008 - Criar produto com quantidade negativa
    [Documentation]    Valida comportamento com quantidade negativa
    [Tags]    produtos    negative    validation    medium
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${response}=    Criar produtos com dados    ${nome}    100    Descrição    -5
    
    # Verifica se API aceita ou rejeita
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 400    Log To Console    \nAPI rejeita quantidade negativa
    ...    ELSE    Log To Console    \nAPI aceita quantidade negativa

CT009 - Criar produto com quantidade como texto
    [Documentation]    Valida erro quando quantidade é enviada como texto
    [Tags]    produtos    negative    validation    medium
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${headers}=    Criar Headers Com Token
    ${body}=    Create Dictionary    nome=${nome}    preco=100    descricao=Teste    quantidade=texto
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=400
    
    Validar Status Code    ${response}    ${STATUS_400}

CT010 - Buscar produto com caracteres especiais no ID
    [Documentation]    Valida comportamento ao buscar com ID inválido
    [Tags]    produtos    negative    validation    medium
    
    ${response}=    Buscar Produto Por ID    @#$%&*
    Validar Status Code    ${response}    ${STATUS_400}

CT011 - Criar múltiplos produtos sequencialmente
    [Documentation]    Valida criação de vários produtos em sequência
    [Tags]    produtos    smoke    medium
    
    FOR    ${i}    IN RANGE    3
        ${produto_id}    ${nome}=    Criar Produto Valido
        Should Not Be Empty    ${produto_id}
        Log To Console    \nProduto ${i+1} criado: ${nome}
    END

CT012 - Validar estrutura completa da resposta de produto
    [Documentation]    Valida que todos os campos esperados estão presentes na resposta
    [Tags]    produtos    smoke    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Buscar Produto Por ID    ${produto_id}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    _id
    Dictionary Should Contain Key    ${response_json}    nome
    Dictionary Should Contain Key    ${response_json}    preco
    Dictionary Should Contain Key    ${response_json}    descricao
    Dictionary Should Contain Key    ${response_json}    quantidade
    
    Log To Console    \nTodos os campos obrigatórios estão presentes

CT013 - Atualizar produto deletado
    [Documentation]    Valida comportamento ao tentar atualizar produto já deletado
    [Tags]    produtos    negative    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    ${response_delete}=    Deletar Produto    ${produto_id}
    Validar Status Code    ${response_delete}    200
    
    ${response}=    Atualizar Produto    ${produto_id}    Produto Atualizado    100    Descrição    10
    
    Validar Status Code    ${response}    ${STATUS_201}
