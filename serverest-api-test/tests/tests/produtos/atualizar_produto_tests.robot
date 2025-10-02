*** Settings ***
Documentation    Testes de atualização de produtos da API ServeRest
Resource         ../../../resources/base_setup.robot
Resource         ../../../resources/variables.robot
Resource         ../../../resources/keywords/login_keywords.robot
Resource         ../../../resources/keywords/produtos_keywords.robot

Suite Setup      Run Keywords    Setup Suite    AND    Realizar Login Como Admin
Suite Teardown   Teardown Suite
Test Setup       Setup Test
Test Teardown    Teardown Test

*** Test Cases ***
CT001 - Atualizar produto existente com dados válidos
    [Documentation]    Valida atualização completa de produto
    [Tags]    produtos    high
    
    # Cria produto
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    # Atualiza produto
    ${timestamp}=    Get Time    epoch
    ${novo_nome}=    Set Variable    Produto Atualizado ${timestamp}
    ${response}=    Atualizar Produto    ${produto_id}    ${novo_nome}    150    Descrição atualizada    20
    
    Validar Produto Atualizado Com Sucesso    ${response}

CT002 - Atualizar produto inexistente cria novo produto
    [Documentation]    Valida que PUT com ID inexistente cria novo produto (comportamento esperado conforme planejamento)
    [Tags]    produtos    high
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto Novo ${timestamp}
    
    ${response}=    Atualizar Produto    idInexistente999    ${nome}    100    Descrição nova    10
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['message']}    Cadastro realizado com sucesso

CT003 - Atualizar produto com ID inválido
    [Documentation]    Valida erro ao usar ID com formato inválido
    [Tags]    produtos    negative    medium
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto ${timestamp}
    
    ${response}=    Atualizar Produto    @#$%INVALID    ${nome}    100    Descrição    10
    
    Validar Status Code    ${response}    ${STATUS_400}

CT004 - Atualizar produto com preço zero
    [Documentation]    Valida erro ao tentar atualizar com preço zero
    [Tags]    produtos    negative    validation    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Atualizar Produto    ${produto_id}    ${nome}    0    Descrição    10
    Validar Erro Preco Zero    ${response}

CT005 - Atualizar produto com preço negativo
    [Documentation]    Valida erro ao tentar atualizar com preço negativo
    [Tags]    produtos    negative    validation    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Atualizar Produto    ${produto_id}    ${nome}    -100    Descrição    10
    Validar Erro Preco Negativo    ${response}

CT006 - Atualizar produto sem nome
    [Documentation]    Valida erro ao tentar atualizar sem campo nome
    [Tags]    produtos    negative    validation    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${headers}=    Criar Headers Com Token
    ${body}=    Create Dictionary    preco=100    descricao=Teste    quantidade=10
    ${response}=    PUT    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    json=${body}    headers=${headers}    expected_status=400
    
    Validar Erro Campo Obrigatorio Produto    ${response}    nome

CT007 - Atualizar produto com nome vazio
    [Documentation]    Valida erro ao atualizar com nome vazio
    [Tags]    produtos    negative    validation    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Atualizar Produto    ${produto_id}    ${EMPTY}    100    Descrição    10
    Validar Erro Campo Obrigatorio Produto    ${response}    nome

CT008 - Atualizar produto sem autenticação
    [Documentation]    Valida erro ao tentar atualizar sem token
    [Tags]    produtos    security    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${timestamp}=    Get Time    epoch
    ${novo_nome}=    Set Variable    Produto ${timestamp}
    ${body}=    Create Dictionary    nome=${novo_nome}    preco=100    descricao=Teste    quantidade=10
    ${response}=    PUT    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    json=${body}    expected_status=401
    
    Validar Status Code    ${response}    401

CT009 - Atualizar apenas o preço do produto
    [Documentation]    Valida atualização parcial de produto (apenas preço)
    [Tags]    produtos    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Atualizar Produto    ${produto_id}    ${nome}    200    Descrição original    10
    Validar Produto Atualizado Com Sucesso    ${response}

CT010 - Atualizar produto com dados parcialmente válidos
    [Documentation]    Valida comportamento ao atualizar com alguns campos válidos e outros inválidos
    [Tags]    produtos    negative    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    # Tenta atualizar com preço negativo mas outros campos válidos
    ${response}=    Atualizar Produto    ${produto_id}    Produto Válido    -50    Descrição válida    10
    
    # Deve rejeitar a atualização por causa do preço inválido
    Validar Erro Preco Negativo    ${response}

CT011 - Atualizar produto com quantidade zero
    [Documentation]    Valida comportamento ao atualizar quantidade para zero
    [Tags]    produtos    validation    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Atualizar Produto    ${produto_id}    ${nome}    100    Descrição    0
    
    # API pode aceitar quantidade zero ou rejeitar
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 200    Log To Console    \nAPI aceita quantidade zero
    ...    ELSE    Validar Status Code    ${response}    ${STATUS_400}

CT012 - Atualizar produto múltiplas vezes
    [Documentation]    Valida múltiplas atualizações sucessivas no mesmo produto
    [Tags]    produtos    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    FOR    ${i}    IN RANGE    3
        ${timestamp}=    Get Time    epoch
        ${novo_nome}=    Set Variable    Produto Atualizado ${timestamp}
        ${novo_preco}=    Evaluate    100 + ${i} * 10
        
        ${response}=    Atualizar Produto    ${produto_id}    ${novo_nome}    ${novo_preco}    Descrição ${i}    10
        Validar Produto Atualizado Com Sucesso    ${response}
        
        Log To Console    \nAtualização ${i+1} realizada com sucesso
    END