*** Settings ***
Documentation    Keywords relacionadas ao gerenciamento de produtos
Library          RequestsLibrary
Library          Collections
Resource         ../variables.robot
Resource         ../base_setup.robot
Resource         login_keywords.robot

*** Keywords ***
Criar Produto Valido
    [Documentation]    Cria um produto com dados válidos, usando o token global, e retorna o ID e o nome.
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
    
    Log    Produto criado com sucesso. ID: ${produto_id} | Nome: ${nome}
    RETURN    ${produto_id}    ${nome}

Criar Produtos Com Dados
    [Documentation]    Cria um produto com dados customizados e retorna a resposta.
    [Arguments]    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Criar Produto Sem Autenticação
    [Documentation]    Tenta criar um produto sem passar o token de autenticação (headers).
    [Arguments]    ${nome}    ${preco}    ${descricao}    ${quantidade}
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    
    ${response}=    POST    ${BASE_URL}${PRODUTOS_ENDPOINT}    json=${body}    expected_status=any
    
    RETURN    ${response}

Buscar Produto Por ID
    [Documentation]    Busca um produto específico pelo ID.
    [Arguments]    ${produto_id}
    
    ${response}=    GET    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    expected_status=any
    
    RETURN    ${response}

Atualizar Produto
    [Documentation]    Atualiza um produto existente.
    [Arguments]    ${produto_id}    ${nome}    ${preco}    ${descricao}    ${quantidade}    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${body}=    Create Dictionary
    ...    nome=${nome}
    ...    preco=${preco}
    ...    descricao=${descricao}
    ...    quantidade=${quantidade}
    
    ${response}=    PUT    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    json=${body}    headers=${headers}    expected_status=any
    
    RETURN    ${response}

Deletar Produto
    [Documentation]    Deleta um produto pelo ID.
    [Arguments]    ${produto_id}    ${token}=${TOKEN}
    
    ${headers}=    Criar Headers Com Token    ${token}
    
    ${response}=    DELETE    ${BASE_URL}${PRODUTOS_ENDPOINT}/${produto_id}    headers=${headers}    expected_status=any
    
    RETURN    ${response}


Validar Produto Criado Com Sucesso
    [Documentation]    Valida que o produto foi criado com sucesso (Status 201) e a mensagem esperada.
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_201}
    ${response_json}=    Set Variable    ${response.json()}
    
    Dictionary Should Contain Key    ${response_json}    _id
    Dictionary Should Contain Key    ${response_json}    message
    
    Should Be Equal    ${response_json['message']}    Cadastro realizado com sucesso
    ...    msg=Mensagem de criação de produto incorreta

Validar Erro Token Ausente
    [Documentation]    Valida erro de autenticação quando token está ausente (Status 401).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    401
    Validar Mensagem De Erro    ${response}    Token de acesso ausente, inválido, expirado ou usuário não é administrador

Validar Erro Produto Duplicado
    [Documentation]    Valida erro quando produto já existe (Status 400).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Já existe produto com esse nome

Validar Erro Preco Negativo
    [Documentation]    Valida erro quando preço é negativo (Status 400).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    ${response_json}=    Set Variable    ${response.json()}
    Should Contain    ${response_json['preco']}    deve ser um número positivo
    ...    msg=Mensagem de erro de preço negativo não encontrada

Validar Erro Campo Obrigatorio Produto
    [Documentation]    Valida erro de campo obrigatório em produto (Status 400).
    [Arguments]    ${response}    ${campo}
    
    Validar Status Code    ${response}    ${STATUS_400}
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Contain    ${response_json['${campo}']}    não pode ficar em branco
    ...    msg=Mensagem de campo obrigatório não encontrada para '${campo}'

Validar Produto Nao Encontrado
    [Documentation]    Valida erro quando produto não existe (Status 400).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    ${STATUS_400}
    Validar Mensagem De Erro    ${response}    Produto não encontrado

Validar Produto Atualizado Com Sucesso
    [Documentation]    Valida resposta de atualização de produto bem-sucedida (Status 200).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    200
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Be Equal    ${response_json['message']}    Registro alterado com sucesso
    ...    msg=Mensagem de atualização de produto incorreta

Validar Produto Deletado Com Sucesso
    [Documentation]    Valida resposta de exclusão de produto bem-sucedida (Status 200).
    [Arguments]    ${response}
    
    Validar Status Code    ${response}    200
    ${response_json}=    Set Variable    ${response.json()}
    
    Should Be Equal    ${response_json['message']}    Registro excluído com sucesso
    ...    msg=Mensagem de exclusão de produto incorreta
