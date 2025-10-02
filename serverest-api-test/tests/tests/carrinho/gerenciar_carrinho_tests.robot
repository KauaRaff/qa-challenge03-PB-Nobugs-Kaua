*** Settings ***
Documentation    Testes de gerenciamento de carrinhos da API ServeRest
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
CT001 - Buscar carrinho por ID válido
    [Documentation]    Valida busca de carrinho existente por ID
    [Tags]    carrinhos    smoke    high
    
    # Cria produto e carrinho
    ${produto_id}    ${nome}=    Criar Produto Valido
    ${response_create}=    Adicionar Produto Ao Carrinho    ${produto_id}    2
    Validar Carrinho Criado Com Sucesso    ${response_create}
    
    ${carrinho_id}=    Set Variable    ${response_create.json()['_id']}
    
    # Busca carrinho
    ${response}=    Buscar Carrinho Por ID    ${carrinho_id}
    Validar Status Code    ${response}    ${STATUS_200}
    
    ${response_json}=    Set Variable    ${response.json()}
    Should Be Equal    ${response_json['_id']}    ${carrinho_id}

CT002 - Buscar carrinho por ID inexistente
    [Documentation]    Valida erro ao buscar carrinho que não existe
    [Tags]    carrinhos    negative    medium
    
    ${response}=    Buscar Carrinho Por ID    idInexistente123456
    Validar Carrinho Nao Encontrado    ${response}

CT003 - Listar todos os carrinhos
    [Documentation]    Valida endpoint que lista todos os carrinhos cadastrados
    [Tags]    carrinhos    smoke    high
    
    ${response}=    Listar todos os carrinhos
    Validar Status Code    ${response}    ${STATUS_200}
    
    ${response_json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${response_json}    carrinhos
    Dictionary Should Contain Key    ${response_json}    quantidade

CT004 - Concluir compra com sucesso
    [Documentation]    Valida conclusão de compra e deleção do carrinho
    [Tags]    carrinhos    high
    
    # Cria produto e carrinho
    ${produto_id}    ${nome}=    Criar Produto Valido
    ${response_create}=    Adicionar Produto Ao Carrinho    ${produto_id}    1
    Validar Carrinho Criado Com Sucesso    ${response_create}
    
    # Conclui compra
    ${response}=    Concluir Compra
    Validar compra conluida com sucesso   ${response}

CT005 - Cancelar compra com sucesso
    [Documentation]    Valida cancelamento de compra e retorno de produtos ao estoque
    [Tags]    carrinhos    high
    
    # Cria produto e carrinho
    ${produto_id}    ${nome}=    Criar Produto Valido
    ${response_create}=    Adicionar Produto Ao Carrinho    ${produto_id}    2
    Validar Carrinho Criado Com Sucesso    ${response_create}
    
    # Cancela compra
    ${response}=    Cancelar Compra
    Validar Compra Cancelada Com Sucesso    ${response}

CT006 - Concluir compra sem ter carrinho
    [Documentation]    Valida erro ao tentar concluir compra sem carrinho ativo
    [Tags]    carrinhos    negative    medium
    
    ${response}=    Concluir Compra
    Validar Carrinho Nao Encontrado    ${response}

CT007 - Cancelar compra sem ter carrinho
    [Documentation]    Valida erro ao tentar cancelar compra sem carrinho ativo
    [Tags]    carrinhos    negative    medium
    
    ${response}=    Cancelar Compra
    Validar Carrinho Nao Encontrado    ${response}

CT008 - Validar quantidade de produtos no carrinho
    [Documentation]    Valida que a quantidade de produtos está correta no carrinho
    [Tags]    carrinhos    validation    medium
    
    # Cria dois produtos
    ${produto_id1}    ${nome1}=    Criar Produto Valido
    ${produto_id2}    ${nome2}=    Criar Produto Valido
    
    # Adiciona ao carrinho
    ${produto1}=    Create Dictionary    idProduto=${produto_id1}    quantidade=2
    ${produto2}=    Create Dictionary    idProduto=${produto_id2}    quantidade=3
    ${lista_produtos}=    Create List    ${produto1}    ${produto2}
    
    ${response}=    Adicionar multiplos produtos ao carriho    ${lista_produtos}
    Validar Carrinho Criado Com Sucesso    ${response}
    
    # Valida quantidade
    Validar Quantidade No Carrinho    ${response}    2

CT009 - Validar preço total do carrinho
    [Documentation]    Valida cálculo do preço total do carrinho
    [Tags]    carrinhos    validation    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id}    2
    Validar Carrinho Criado Com Sucesso    ${response}
    
    ${response_json}=    Set Variable    ${response.json()}
    Dictionary Should Contain Key    ${response_json}    precoTotal
    
    # Preço do produto criado é 100, quantidade 2 = 200
    ${preco_esperado}=    Evaluate    100 * 2
    Should Be Equal As Numbers    ${response_json['precoTotal']}    ${preco_esperado}

CT010 - Criar carrinho e concluir compra em sequência
    [Documentation]    Valida fluxo completo de criar carrinho e finalizar compra
    [Tags]    carrinhos    smoke    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    # Cria carrinho
    ${response_create}=    Adicionar Produto Ao Carrinho    ${produto_id}    1
    Validar Carrinho Criado Com Sucesso    ${response_create}
    
    # Conclui compra
    ${response_conclude}=    Concluir Compra
    Validar compra conluida com sucesso    ${response_conclude}
    
    # Verifica que não há mais carrinho ativo
    ${response_verify}=    Concluir Compra
    Validar Carrinho Nao Encontrado    ${response_verify}

CT011 - Criar carrinho e cancelar compra em sequência
    [Documentation]    Valida fluxo completo de criar carrinho e cancelar compra
    [Tags]    carrinhos    high
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    # Cria carrinho
    ${response_create}=    Adicionar Produto Ao Carrinho    ${produto_id}    3
    Validar Carrinho Criado Com Sucesso    ${response_create}
    
    # Cancela compra
    ${response_cancel}=    Cancelar Compra
    Validar Compra Cancelada Com Sucesso    ${response_cancel}
    
    # Verifica que não há mais carrinho ativo
    ${response_verify}=    Cancelar Compra
    Validar Carrinho Nao Encontrado    ${response_verify}

CT012 - Validar estrutura completa da resposta de carrinho
    [Documentation]    Valida que todos os campos esperados estão presentes
    [Tags]    carrinhos    validation    medium
    
    ${produto_id}    ${nome}=    Criar Produto Valido
    
    ${response}=    Adicionar Produto Ao Carrinho    ${produto_id}    2
    ${response_json}=    Set Variable    ${response.json()}
    
    # Valida campos obrigatórios
    Dictionary Should Contain Key    ${response_json}    _id
    Dictionary Should Contain Key    ${response_json}    produtos
    Dictionary Should Contain Key    ${response_json}    precoTotal
    Dictionary Should Contain Key    ${response_json}    quantidadeTotal
    Dictionary Should Contain Key    ${response_json}    idUsuario
    
    Log To Console    \nTodos os campos obrigatórios do carrinho estão presentes

CT013 - Concluir compra sem autenticação
    [Documentation]    Valida erro ao tentar concluir compra sem token
    [Tags]    carrinhos    security    high
    
    ${response}=    DELETE    ${BASE_URL}${CARRINHO_ENDPOINT}/concluir-compra    expected_status=401
    Validar Status Code    ${response}    401

CT014 - Cancelar compra sem autenticação
    [Documentation]    Valida erro ao tentar cancelar compra sem token
    [Tags]    carrinhos    security    high
    
    ${response}=    DELETE    ${BASE_URL}${CARRINHO_ENDPOINT}/cancelar-compra    expected_status=401
    Validar Status Code    ${response}    401
