*** Settings ***
Documentation    Testes de criação de carrinhos da API ServeRest
Resource         ../../../resources/base_setup.robot
Resource         ../../../resources/variables.robot
Resource         ../../../resources/keywords/login_keywords.robot
Resource         ../../../resources/keywords/produtos_keywords.robot
Resource         ../../../resources/keywords/carrinho_keywords.robot
Resource         ../../../resources/keywords/usuarios_keywords.robot

Suite Setup      Run Keywords    Setup Suite    AND    Realizar Login Como Admin
Suite Teardown   Teardown Suite
Test Setup       Setup Test
Test Teardown    Teardown Test

*** Test Cases ***
CT001 - Adicionar produto válido ao carrinho
    [Documentation]    Valida adição de produto existente ao carrinho
    [Tags]    carrinhos    smoke    high
    
    # Cria produto
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    # Adiciona ao carrinho
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id}    2
    Validar Carrinho Criado Com Sucesso    ${response}

CT002 - Adicionar produto inexistente ao carrinho
    [Documentation]    Valida erro ao tentar adicionar produto que não existe
    [Tags]    carrinhos    negative    high
    
    ${produto_id_fake}=    Set Variable    idInexistente123456
    
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id_fake}    1
    Validar Erro Produto Inexistente    ${response}

CT003 - Adicionar múltiplos produtos ao carrinho
    [Documentation]    Valida adição de vários produtos de uma vez
    [Tags]    carrinhos    smoke    high
    
    # Cria dois produtos
    ${produto_id1}    ${nome1}=    Criar Produto Valido
    ${produto_id2}    ${nome2}=    Criar Produto Valido
    
    # Cria lista de produtos
    ${produto1}=    Create Dictionary    idProduto=${produto_id1}    quantidade=2
    ${produto2}=    Create Dictionary    idProduto=${produto_id2}    quantidade=3
    ${lista_produtos}=    Create List    ${produto1}    ${produto2}
    
    # Adiciona múltiplos produtos
    ${response}=    Adicionar multiplos produtos ao carriho    ${lista_produtos}
    Validar Carrinho Criado Com Sucesso    ${response}

CT004 - Adicionar produto com quantidade zero
    [Documentation]    Valida comportamento ao adicionar produto com quantidade zero
    [Tags]    carrinhos    negative    validation    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id}    0
    
    # Verifica se API aceita ou rejeita quantidade zero
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 400    Log To Console    \nAPI rejeita quantidade zero
    ...    ELSE IF    ${status} == 201    Log To Console    \nAPI aceita quantidade zero

CT005 - Adicionar produto com quantidade negativa
    [Documentation]    Valida erro ao tentar adicionar quantidade negativa
    [Tags]    carrinhos    negative    validation    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id}    -5
    
    Validar Status Code    ${response}    ${STATUS_400}

CT006 - Criar segundo carrinho para mesmo usuário
    [Documentation]    Valida erro ao tentar criar mais de um carrinho por usuário
    [Tags]    carrinhos    negative    high
    
    ${produto_id1}    ${nome1}=    Criar Produto Valido
    ${produto_id2}    ${nome2}=    Criar Produto Valido
    
    # Cria primeiro carrinho
    ${response1}=    Adicionar Produto Ao Carrinho    ${produto_id1}    1
    Validar Carrinho Criado Com Sucesso    ${response1}
    
    # Tenta criar segundo carrinho
    ${response2}=    Adicionar Produto Ao Carrinho    ${produto_id2}    1
    Validar Erro Carrinho Duplicado    ${response2}

CT007 - Adicionar produto duplicado ao carrinho
    [Documentation]    Valida comportamento ao adicionar mesmo produto duas vezes
    [Tags]    carrinhos    validation    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    # Cria lista com produto duplicado
    ${produto1}=    Create Dictionary    idProduto=${produto_id}    quantidade=2
    ${produto2}=    Create Dictionary    idProduto=${produto_id}    quantidade=3
    ${lista_produtos}=    Create List    ${produto1}    ${produto2}
    
    ${response}=    Adicionar multiplos produtos ao carriho    ${lista_produtos}
    
    # API pode aceitar (somando quantidades) ou rejeitar
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 201    Log To Console    \nAPI aceita produto duplicado
    ...    ELSE    Validar Status Code    ${response}    ${STATUS_400}

CT008 - Adicionar produto com ID inválido
    [Documentation]    Valida erro com formato de ID inválido
    [Tags]    carrinhos    negative    validation    medium
    
    ${response}=    Adicionar Produto Ao Carrinho    @#$%INVALID    1
    
    Validar Status Code    ${response}    ${STATUS_400}

CT009 - Criar carrinho sem autenticação
    [Documentation]    Valida erro ao tentar criar carrinho sem token
    [Tags]    carrinhos    security    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${produto}=    Create Dictionary    idProduto=${produto_id}    quantidade=1
    ${produtos}=    Create List    ${produto}
    ${body}=    Create Dictionary    produtos=${produtos}
    
    ${response}=    POST    ${BASE_URL}${CARRINHO_ENDPOINT}    json=${body}    expected_status=401
    
    Validar Status Code    ${response}    401

CT010 - Criar carrinho vazio
    [Documentation]    Valida comportamento ao enviar array de produtos vazio
    [Tags]    carrinhos    negative    validation    medium
    
    ${produtos_vazios}=    Create List
    
    ${response}=    Criar Carrinho Com Produtos    ${produtos_vazios}
    
    # API pode aceitar carrinho vazio ou rejeitar
    ${status}=    Set Variable    ${response.status_code}
    Run Keyword If    ${status} == 201    Log To Console    \nAPI aceita carrinho vazio
    ...    ELSE    Validar Status Code    ${response}    ${STATUS_400}

CT011 - Adicionar produto com quantidade maior que estoque
    [Documentation]    Valida erro ao tentar adicionar mais produtos que o estoque disponível
    [Tags]    carrinhos    negative    validation    high
    
    # Cria produto com quantidade limitada (10)
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    # Tenta adicionar quantidade maior que estoque
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id}    999
    
    Validar Erro Produto Sem Estoque    ${response}