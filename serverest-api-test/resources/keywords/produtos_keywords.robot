*** Settings ***
Documentation    Keywords relacionadas ao gerenciamento de produtos
Library          RequestsLibrary
Library          Collections
Resource         ../variables.robot
Resource         ../base_setup.robot
Resource         login_keywords.robot

*** Keywords ***
Criar produto valido
    [Documentation]    Cria um produto com dados válidos e retorna o ID
    [Arguments]    ${token}=${TOKEN}
    
    ${timestamp}=    Get Time    epoch
    ${nome}=    Set Variable    Produto Teste ${timestamp}
    ${preco}=    Set Variable    ${100}
    ${descricao}=    Set Variable    Descrição do produto teste
    ${quantidade}=    Set Variable    ${10}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=201
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    _id
    ...    msg=ID do produto não retornado
    
    ${produto_id}=    Set Variable    ${response_json['_id']}
    
    Log   Produto criado com sucesso. ID: ${produto_id}
    RETURN    ${produto_id}    ${nome}

Criar produtos com dados
    [Documentation]    Cria produto com dados customizados
    [Arguments]    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Criar produto sem autenticação
    [Documentation]    Tenta criar produto sem token de autenticação
    [Arguments]    ${nome}    ${preco}    ${descricao}    ${quantidade}
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    expected_status=401
    
    RETURN    ${response}

Buscar produto por ID
    [Documentation]    Busca produto específico por ID
    [Arguments]    ${produto_id}
    
    ${response}=    GET    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    expected_status=any
    
    RETURN    ${response}

Listar todos produtos
    [Documentation]    Lista todos os produtos cadastrados
    
    ${response}=    GET    ${BASE_URL}${PRODUTOS_ENDPOINT}    expected_status=200
    
    Validar Status Code    ${response}    ${STATUS_200}
    RETURN    ${response}

Atualizar produto
    [Documentation]    Atualiza dados de um produto existente
    [Arguments]    ${produto_id}    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    
    ${response}=    PUT    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    json=${body}    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Deletar produto
    [Documentation]    Deleta um produto por ID
    [Arguments]    ${produto_id}    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    ${response}=    DELETE    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Validar produto criado com Sucesso
    [Documentation]    Valida resposta de criação de produto bem-sucedida
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    _id
    Dictionary Should Contain Key    ${response_json}    message
    
    Should Be Equal    ${response_json['message']}    Cadastro realizado com sucesso
    ...    msg=Mensagem de sucesso não retornada

Validar erro token ausente
    [Documentation]    Valida erro quando token não é enviado
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    401
    Validar Mensagem De Erro    ${response}    Token de acesso ausente

Validar erro preco zero
    [Documentation]    Valida erro quando preço é igual a zero
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json['preco']}    deve ser um número positivo
    ...    msg=Mensagem de erro de preço zero não encontrada

Validar erro preco negativo
    [Documentation]    Valida erro quando preço é negativo
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json['preco']}    deve ser um número positivo
    ...    msg=Mensagem de erro de preço negativo não encontrada

Validar erro campo obrigatorio produto
    [Documentation]    Valida erro de campo obrigatório em produto
    [Arguments]    ${response}    ${campo}
    
    Validar Status Code    ${response}    ${STATUS_400}
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Contain    ${response_json['${campo}']}    obrigatório
    ...    msg=Mensagem de campo obrigatório não encontrada para '${campo}'

Validar produto nao encontrado
    [Documentation]    Valida erro quando produto não existe
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Produto não encontrado

Validar produto atualizado com sucesso
    [Documentation]    Valida resposta de atualização de produto bem-sucedida
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    200
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Be Equal    ${response_json['message']}    Registro alterado com sucesso
    ...    msg=Mensagem de sucesso de atualização não retornada